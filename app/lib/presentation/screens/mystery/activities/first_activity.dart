import 'package:app/presentation/screens/mystery/time_service.dart';
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
  State<TranslationPuzzleScreen> createState() => _TranslationPuzzleScreenState(presentationController);
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
  final TimerService _timerService = TimerService();

  @override
  void initState() {
    super.initState();
    shuffledWords = List.from(correctOrder)..shuffle();
    currentOrder = [];
    _timerService.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('translation_game'.tr()),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: resetPuzzle),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'ins_trans_game'.tr(),
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: shuffledWords.map((word) {
                  Color? tileColor;

                  if (currentOrder.contains(word)) {
                    tileColor = Colors.grey.shade400;
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
                    height: 160,
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: currentOrder.isEmpty
                      ? Center(
                          child: Text(
                            'drop_words'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          children: currentOrder.asMap().entries.map((entry) {
                            final index = entry.key;
                            final word = entry.value;
                            Color? color;

                            if (showResults) {
                              if (word == correctOrder[index]) {
                                color = Colors.greenAccent;
                              } else {
                                color = Colors.orangeAccent;
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentOrder.removeAt(index);
                                });
                              },
                              child: WordTile(word: word, color: color),
                            );
                          }).toList(),
                        )
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: currentOrder.length == correctOrder.length
                  ? checkAnswer
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 179, 254),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('check'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkAnswer() async {
    setState(() => showResults = true);
    bool isCorrect = currentOrder.join(' ') == correctOrder.join(' ');
    if (isCorrect) {
      _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder-1);
      await _timerService.persistElapsedTime(_presentationController, widget.routeId);
      String nextStep = await _presentationController.getNextstep(widget.mysteryId, widget.stepOrder-1);
      finalPopUp(nextStep);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('incorrect'.tr()),
          content: Text('incorrect_phrase'.tr()),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 179, 254),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ok'.tr()),
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
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 179, 254),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
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
