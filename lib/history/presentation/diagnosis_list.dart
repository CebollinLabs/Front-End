// presentation/diagnosis_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/utils/color_ext.dart';
import '../infrastructure/api.dart';
import '../domain/models.dart';
import '../application/usecases.dart';

class DiagnosisListScreen extends StatefulWidget {
  final String baseUrl;
  const DiagnosisListScreen({super.key, required this.baseUrl});

  @override
  State<DiagnosisListScreen> createState() => _DiagnosisListScreenState();
}

class _DiagnosisListScreenState extends State<DiagnosisListScreen> with SingleTickerProviderStateMixin {
  late Future<List<DiagnosisRequest>> _future;
  late AnimationController _fabController;
  
  // Filtros
  String? _selectedDisease;
  String? _selectedPlot;
  DateTimeRange? _dateRange;
  List<DiagnosisRequest> _allItems = [];
  List<DiagnosisRequest> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  void _loadData() {
    _future = DiagnosisApi(baseUrl: widget.baseUrl).fetchAll().then((items) {
      setState(() {
        _allItems = items;
        _applyFilters();
      });
      return items;
    });
  }

  void _applyFilters() {
    _filteredItems = _allItems.where((item) {
      final vm = toCardVM(item);
      
      // Filtro por tipo de enfermedad
      if (_selectedDisease != null && vm.diseaseLabel != _selectedDisease) {
        return false;
      }
      
      // Filtro por lote (plotName)
      if (_selectedPlot != null && vm.plotName != _selectedPlot) {
        return false;
      }
      
      // Filtro por fecha
      if (_dateRange != null) {
        try {
          final itemDate = _parseDate(vm.day);
          if (itemDate == null || 
              itemDate.isBefore(_dateRange!.start) || 
              itemDate.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        } catch (_) {
          return true;
        }
      }
      
      return true;
    }).toList();
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}
    return null;
  }

  Set<String> _getAvailableDiseases() {
    return _allItems.map((item) => toCardVM(item).diseaseLabel).toSet();
  }

