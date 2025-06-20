class StepData {
  final String title;
  final String narration;
  final String resum;
  final String instructions;
  final int order;
  final String nextStep;

  StepData({
    required this.title, 
    required this.narration,
    required this.resum,
    required this.instructions,
    required this.order,
    required this.nextStep
  });

  factory StepData.fromMap(Map<String, dynamic> data) {
    return StepData(
      title: data['title'] ?? 'No Title',
      narration: data['narration'] ?? 'No narration',
      resum: data['resum'] ?? 'No resum',
      instructions: data['instructions'] ?? 'No instructions',
      order: data['order'] ?? 0,
      nextStep: data['next_step'] ?? 'No next step'
    );
  }
}