import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class TranslationPuzzleScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;
  final int stepOrder;
  
  const TranslationPuzzleScreen({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
    required this.stepOrder
  });

  @override
  _TranslationPuzzleScreenState createState() => _TranslationPuzzleScreenState(presentationController);
}

class _TranslationPuzzleScreenState extends State<TranslationPuzzleScreen> {
  late PresentationController _presentationController;

  _TranslationPuzzleScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  final List<String> correctOrder = [
    'Pactum',
    'manet',
    'sepultum.',
    'Turris',
    'Arenae',
    'latere',
    'debet.'
  ];
  List<String> currentOrder = [];
  List<String> shuffledWords = [];

  bool showResults = false;

  @override
  void initState() {
    super.initState();
    shuffledWords = List.from(correctOrder)..shuffle();
    currentOrder = [];
  }

  Future<void> checkAnswer() async {
    setState(() => showResults = true);
    bool isCorrect = currentOrder.join(' ') == correctOrder.join(' ');
    if (isCorrect) {
      _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder-1);
      String nextStep = await _presentationController.getNextstep(widget.mysteryId, widget.stepOrder);
      finalPopUp(nextStep);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Incorrecte'),
          content: Text('La frase no és correcta. Torna-ho a provar!'),
          actions: [
            TextButton(
              child: Text('D\'acord'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void resetPuzzle() {
    setState(() {
      currentOrder.clear();
      showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joc de traducció'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: resetPuzzle),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Reorganitza les paraules per formar la frase correcta:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: shuffledWords.map((word) {
                Color? tileColor;

                if (showResults && currentOrder.contains(word)) {
                  int correctIndex = correctOrder.indexOf(word);
                  int currentIndex = currentOrder.indexOf(word);
                  bool isCorrectPosition = currentIndex == correctIndex;
                  tileColor = isCorrectPosition ? Colors.greenAccent : Colors.orangeAccent;
                }

                return Draggable<String>(
                  data: word,
                  feedback: Material(
                    color: Colors.transparent,
                    child: WordTile(word: word, color: tileColor),
                  ),
                  childWhenDragging: WordTile(word: '', faded: true),
                  child: WordTile(word: word, color: tileColor),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            DragTarget<String>(
            onAccept: (word) {
              setState(() {
                if (currentOrder.length < correctOrder.length) {
                  currentOrder.add(word);
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  spacing: 8,
                  children: currentOrder
                        .map((word) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentOrder.remove(word);
                                });
                              },
                              child: WordTile(word: word),
                            ))
                        .toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: currentOrder.length == correctOrder.length
                ? checkAnswer
                : null,
            child: Text('Comprova'),
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

class WordTile extends StatelessWidget {
  final String word;
  final bool faded;
  final Color? color;

  const WordTile({
    super.key, 
    required this.word, 
    this.faded = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: faded
            ? Colors.grey.shade300
            : color ?? Color.fromARGB(255, 206, 179, 254),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        word,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
