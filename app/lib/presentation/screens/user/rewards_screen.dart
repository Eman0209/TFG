import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text('rewards'.tr(), style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _presentationController.getTrophies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final trophies = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.73,
              children: List.generate(trophies.length, (i) {
                final trophy = trophies[i];
                return _buildTrophyTile(
                  trophy['name'],
                  trophy['description'],
                  trophy['image'],
                );
              }),
            ),
          );
        },
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
              child: Text('close'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyTile(String title, String description, String image) {
    return GestureDetector(
      onTap: () {
        _showTrophyDialog(title, description); 
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: null,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Image(
              width: 100,
              height: 100,
              image: AssetImage(image),
              color: Colors.grey,
              colorBlendMode: BlendMode.srcIn
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

}