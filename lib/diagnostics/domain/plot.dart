class Plot {
  final String id;
  final String name;

  Plot({required this.id, required this.name});

  // Constructor para parsear desde JSON (de la API)
  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // Si quieres convertir de Plot a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
