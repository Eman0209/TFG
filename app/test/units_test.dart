import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/data/datasources/user_datasource.dart';
import 'package:app/data/datasources/routes_datasource.dart';

import 'mocks.mocks.dart';

void main() {

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

  group('FirebaseUserDatasource.createUser', () {
    late FirebaseUserDatasource datasource;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockUser mockUser;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
    late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUser = MockUser();
      mockCollectionRef = MockCollectionReference();
      mockDocumentRef = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();

      datasource = FirebaseUserDatasource(
        auth: mockAuth,
        firestore: mockFirestore,
        googleSignIn: mockGoogleSignIn,
      );

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
    late FirebaseUserDatasource datasource;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockUser mockUser;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
    late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      mockUser = MockUser();
      mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      datasource = FirebaseUserDatasource(auth: mockAuth, firestore: mockFirestore, googleSignIn: mockGoogleSignIn);

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
    late FirebaseUserDatasource authService;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleUser;
    late MockGoogleSignInAuthentication mockGoogleAuth;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleUser = MockGoogleSignInAccount();
      mockGoogleAuth = MockGoogleSignInAuthentication();
      mockUserCredential = MockUserCredential();

      authService = FirebaseUserDatasource(
        auth: mockAuth,
        firestore: mockFirestore,
        googleSignIn: mockGoogleSignIn,
      );
    });

    test('returns UserCredential on successful sign in', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleAuth.accessToken).thenReturn('access-token');
      when(mockGoogleAuth.idToken).thenReturn('id-token');
      when(mockAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);

      final result = await authService.signInWithGoogle();

      expect(result, mockUserCredential);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAuth.signInWithCredential(any)).called(1);
    });

    test('returns null if user cancels sign in', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await authService.signInWithGoogle();

      expect(result, null);
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAuth.signInWithCredential(any));
    });

    test('logs and returns null on exception', () async {
      when(mockGoogleSignIn.signIn()).thenThrow(Exception('Failed to sign in'));

      final result = await authService.signInWithGoogle();

      expect(result, null);
    });

  });

  group('FirebaseUserDatasource.accountExists', () {
    late FirebaseUserDatasource datasource;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
    late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
      mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      datasource = FirebaseUserDatasource(
        auth: MockFirebaseAuth(), 
        firestore: mockFirestore,
        googleSignIn: MockGoogleSignIn(), 
      );

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

  group('FirebaseRoutesDatasource.getAllRoutesData', () {
    late FirebaseRoutesDatasource datasource;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc1;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc2;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      datasource = FirebaseRoutesDatasource(mockFirestore);

      when(mockFirestore.collection('routes')).thenReturn(mockCollection);
    });

    test('returns list of RouteData on success', () async {
      final data1 = {
        'name': 'Route 1',
        'category': 'Category 1',
        'description': 'Desc 1',
        'time': 90,
        'path': ['pointA', 'pointB'],
        'mysteryId': 'mystery1'
      };
      final data2 = {
        'name': 'Route 2',
        'category': 'Category 2',
        'description': 'Desc 2',
        'time': 90,
        'path': ['pointC', 'pointD'],
        'mysteryId': 'mystery2'
      };

      when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

      when(mockDoc1.data()).thenReturn(data1);
      when(mockDoc1.id).thenReturn('doc1');

      when(mockDoc2.data()).thenReturn(data2);
      when(mockDoc2.id).thenReturn('doc2');

      final results = await datasource.getAllRoutesData('en');

      expect(results.length, 2);
      expect(results[0]?.name, data1['name']);
      expect(results[1]?.name, data2['name']);
    });

    test('returns empty list and logs on failure', () async {
      when(mockCollection.get()).thenThrow(Exception('Firestore failure'));

      final results = await datasource.getAllRoutesData('en');

      expect(results, isEmpty);
      // Optionally verify logger called (requires mocking Logger)
    });
  });

  group('FirebaseRoutesDatasource.getRouteData', () {
    late FirebaseRoutesDatasource datasource;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      datasource = FirebaseRoutesDatasource(mockFirestore);
    });

    test('returns RouteData when document exists', () async {
      final routeId = 'route123';
      final language = 'en';
      final data = {
        'name': 'Route Name',
        'category': 'Category A',
        'description': 'A nice route',
        'time': 60,
        'path': ['point1', 'point2'],
        'mysteryId': 'mystery123',
      };

      when(mockFirestore.collection('routes')).thenReturn(mockCollection);
      when(mockCollection.doc(routeId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(data);
      when(mockDocSnapshot.id).thenReturn(routeId);

      final result = await datasource.getRouteData(routeId, language);

      expect(result, isNotNull);
      expect(result?.id, routeId);
      expect(result?.name, data['name']);
    });

    test('returns null when document does not exist', () async {
      final routeId = 'missingRoute';
      final language = 'en';

      when(mockFirestore.collection('routes')).thenReturn(mockCollection);
      when(mockCollection.doc(routeId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      final result = await datasource.getRouteData(routeId, language);

      expect(result, isNull);
    });

    test('returns null on firestore error', () async {
      final routeId = 'routeError';
      final language = 'en';

      when(mockFirestore.collection('routes')).thenReturn(mockCollection);
      when(mockCollection.doc(routeId)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenThrow(Exception('Firestore failure'));

      final result = await datasource.getRouteData(routeId, language);

      expect(result, isNull);
    });
  });



}
