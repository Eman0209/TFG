import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class RewardsScreen extends StatefulWidget {
  final PresentationController presentationController;

  const RewardsScreen({Key? key, required this.presentationController});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState(presentationController);
}

class _RewardsScreenState extends State<RewardsScreen> {
  late PresentationController _presentationController;

  _RewardsScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  // esta lista se cambiara por todos los trofeos diseñados y luego habra otra lista con los trofeos que tiene un user
  final List<Map<String, dynamic>> trophies = [
    {'title': 'Trophy 1', 'description': 'Explanation of the trophy', 'unlocked': true},
    {'title': 'Trophy 2', 'description': 'Explanation of the trophy', 'unlocked': false},
    {'title': 'Trophy 3', 'description': 'Explanation of the trophy', 'unlocked': true},
    {'title': 'Trophy 4', 'description': 'Explanation of the trophy', 'unlocked': false},
    {'title': 'Trophy 5', 'description': 'Explanation of the trophy', 'unlocked': false},
    {'title': 'Trophy 6', 'description': 'Explanation of the trophy', 'unlocked': true},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rewards', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            for (int i = 0; i < trophies.length; i++)
              _buildTrophyTile(
                trophies[i]['title'],
                trophies[i]['description'],
                trophies[i]['unlocked'],
                isSelected: i == 2,
              ),
          ],
        ),
      ),
    );
  }

  void _showTrophyDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFECE3FF),
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyTile(String title, String description, bool unlocked, {bool isSelected = false}) {
    return GestureDetector(
      onTap: unlocked
          ? () => _showTrophyDialog(title, description)
          : null, // Don't allow tap if locked
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: unlocked ? const Color(0xFFECE3FF) : Colors.grey.shade300,
              border: isSelected ? Border.all(color: Colors.deepPurple, width: 2) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.emoji_events,
              size: 48,
              color: unlocked ? Colors.deepPurple : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: unlocked ? Colors.black87 : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

}