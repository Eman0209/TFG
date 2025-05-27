class RouteData {
  final String id;
  final String name;
  final String category;
  final String description;
  final int duration;
  final List<String> path;
  final String mysteryId;

  RouteData({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.duration,
    required this.path,
    required this.mysteryId,
  });

  factory RouteData.fromMap(Map<String, dynamic> data, String documentId, String language) {
    String langKey = language.toLowerCase();
    String descriptionKey = data.containsKey('description_$langKey')
        ? 'description_$langKey'
        : 'description'; 
    String nameKey = data.containsKey('name_$langKey')
        ? 'name_$langKey'
        : 'name'; 

    return RouteData(
      id: documentId,
      name: data[nameKey] ?? '',
      category: data['category'] ?? '',
      description: data[descriptionKey] ?? '',
      duration: data['time'] is int ? data['time'] : 60,
      path: List<String>.from(data['path'] ?? []),
      mysteryId: data['mysteryId'] ?? ''
    );
  }

  // Convert RouteData to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'time': duration,
      'path': path,
      'mysteryId': mysteryId,
    };
  }

}
