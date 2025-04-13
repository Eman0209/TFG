import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_test.mocks.dart';

// Unit tests
@GenerateMocks([FirebaseAuth, User])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  // userLogged
  group('userLogged', () {

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
    });

    bool userLoggedTest(FirebaseAuth auth) {
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        return true;
      } else {
        return false;
      }
    }

    test('returns true when user is logged in', () {
      when(mockAuth.currentUser).thenReturn(mockUser);
      
      final result = userLoggedTest(mockAuth);
      debugPrint('Test result: $result');
      expect(result, isTrue);
    });

    test('returns false when no user is logged in', () {
      when(mockAuth.currentUser).thenReturn(null);

      final result = userLoggedTest(mockAuth);
      debugPrint('Test result: $result');
      expect(result, isFalse);
    });
  });

  // getFirebaseAuth

  // getUser

  // createUser

  // checkLoggedInUser

  // handleGoogleSignIn


}