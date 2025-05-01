class RouteData {
  final String id;
  final String name;
  final String description;
  final int duration;
  final List<String> path;
  final String mysteryId;

  RouteData({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.path,
    required this.mysteryId,
  });

  factory RouteData.fromMap(Map<String, dynamic> data, String documentId) {
    return RouteData(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      duration: data['time'] ?? '1h',
      path: List<String>.from(data['path'] ?? []),
      mysteryId: data['mysteryId'] ?? ''
    );
  }

  // Convert RouteData to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'time': duration,
      'path': path,
      'mysteryId': mysteryId,
    };
  }

}
