import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/mystery/time_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HeraldicPuzzleScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;
  final int stepOrder;
  
  const HeraldicPuzzleScreen({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
    required this.stepOrder
  });

  @override
  _HeraldicPuzzleScreenState createState() => _HeraldicPuzzleScreenState(presentationController);
}

class _HeraldicPuzzleScreenState extends State<HeraldicPuzzleScreen> {
  late PresentationController _presentationController;

  _HeraldicPuzzleScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  final int rows = 6;
  final int cols = 4;
  late List<int> positions; 

  final TimerService _timerService = TimerService();

  @override
  void initState() {
    super.initState();
    _shuffleTiles();
    _timerService.start();
  }

  void _shuffleTiles() {
    positions = List.generate(rows * cols, (index) => index);
    positions.shuffle(Random());
  }

  void _onSwap(int oldIndex, int newIndex) async {
    setState(() {
      final temp = positions[oldIndex];
      positions[oldIndex] = positions[newIndex];
      positions[newIndex] = temp;
    });

    if (_isSolved()) {
      _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder - 1);
      await _timerService.persistElapsedTime(_presentationController, widget.routeId);
      String nextStep = await _presentationController.getNextstep(widget.mysteryId, widget.stepOrder - 1);
      finalPopUp(nextStep);
    }
    
  }

  bool _isSolved() {
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != i) return false;
    }
    return true;
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 32;
    double imageHeight = screenWidth * (rows / cols); // match image's logical shape
    return Scaffold(
      appBar: AppBar(title: Text('Reconstrueix l’escut nobiliari')),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            'Arrossega les peces per recompondre l’escut de la família desapareguda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: screenWidth,
              height: imageHeight,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: rows * cols,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                ),
                itemBuilder: (context, index) {
                  int tileIndex = positions[index];
                  return DragTarget<int>(
                    builder: (context, candidateData, rejectedData) {
                      return Draggable<int>(
                        data: index,
                        feedback: _buildImageTile(tileIndex, screenWidth, imageHeight),
                        childWhenDragging: Container(color: Colors.grey[300]),
                        child: _buildImageTile(tileIndex, screenWidth, imageHeight),
                      );
                    },
                    onAccept: (fromIndex) {
                      _onSwap(fromIndex, index);
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _shuffleTiles()),
            child: Text("Reinicia el trencaclosques"),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(int index, double imageWidth, double imageHeight) {
    double tileWidth = imageWidth / cols;
    double tileHeight = imageHeight / rows;
    int row = index ~/ cols;
    int col = index % cols;

    return ClipRect(
      child: Container(
        width: tileWidth,
        height: tileHeight,
        child: OverflowBox(
          maxWidth: imageWidth,
          maxHeight: imageHeight,
          alignment: Alignment(
            -1.0 + (col * 2 / (cols - 1)),
            -1.0 + (row * 2 / (rows - 1)),
          ),
          child: Image.asset(
            'assets/escut.png',
            width: imageWidth,
            height: imageHeight,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