  Set<String> _getAvailablePlots() {
    return _allItems.map((item) => toCardVM(item).plotName).where((p) => p.isNotEmpty).toSet();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = DiagnosisApi(baseUrl: widget.baseUrl).fetchAll().then((items) {
        setState(() {
          _allItems = items;
          _applyFilters();
        });
        return items;
      });
    });
    try {
      await _future;
    } catch (_) {}
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedDisease: _selectedDisease,
        selectedPlot: _selectedPlot,
        dateRange: _dateRange,
        availableDiseases: _getAvailableDiseases().toList(),
        availablePlots: _getAvailablePlots().toList(),
        onApply: (disease, plot, dateRange) {
          setState(() {
            _selectedDisease = disease;
            _selectedPlot = plot;
            _dateRange = dateRange;
            _applyFilters();
          });
        },
        onClear: () {
          setState(() {
            _selectedDisease = null;
            _selectedPlot = null;
            _dateRange = null;
            _applyFilters();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  final hasActiveFilters = _selectedDisease != null || _selectedPlot != null || _dateRange != null;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Diagnósticos', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (hasActiveFilters) _ActiveFiltersBar(
            selectedDisease: _selectedDisease,
            selectedPlot: _selectedPlot,
            dateRange: _dateRange,
            onClearDisease: () {
              setState(() {
                _selectedDisease = null;
                _applyFilters();
              });
            },
            onClearPlot: () {
              setState(() {
                _selectedPlot = null;
                _applyFilters();
              });
            },
            onClearDate: () {
              setState(() {
                _dateRange = null;
                _applyFilters();
              });
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: Theme.of(context).primaryColor,
              child: FutureBuilder<List<DiagnosisRequest>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: 3,
                      itemBuilder: (_, index) => _ShimmerCard(delay: index * 100),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData || _filteredItems.isEmpty) {
                    return _EmptyState(
                      onRetry: _refresh,
                      hasFilters: hasActiveFilters,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _filteredItems.length,
                    itemBuilder: (_, i) => _AnimatedListItem(
                      index: i,
                      child: DiagnosisCard(vm: toCardVM(_filteredItems[i])),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  final String? selectedDisease;
  final String? selectedPlot;
  final DateTimeRange? dateRange;
  final VoidCallback onClearDisease;
  final VoidCallback onClearPlot;
  final VoidCallback onClearDate;

  const _ActiveFiltersBar({
    this.selectedDisease,
    this.selectedPlot,
    this.dateRange,
    required this.onClearDisease,
    required this.onClearPlot,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (selectedDisease != null)
              _FilterChip(
                label: selectedDisease!,
                onClear: onClearDisease,
                icon: Icons.health_and_safety,
              ),
            if (selectedDisease != null && (selectedPlot != null || dateRange != null))
              const SizedBox(width: 8),
            if (selectedPlot != null)
              _FilterChip(
                label: selectedPlot!,
                onClear: onClearPlot,
                icon: Icons.agriculture,
              ),
            if (selectedPlot != null && dateRange != null)
              const SizedBox(width: 8),
            if (dateRange != null)
              _FilterChip(
                label: '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)}',
                onClear: onClearDate,
                icon: Icons.calendar_today,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.onClear,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
      decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacitySafe(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacitySafe(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? selectedDisease;
  final String? selectedPlot;
  final DateTimeRange? dateRange;
  final List<String> availableDiseases;
  final List<String> availablePlots;
  final Function(String?, String?, DateTimeRange?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.selectedDisease,
    required this.selectedPlot,
    required this.dateRange,
    required this.availableDiseases,
    required this.availablePlots,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _tempDisease;
  late String? _tempPlot;
  late DateTimeRange? _tempDateRange;

  @override
  void initState() {
    super.initState();
    _tempDisease = widget.selectedDisease;
    _tempPlot = widget.selectedPlot;
    _tempDateRange = widget.dateRange;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _tempDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tempDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar todo'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de enfermedad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.availableDiseases.map((disease) {
                    final isSelected = _tempDisease == disease;
                    return ChoiceChip(
                      label: Text(disease),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _tempDisease = selected ? disease : null;
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacitySafe(0.2),
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                if (widget.availablePlots.isNotEmpty) ...[
                  const Text(
                    'Lote',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.availablePlots.map((plot) {
                      final isSelected = _tempPlot == plot;
                      return ChoiceChip(
                        label: Text(plot),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _tempPlot = selected ? plot : null;
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor.withOpacitySafe(0.2),
                        labelStyle: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Rango de fechas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _tempDateRange == null
                                ? 'Seleccionar rango de fechas'
                                : '${_formatDate(_tempDateRange!.start)} - ${_formatDate(_tempDateRange!.end)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _tempDateRange == null ? Colors.grey.shade600 : Colors.black87,
                              fontWeight: _tempDateRange == null ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_tempDateRange != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _tempDateRange = null;
                              });
                            },
                            child: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempDisease, _tempPlot, _tempDateRange);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Aplicar filtros',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final int delay;
  const _ShimmerCard({required this.delay});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacitySafe(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      value: _shimmerController.value,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  final bool hasFilters;
  
  const _EmptyState({required this.onRetry, this.hasFilters = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.inbox_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No hay resultados' : 'Sin diagnósticos por ahora',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          if (hasFilters)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Intenta ajustar los filtros',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosisCard extends StatefulWidget {
  final DiagnosisCardVM vm;
  const DiagnosisCard({super.key, required this.vm});

  @override
  State<DiagnosisCard> createState() => _DiagnosisCardState();
}

class _DiagnosisCardState extends State<DiagnosisCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _confidenceColor(String percent) {
    final v = double.tryParse(percent.replaceAll('%', '')) ?? 0.0;
    if (v >= 90.0) return Colors.green.shade600;
    if (v >= 70.0) return Colors.amber.shade700;
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _confidenceColor(widget.vm.confidencePercent);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: () {
          // Acción al presionar la tarjeta
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
                BoxShadow(
                color: Colors.black.withOpacitySafe(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.vm.day,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    _ConfidenceChip(
                      percent: widget.vm.confidencePercent,
                      color: chipColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.vm.diseaseLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Lote: ${widget.vm.plotName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _StatusBadge(status: widget.vm.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  final String percent;
  final Color color;

  const _ConfidenceChip({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacitySafe(0.15), color.withOpacitySafe(0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            percent,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}