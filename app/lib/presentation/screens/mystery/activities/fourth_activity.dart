import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/mystery/time_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MapReconstructionGame extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;
  final int stepOrder;
  
  const MapReconstructionGame({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
    required this.stepOrder
  });

  @override
  State<MapReconstructionGame> createState() => _MapReconstructionGameState(presentationController);
}

class _MapReconstructionGameState extends State<MapReconstructionGame> {
  late PresentationController _presentationController;

  _MapReconstructionGameState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  final TimerService _timerService = TimerService();

  int size = 3; 
  late List<int> tiles;

  double imageWidth = 1194;
  double imageHeight = 828;

  @override
  void initState() {
    super.initState();
    _initializeTiles();
    _timerService.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('reconstruct_map'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'ins_map'.tr(),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      itemCount: tiles.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size,
                      ),
                      itemBuilder: (context, index) => _buildTile(index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _initializeTiles() {
    tiles = List.generate(size * size, (index) => index);
    tiles.shuffle();
    while (!_isSolvable(tiles) || _isSolved()) {
      tiles.shuffle();
    }
  }

  bool _isSolvable(List<int> list) {
    int inversions = 0;
    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length; j++) {
        if (list[i] != list.length - 1 && list[j] != list.length - 1 && list[i] > list[j]) {
          inversions++;
        }
      }
    }
    int blankRow = list.indexOf(list.length - 1) ~/ size;
    return (inversions + blankRow) % 2 == 0;
  }

  bool _isSolved() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i) return false;
    }
    return true;
  }

  void _moveTile(int index) async {
    int emptyIndex = tiles.indexOf(size * size - 1);
    List<int> validMoves = [
      emptyIndex - 1,
      emptyIndex + 1,
      emptyIndex - size,
      emptyIndex + size,
    ];

    if (validMoves.contains(index) &&
        ((index % size - emptyIndex % size).abs() +
                (index ~/ size - emptyIndex ~/ size).abs() ==
            1)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = size * size - 1;
      });

      if (_isSolved()) {
        _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder - 1);
        await _timerService.persistElapsedTime(_presentationController, widget.routeId);
        String nextStep = await _presentationController.getNextstep(widget.mysteryId, widget.stepOrder - 1);
        finalPopUp(nextStep);
      }
    }
  }

  Widget _buildTile(int i) {
    final tileNum = tiles[i];
    final isEmpty = tileNum == size * size - 1;

    double screenWidth = MediaQuery.of(context).size.width - 32;
    double imageHeight = screenWidth * (size / size);

    int row = tileNum ~/ size;
    int col = tileNum % size;

    return GestureDetector(
      onTap: () => _moveTile(i),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          color: isEmpty ? Colors.white : Colors.grey[300],
        ),
        child: isEmpty
          ? null
          : Stack(
              children: [
                ClipRect(
                  child: OverflowBox(
                    maxWidth: screenWidth,
                    maxHeight: imageHeight,
                    alignment: Alignment(
                      -1.0 + 2 * col / (size - 1),
                      -1.0 + 2 * row / (size - 1),
                    ),
                    child: Image.asset(
                      'assets/mapa.png',
                      width: screenWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${tileNum + 1}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  void finalPopUp(String nextStep) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('completed_enigma'.tr()),
          content: Text(nextStep),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _presentationController.mysteryScreen(context, widget.routeId, widget.mysteryId);
              },
              child: Text('continue'.tr()),
            ),
          ],
        );
      },
    );
  }
  
}
