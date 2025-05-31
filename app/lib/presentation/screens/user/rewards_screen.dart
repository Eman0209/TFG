import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/presentation/presentation_controller.dart';

class RewardsScreen extends StatefulWidget {
  final PresentationController presentationController;

  const RewardsScreen({super.key, required this.presentationController});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState(presentationController);
}

class _RewardsScreenState extends State<RewardsScreen> {
  late PresentationController _presentationController;

  _RewardsScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  bool _trophyGiven = false;

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
      body: getAllTrophies(),
    );
  }

  Widget getAllTrophies() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _presentationController.getTrophies(),     
        _presentationController.getMyOwnTrophies() 
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allTrophies = snapshot.data![0] as List<Map<String, dynamic>>;
        final ownedTrophies = snapshot.data![1] as List<String>;

        if (ownedTrophies.length >= 11 && !_trophyGiven) {
            _trophyGiven = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _presentationController.addUserTrophy("lh6Ox374RuLD7CCR7rfu");
            });
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.73,
            children: List.generate(allTrophies.length, (i) {
              final trophy = allTrophies[i];
              final isOwned = ownedTrophies.contains(trophy['id']);
              return _buildTrophyTile(
                trophy['name'],
                trophy['description'],
                trophy['image'],
                isOwned,
              );
            }),
          ),
        );
      },
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

  Widget _buildTrophyTile(String title, String description, String image, bool isOwned,) {
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
              color: isOwned ? null : Colors.grey,
              colorBlendMode: isOwned ? null : BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isOwned ? Colors.black : Colors.grey,
              fontWeight: isOwned ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

}