class Plot {
  final String id;
  final String name;
  Plot({required this.id, required this.name});

  factory Plot.fromJson(Map<String, dynamic> json) =>
      Plot(id: json['id'], name: json['name']);
}
