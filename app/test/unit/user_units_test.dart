import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/data/datasources/user_datasource.dart';

import '../mocks.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late FirebaseUserDatasource datasource;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockGoogleSignInAccount mockGoogleUser;
  late MockGoogleSignInAuthentication mockGoogleAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    mockCollectionRef = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockAuth = MockFirebaseAuth();
    mockGoogleUser = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();

    datasource = FirebaseUserDatasource(
      auth: mockAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('userLogged', () {
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

  group('FirebaseUserDatasource.createUser', () {

    setUp(() {
      when(mockUser.uid).thenReturn('uid_abc');
      when(mockUser.email).thenReturn('test@email.com');
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc('uid_abc')).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
    });

    test('creates user if not exists', () async {
      when(mockDocumentSnapshot.exists).thenReturn(false);

      await datasource.createUser(mockUser, 'TestName');

      verify(mockDocumentRef.set({
        'uid': 'uid_abc',
        'email': 'test@email.com',
        'name': 'TestName',
      })).called(1);

      debugPrint('Test: User was created because document did not exist.');
    });

    test('does not create user if already exists', () async {
      when(mockDocumentSnapshot.exists).thenReturn(true);

      await datasource.createUser(mockUser, 'TestName');

      verifyNever(mockDocumentRef.set(any));

      debugPrint('Test: User was NOT created because document already existed.');
    });
  });

  group('FirebaseUserDatasource.editUsername', () {

    setUp(() {
      when(mockUser.uid).thenReturn('user123');

      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc('user123')).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
    });

    test('updates username if user document exists', () async {
      when(mockDocumentSnapshot.exists).thenReturn(true);

      await datasource.editUsername(mockUser, 'NewName');

      verify(mockDocumentRef.update({'name': 'NewName'})).called(1);

      debugPrint('Test: Users name was updated.');
    });

    test('does not update username if user document does not exist', () async {
      when(mockDocumentSnapshot.exists).thenReturn(false);

      await datasource.editUsername(mockUser, 'NewName');

      verifyNever(mockDocumentRef.update(any));

      debugPrint('Test: Users name was NOT updated because user didn''t exist');
    });
  });

  group('FirebaseUserDatasource.signInWithGoogle', () {
    test('returns UserCredential on successful sign in', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleAuth.accessToken).thenReturn('access-token');
      when(mockGoogleAuth.idToken).thenReturn('id-token');
      when(mockAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);

      final result = await datasource.signInWithGoogle();

      expect(result, mockUserCredential);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAuth.signInWithCredential(any)).called(1);
    });

    test('returns null if user cancels sign in', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await datasource.signInWithGoogle();

      expect(result, null);
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAuth.signInWithCredential(any));
    });

    test('logs and returns null on exception', () async {
      when(mockGoogleSignIn.signIn()).thenThrow(Exception('Failed to sign in'));

      final result = await datasource.signInWithGoogle();

      expect(result, null);
    });

  });

  group('FirebaseUserDatasource.accountExists', () {
    setUp(() {
      when(mockUser.uid).thenReturn('user123');
      when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc('user123')).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
    });

    test('returns true when user document exists', () async {
      when(mockDocumentSnapshot.exists).thenReturn(true);

      final result = await datasource.accountExists(mockUser);

      expect(result, true);
      verify(mockDocumentRef.get()).called(1);
    });

    test('returns false when user document does not exist', () async {
      when(mockDocumentSnapshot.exists).thenReturn(false);

      final result = await datasource.accountExists(mockUser);

      expect(result, false);
      verify(mockDocumentRef.get()).called(1);
    });
  });

}
