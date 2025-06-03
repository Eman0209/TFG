import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/mystery/activities/path_validator.dart';
import 'package:app/presentation/widgets/pipe.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PlumbingGameScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;
  final int stepOrder;
  
  const PlumbingGameScreen({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
    required this.stepOrder
  });
  
  @override
  _PlumbingGameScreenState createState() => _PlumbingGameScreenState(presentationController);
}

class _PlumbingGameScreenState extends State<PlumbingGameScreen> {
  late PresentationController _presentationController;

  _PlumbingGameScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  static const int gridSize = 4;

  List<List<PipeTile>> grid = [];

  @override
  void initState() {
    super.initState();
    generatePuzzle();
  }

  void generatePuzzle() {
    grid = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        return PipeTile.random();
      });
    });

    setState(() {});
  }

  Future<void> checkSolution() async {
    if (PathValidator.isConnected(grid)) {
      _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder-1);
      String nextStep = await _presentationController.getNextstep(widget.mysteryId, widget.stepOrder);
      finalPopUp(nextStep);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Encara no..."),
          content: Text("La connexió no està completa. Prova de nou!"),
          actions: [
            TextButton(
              child: Text("D'acord"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Puzzle de canonades")),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Gira les peces tocant-les per connectar la font d'aigua amb el molí.\n"
              "Pot sortir per el lateral.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: gridSize * gridSize,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            grid[row][col].rotate();
                          });
                        },
                        child: CustomPaint(
                          painter: PipePainter(grid[row][col]),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  top: -22,
                  child: Image.asset(
                    'assets/wave.png',
                    width: 100,
                    height: 100,
                  ),
                ),

                Positioned(
                  bottom: 20,
                  right: 4,
                  child: Image.asset(
                    'assets/waterMill.png',
                    width: 100,
                    height: 100,
                  ),
                ),      
              ],
            ),
          ),
          ElevatedButton(
            onPressed: checkSolution,
            child: Text("Comprova connexió"),
          ),
          const SizedBox(height: 20),
        ]
      )
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
