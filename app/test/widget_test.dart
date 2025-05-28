import 'package:app/presentation/screens/user/login.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/presentation/screens/user/how_to_play_screen.dart'; 
import 'package:app/presentation/screens/user/edit_user_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

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

      expect(find.text('how_to_play_1_title'.tr()), findsOneWidget);
      expect(find.text('how_to_play_1_body'.tr()), findsOneWidget);
      expect(find.text('how_to_play_5_title'.tr()), findsOneWidget);
      expect(find.text('how_to_play_tips_body'.tr()), findsOneWidget);
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

} 