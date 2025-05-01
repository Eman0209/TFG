class StepData {
  final String title;
  final String narration;
  final bool completed;
  final String resum;
  final String instructions;
  final int order;

  StepData({
    required this.title, 
    required this.narration,
    required this.completed,
    required this.resum,
    required this.instructions,
    required this.order
  });

  factory StepData.fromMap(Map<String, dynamic> data) {
    return StepData(
      title: data['title'] ?? 'No Title',
      narration: data['narration'] ?? 'No narration',
      completed: data['complete'] ?? false,
      resum: data['resum'] ?? 'No resum',
      instructions: data['instructions'] ?? 'No instructions',
      order: data['order'] ?? 0
    );
  }
}