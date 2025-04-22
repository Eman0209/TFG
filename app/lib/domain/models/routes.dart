class RouteData {
  final String name;
  final String description;
  final int duration;
  final List<String> path;

  RouteData({
    required this.name,
    required this.description,
    required this.duration,
    required this.path,
  });

  factory RouteData.fromMap(Map<String, dynamic> data) {
    return RouteData(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      duration: data['time'] ?? '1h',
      path: List<String>.from(data['path'] ?? []),
    );
  }

  // Convert RouteData to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'time': duration,
      'path': path,
    };
  }

}
