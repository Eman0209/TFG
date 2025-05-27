import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:app/data/datasources/routes_datasource.dart';

import 'mocks.mocks.dart';

void main() {
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

  group('FirebaseRoutesDatasource.getDoneRoutes', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockQuery<Map<String, dynamic>> mockQuery;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc1;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc2;

    late FirebaseRoutesDatasource datasource;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockQuery = MockQuery<Map<String, dynamic>>();
      mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      datasource = FirebaseRoutesDatasource(mockFirestore);
      
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


  
}
