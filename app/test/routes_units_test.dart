import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:app/data/datasources/routes_datasource.dart';

import 'mocks.mocks.dart';

void main() {
  late FirebaseRoutesDatasource datasource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc1;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc2;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockCollectionReference<Map<String, dynamic>> mockDoneRoutesCollection;
  late MockCollectionReference<Map<String, dynamic>> mockStartedRoutesCollection;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDock3;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockDoneRoutesCollection = MockCollectionReference<Map<String, dynamic>>();
    mockStartedRoutesCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDock3 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    datasource = FirebaseRoutesDatasource(mockFirestore);

    when(mockFirestore.collection('routes')).thenReturn(mockCollection);   
  });
  group('FirebaseRoutesDatasource.getAllRoutesData', () {
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

  group('FirebaseRoutesDatasource.getDoneRoutes', () {

    setUp(() {
      when(mockFirestore.collection('doneRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo'))).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

      when(mockDoc1.data()).thenReturn({'routeId': 'route_1'});
      when(mockDoc2.data()).thenReturn({'routeId': 'route_2'});
    });

    test('returns list of done routes for given user', () async {
      final userId = 'user123';

      final result = await datasource.getDoneRoutes(userId);

      expect(result, ['route_1', 'route_2']);

      // Verify methods were called as expected (optional)
      verify(mockFirestore.collection('doneRoutes')).called(1);
      verify(mockCollection.where('userId', isEqualTo: userId)).called(1);
      verify(mockQuery.get()).called(1);
    });

    test('returns empty list on firestore error', () async {
      final userId = 'userError';

      when(mockQuery.get()).thenThrow(Exception('Firestore failure'));

      final result = await datasource.getDoneRoutes(userId);

      expect(result, isEmpty);
    });
  });

  group('FirebaseRoutesDatasource.addDoneRoute', () {
    test('adds route if not already done', () async {
      when(mockFirestore.collection('doneRoutes'))
          .thenReturn(mockDoneRoutesCollection);

      when(mockDoneRoutesCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(mockDoneRoutesCollection.add(any))
          .thenAnswer((_) async => MockDocumentReference<Map<String, dynamic>>());

      await datasource.addDoneRoute('user1', 'route1', Duration(minutes: 5));

      verify(mockDoneRoutesCollection.add({
        'userId': 'user1',
        'routeId': 'route1',
        'duration': 300, // 5 * 60 seconds
      })).called(1);
    });

    test('does not add if route already done', () async {
      when(mockFirestore.collection('doneRoutes'))
          .thenReturn(mockDoneRoutesCollection);

      when(mockDoneRoutesCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      
      // Simulate existing doc
      when(mockQuerySnapshot.docs).thenReturn([MockQueryDocumentSnapshot<Map<String, dynamic>>()]);

      await datasource.addDoneRoute('user1', 'route1', Duration(minutes: 5));

      // Add should NOT be called if already exists
      verifyNever(mockDoneRoutesCollection.add(any));
    });
  });

  group('FirebaseRoutesDatasource.addStartedRoute', () {
    test('adds route if not already started', () async {
      when(mockFirestore.collection('startedRoutes'))
          .thenReturn(mockStartedRoutesCollection);

      when(mockStartedRoutesCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(mockStartedRoutesCollection.add(any))
          .thenAnswer((_) async => MockDocumentReference<Map<String, dynamic>>());

      await datasource.addStardtedRoute('user1', 'route1');

      verify(mockStartedRoutesCollection.add({
        'userId': 'user1',
        'routeId': 'route1',
        'duration': 0,
      })).called(1);
    });

    test('does not add if route already started', () async {
      when(mockFirestore.collection('startedRoutes'))
          .thenReturn(mockStartedRoutesCollection);

      when(mockStartedRoutesCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      
      // Simulate existing doc
      when(mockQuerySnapshot.docs).thenReturn([MockQueryDocumentSnapshot<Map<String, dynamic>>()]);

      await datasource.addStardtedRoute('user1', 'route1');

      verifyNever(mockStartedRoutesCollection.add(any));
    });
  });

  group('FirebaseRoutesDatasource.isRouteStarted', () {
    test('returns true when route is started', () async {
      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDock3]);

      final result = await datasource.isRouteStarted('user1', 'route1');

      expect(result, isTrue);
    });

    test('returns false when no route is started', () async {
      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      final result = await datasource.isRouteStarted('user1', 'route1');

      expect(result, isFalse);
    });
  });

  group('FirebaseRoutesDatasource.deleteStartedRoute', () {
    test('deletes existing started route', () async {
      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDock3]);
      when(mockDock3.reference).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) async {});

      await datasource.deleteStartedRoute('user1', 'route1');

      verify(mockDocRef.delete()).called(1);
    });

    test('does nothing if no started route found', () async {
      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      await datasource.deleteStartedRoute('user1', 'route1');

      verifyNever(mockDocRef.delete());
    });
  });

  group('FirebaseRoutesDatasource.isRouteFinished', () {
    test('returns true when route is finished', () async {
      when(mockFirestore.collection('doneRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDock3]);

      final result = await datasource.isRouteFinished('user1', 'route1');

      expect(result, isTrue);
    });

    test('returns false when route is not finished', () async {
      when(mockFirestore.collection('doneRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      final result = await datasource.isRouteFinished('user1', 'route1');

      expect(result, isFalse);
    });
  });

  group('FirebaseRoutesDatasource.getStartedRouteDuration', () {
    test('returns duration when found', () async {
      final mockData = {'duration': 120};

      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDock3]);
      when(mockDock3.data()).thenReturn(mockData);

      final result = await datasource.getStartedRouteDuration('user1', 'route1');

      expect(result, Duration(seconds: 120));
    });

    test('returns null when no document found', () async {
      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      final result = await datasource.getStartedRouteDuration('user1', 'route1');

      expect(result, isNull);
    });
  });

  group('FirebaseRoutesDatasource.updateStartedRouteDuration', () {

    test('updates duration when document exists', () async {
      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDock3]);
      when(mockDock3.reference).thenReturn(mockDocRef);

      await datasource.updateStartedRouteDuration('user1', 'route1', Duration(seconds: 300));

      verify(mockDocRef.update({'duration': 300})).called(1);
    });

    test('does nothing when no document exists', () async {
      when(mockFirestore.collection('startedRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      await datasource.updateStartedRouteDuration('user1', 'route1', Duration(seconds: 300));

      verifyNever(mockDocRef.update(any));
    });
  });

  group('FirebaseRoutesDatasource.getRouteDuration', () {
    late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

    setUp(() {
      mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    });

    test('returns duration when found', () async {
      final mockData = {'duration': 180};

      when(mockFirestore.collection('doneRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.data()).thenReturn(mockData);

      final result = await datasource.getRouteDuration('user1', 'route1');

      expect(result, Duration(seconds: 180));
    });

    test('returns null when no document found', () async {
      when(mockFirestore.collection('doneRoutes')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.where('routeId', isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.docs).thenReturn([]);

      final result = await datasource.getRouteDuration('user1', 'route1');

      expect(result, isNull);
    });
  });

}
