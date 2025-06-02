import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mockito/mockito.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';
import 'package:app/presentation/screens/user/how_to_play_screen.dart'; 
import 'package:app/presentation/screens/user/edit_user_screen.dart';
import 'package:app/presentation/screens/user/login.dart';
import 'package:app/presentation/screens/mystery/introduction_screen.dart';
import 'package:app/presentation/screens/mystery/mystery_screen.dart';
import 'package:app/presentation/screens/mystery/step_screen.dart';
import 'package:app/presentation/widgets/custom_appbar.dart';
import 'package:app/domain/models/steps.dart';

import '../mocks.mocks.dart';

void main() {

  late MockPresentationController mockPresentationController;

  setUp(() async {
    mockPresentationController = MockPresentationController();
  });

  group("Translationts Tests", () {
    testWidgets('renders all how to play sections and translations work', (WidgetTester tester) async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('es'), Locale('ca')],
          path: 'assets/lang',
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('en'),
          child: MaterialApp(
            home: HowToPlayScreen(presentationController: mockPresentationController),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('how_to_play_1_title'), findsOneWidget);
      expect(find.text('how_to_play_1_body'), findsOneWidget);
      expect(find.text('how_to_play_5_title'), findsOneWidget);
      expect(find.text('how_to_play_tips_body'), findsOneWidget);
    });
  });

  group("EditUserScreen Tests ", () {
    testWidgets('EditUserScreen renders correctly and allows text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return EditUserScreen(presentationController: mockPresentationController);
              },
            ),
          ),
        ),
      );

      // Verify AppBar title is present
      expect(find.text('editUser'), findsOneWidget);

      // Verify main title text is present
      expect(find.text('editNameUser'), findsOneWidget);

      // Verify TextField is present
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Enter text into the TextField
      await tester.enterText(textFieldFinder, 'NewUsername');
      expect(find.text('NewUsername'), findsOneWidget);

      // Verify ElevatedButton is present and enabled
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      expect(tester.widget<ElevatedButton>(buttonFinder).enabled, isTrue);

      // Tap the button
      await tester.tap(buttonFinder);
      await tester.pump();
    });

    testWidgets('shows SnackBar and calls editUsername when username is not empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditUserScreen(
            presentationController: mockPresentationController,
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      final saveButtonFinder = find.byType(ElevatedButton);

      // Enter text
      await tester.enterText(textFieldFinder, 'new_user');
      await tester.pump();

      // Tap save button
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Verify SnackBar with username_updated message is shown
      expect(find.textContaining('username_updated'), findsOneWidget);

      // Verify the mock controller method is called with the correct username and context
      verify(mockPresentationController.editUsername('new_user', any)).called(1);
    });

    testWidgets('shows SnackBar when username is empty and does NOT call editUsername', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditUserScreen(
            presentationController: mockPresentationController,
          ),
        ),
      );

      final saveButtonFinder = find.byType(ElevatedButton);

      // Do NOT enter text (empty username)
      await tester.tap(saveButtonFinder);
      await tester.pump();

      // Verify SnackBar with username_empty message is shown
      expect(find.text('username_empty'), findsOneWidget);

      // Verify editUsername is NOT called
      verifyNever(mockPresentationController.editUsername(any, any));
    });

  });

  group("Login Class Tests", () {
    testWidgets('calls checkLoggedInUser after build', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Login(presentationController: mockPresentationController),
      ));

      // Wait for post frame callbacks
      await tester.pump();

      verify(mockPresentationController.checkLoggedInUser(any)).called(1);
    });
  });
  
  group("CustomBottomNavigationBar Tests", () {
    testWidgets('CustomBottomNavigationBar displays tabs and calls onTabChange', (WidgetTester tester) async {
      int selectedIndex = 1; 
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: selectedIndex,
              onTabChange: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Verify that the GButtons (tabs) are present by their text
      expect(find.text('ruta'), findsOneWidget);
      expect(find.text('done'), findsOneWidget);
      expect(find.text('me'), findsOneWidget);

      // Tap on the first tab (index 0)
      await tester.tap(find.widgetWithText(GButton, 'ruta'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 0);

      // Tap on the last tab (index 2)
      await tester.tap(find.widgetWithText(GButton, 'me'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 2);
    });
  });

  group("CustomTopNavigationBar Tests", () {
    testWidgets('TabBar switches views and triggers callback', (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: CustomTopNavigationBar(
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              selectedIndex = index;
            },
          ),
        ),
      );

      // Ensure first tab is selected
      expect(find.text('Map View'), findsOneWidget);
      expect(find.text('Mystery View'), findsNothing);

      // Tap on the second tab ("mistery")
      await tester.tap(find.text('mistery'));
      await tester.pumpAndSettle();

      // Check if the callback was triggered
      expect(selectedIndex, 1);

      // Ensure second view is now shown
      expect(find.text('Map View'), findsNothing);
      expect(find.text('Mystery View'), findsOneWidget);
    });
  });

  group("Introduction Screen Test", () {
    testWidgets('loads introduction and navigates to map', (WidgetTester tester) async {
      const mysteryId = 'mystery1';
      const routeId = 'route1';
      const introText = 'Welcome to the mystery!';

      when(mockPresentationController.getIntroduction(mysteryId))
          .thenAnswer((_) async => introText);

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: IntroScreen(
            mysteryId: mysteryId,
            routeId: routeId,
            presentationController: mockPresentationController,
          ),
        ),
      );

      // Wait for FutureBuilder to resolve
      await tester.pumpAndSettle();

      // Assert intro text
      expect(find.text(introText), findsOneWidget);

      // Assert "go to location" text
      expect(find.textContaining('go_to_location'), findsOneWidget); // adjust if hardcoded string

      // Find the button and tap it
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();

      // Verify methods are called
      verify(mockPresentationController.addStardtedRoute(any, routeId)).called(1);
      verify(mockPresentationController.startedRouteScreen(any, routeId)).called(1);
    });
  });

  group("Mystery Screen Test", () {
    
    Widget buildTestWidget() {
      return MaterialApp(
        home: MysteryScreen(
          routeId: 'route1',
          mysteryId: 'mystery1',
          presentationController: mockPresentationController,
        ),
      );
    }
    testWidgets('MysteryScreen displays steps and handles finish logic', (WidgetTester tester) async {
      // Mock responses
      when(mockPresentationController.getMysteryTitle(any))
          .thenAnswer((_) async => 'Mocked Route Title');

      when(mockPresentationController.getCompletedSteps(any))
          .thenAnswer((_) async => List.generate(5, (i) => StepData(
            title: 'Step ${i + 1}',
            resum: 'Description ${i + 1}',
            order: i + 1,
            narration: "Narracio",
            instructions: "instructions",
            next_step: "Next step"
          )));

      when(mockPresentationController.getLengthOfSteps(any))
          .thenAnswer((_) async => 5);

      when(mockPresentationController.getStartedRouteDuration(any))
          .thenAnswer((_) async => const Duration(minutes: 10));

      // Pump the widget
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify title is shown
      expect(find.text('Mocked Route Title'), findsOneWidget);

      // Verify all steps are shown
      for (int i = 1; i <= 5; i++) {
        expect(find.text('Step $i'), findsOneWidget);
        expect(find.text('Description $i'), findsOneWidget);
      }

      // Verify completion popup appears
      expect(find.text('finished_congrats'), findsOneWidget);

      // Tap "Close route" button
      final closeButton = find.widgetWithText(ElevatedButton, 'close_route');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Verify expected controller calls
      verify(mockPresentationController.getStartedRouteDuration(any)).called(2);
      verify(mockPresentationController.deleteStartedRoute(any, any)).called(1);
      verify(mockPresentationController.addDoneRoute(any, any, any)).called(1);
    });
  });

  group("Step Screen Test", () {
    Widget buildTestWidget({required String mysteryId, required int stepOrder}) {
      return MaterialApp(
        home: StepScreen(
          routeId: 'route1',
          mysteryId: mysteryId,
          stepOrder: stepOrder,
          presentationController: mockPresentationController,
        ),
      );
    }

    testWidgets('shows loading indicator while fetching step', (WidgetTester tester) async {
      // Arrange: stub to never complete
      final completer = Completer<StepData?>();
      when(mockPresentationController.getStepInfo(any, any)).thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(buildTestWidget(mysteryId: 'mystery1', stepOrder: 1));

      // Assert loading indicator shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text when step loading fails', (WidgetTester tester) async {
      when(mockPresentationController.getStepInfo(any, any))
        .thenAnswer((_) async => throw Exception('Failed to load'));

      await tester.pumpWidget(buildTestWidget(mysteryId: 'mystery1', stepOrder: 1));
      await tester.pumpAndSettle();

      expect(find.text('Step not found or error loading step.'), findsOneWidget);
    });

    testWidgets('shows error text when step is null', (WidgetTester tester) async {
      when(mockPresentationController.getStepInfo(any, any)).thenAnswer((_) async => null);

      await tester.pumpWidget(buildTestWidget(mysteryId: 'mystery1', stepOrder: 1));
      await tester.pumpAndSettle();

      expect(find.text('Step not found or error loading step.'), findsOneWidget);
    });

    testWidgets('shows step narration and instructions when loaded', (WidgetTester tester) async {
      final stepData = StepData(
        title: 'Step 1',
        resum: 'Desc',
        order: 1,
        narration: 'This is narration text',
        instructions: 'These are instructions',
        next_step: 'Next step'
      );

      when(mockPresentationController.getStepInfo(any, any)).thenAnswer((_) async => stepData);

      await tester.pumpWidget(buildTestWidget(mysteryId: 'mystery1', stepOrder: 1));
      await tester.pumpAndSettle();

      // Check UI
      expect(find.text('Narration'), findsOneWidget);
      expect(find.text('This is narration text'), findsOneWidget);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('These are instructions'), findsOneWidget);

      // Check app bar title (assuming localization is set up correctly)
      expect(find.text('new_track'), findsOneWidget);

      // Check button text
      expect(find.widgetWithText(ElevatedButton, 'start_game'), findsOneWidget);
    });

  });

} 

extension TestTr on String {
  String tr() => this; 
}
