import 'package:app/presentation/presentation_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/domain/controllers/user_controller.dart';
import 'package:app/data/datasources/user_datasource.dart';

import 'mocks.mocks.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
//class MockDomainController extends Mock implements DomainController {}
class MockBuildContext extends Mock implements BuildContext {}
class MockUser extends Mock implements User {}

class MockDatasource extends Mock implements FirebaseUserDatasource {}

// Unit tests
//@GenerateMocks([FirebaseAuth, User])
void main() {

  // userLogged
  group('userLogged', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

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
      debugPrint('userLogged when logged. Test result: $result');
      expect(result, isTrue);
    });

    test('returns false when no user is logged in', () {
      when(mockAuth.currentUser).thenReturn(null);

      final result = userLoggedTest(mockAuth);
      debugPrint('userLogged when not logged. Test result: $result');
      expect(result, isFalse);
    });
  });

  // createUser
  group('createUser', (){
    /*
    void createUser(User? user, String username) async {
      if (user != null) {
        // Reference to the "users" collection
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Check if user already exists
        final userDoc = await userDocRef.get();
        if (!userDoc.exists) {
          // Create a new document with user info
          await userDocRef.set({
            'uid': user.uid,
            'email': user.email,
            'name': username,
            'routes': []
          });
        }
      }
    }
    */
  });

  // checkLoggedInUser
  group('checkLoggedInUser', (){
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockBuildContext mockContext;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockContext = MockBuildContext();
      mockFirestore = MockFirebaseFirestore();
    });

    /*
    test('calls mapScreen and sets _user if user is logged in', () {
      // Arrange
      when(mockAuth.currentUser).thenReturn(mockUser);
      final controller = _TestableController(mockAuth, mockFirestore);
      
      bool mapScreenCalled = false;
      controller.mapScreenCallback = (_) {
        mapScreenCalled = true;
      };

      // Act
      controller.checkLoggedInUser(mockContext);

      // Assert
      expect(controller.currentUser, equals(mockUser));
      expect(mapScreenCalled, isTrue);
    });
    

    test('does nothing if user is not logged in', () {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      final controller = _TestableController(mockAuth, mockFirestore);

      bool mapScreenCalled = false;
      controller.mapScreenCallback = (_) {
        mapScreenCalled = true;
      };

      // Act
      controller.checkLoggedInUser(mockContext);

      // Assert
      expect(controller.currentUser, isNull);
      expect(mapScreenCalled, isFalse);
    });
    */
  });
  

  // handleGoogleSignIn
  group('handleGoogleSignIn', (){

  });

}
/*
class _TestableController extends PresentationController {
  _TestableController(FirebaseAuth auth, FirebaseFirestore firestore)
      : super(auth: auth, firestore: firestore);
}
*/
