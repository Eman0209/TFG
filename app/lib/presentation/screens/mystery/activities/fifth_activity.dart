import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/mystery/time_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CryptogramGame extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;
  final int stepOrder;
  final Locale language;
  final int game;
  
  const CryptogramGame({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
    required this.stepOrder,
    required this.language,
    required this.game
  });

  @override
  State<CryptogramGame> createState() => _CryptogramGameState(presentationController);
}

class _CryptogramGameState extends State<CryptogramGame> {
  late PresentationController _presentationController;

  _CryptogramGameState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  final TimerService _timerService = TimerService();

  late String phrase;
  final Map<int, String> userInput = {};
  final Map<int, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    phrase = _getPhraseByLocale(widget.language);
    _timerService.start();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getPhraseByLocale(Locale locale) {
    if (widget.game == 5) {
      switch (locale.languageCode) {
        case 'es':
          return "Bajo la fabrica de cemento, se esconde lo que la guerra no destruyo.";
        case 'en':
          return "Beneath the cement factory, lies what the war didn't destroy.";
        default:
          return "Sota la fabrica de ciment, s'amaga allo que la guerra no va destruir.";
      }
    }
    else {
      switch (locale.languageCode) {
        case 'es':
          return "Se descubrio una camara subterranea. Se cerro y nunca mas hablamos de ella.";
        case 'en':
          return "An underground chamber was discovered. It was sealed, and we never spoke of it again.";
        default:
          return "Es va descobrir una cambra subterrania. Es va tancar i mai mes en vam parlar.";
      }
    }
  }

  bool _isCorrectLetter(int index) {
    final correctChar = phrase[index].toUpperCase();
    final userChar = controllers[index]?.text.toUpperCase() ?? '';
    return correctChar == userChar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('cryptogram'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 8,
                  children: _buildTiles(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(100, 8, 100, 16),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _checkSolution,
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
        ),
      ),
    );
  }

  List<Widget> _buildTiles() {
    List<Widget> tiles = [];

    for (int i = 0; i < phrase.length; i++) {
      final char = phrase[i];
      final isLetter = RegExp(r'[A-Za-z]').hasMatch(char);

      if (!isLetter) {
        tiles.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              char,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
        continue;
      }

      final encodedValue = char.toUpperCase().codeUnitAt(0) - 64;
      final controller = controllers.putIfAbsent(
        i,
        () => TextEditingController(text: userInput[i] ?? ''),
      );

      final isCorrect = _isCorrectLetter(i);

      tiles.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 44,
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green[200] : Colors.white,
                border: Border.all(color: Colors.black26),
              ),
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    userInput[i] = value;
                  });
                },
                maxLength: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              encodedValue.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }

    return tiles;
  }

  Future<void> _checkSolution() async {
    StringBuffer guessBuffer = StringBuffer();

    for (int i = 0; i < phrase.length; i++) {
      final char = phrase[i];
      final isLetter = RegExp(r'[A-Za-z]').hasMatch(char);

      if (!isLetter) {
        guessBuffer.write(char);
      } else {
        final letter = (userInput[i] ?? '').toUpperCase();
        guessBuffer.write(letter.isNotEmpty ? letter : ' ');
      }
    }

    final guess = guessBuffer.toString().toUpperCase();
    final actual = phrase.toUpperCase();

    final success = guess == actual;

    if (success) {
      _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder-1);
      await _timerService.persistElapsedTime(_presentationController, widget.routeId);
      String nextStep = await _presentationController.getNextstep(widget.mysteryId, widget.stepOrder-1);
      finalPopUp(nextStep);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('incorrect'.tr()),
          content: Text('incorrect_cryp'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 179, 254),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('close'.tr()),
            ),
          ],
        ),
      );
    }
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