class Plot {
  final String id;
  final String name;

  Plot({required this.id, required this.name});

  // Factory constructor to create a Plot from JSON
  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'].toString(),   // convert to String just in case
      name: json['name'] ?? '',
    );
  }

  // Optional: convert Plot back to JSON (useful for POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
