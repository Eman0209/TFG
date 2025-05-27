import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:app/data/datasources/rewards_datasource.dart';

import 'mocks.mocks.dart';

void main() {
  late FirebaseRewardsDatasource datasource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc1;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc2;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    datasource = FirebaseRewardsDatasource(mockFirestore);
  });

  group('FirebaseRewardsDatasource.getTrophies', () {
    test('returns list of trophies with translated fields', () async {
      when(mockFirestore.collection('trophy')).thenReturn(mockCollection);
      when(mockCollection.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

      when(mockDoc1.id).thenReturn('trophy1');
      when(mockDoc1.data()).thenReturn({
        'name_en': 'Explorer',
        'description_en': 'Explore things',
        'image': 'explorer.png',
      });

      when(mockDoc2.id).thenReturn('trophy2');
      when(mockDoc2.data()).thenReturn({
        'name': 'Champion',
        'description': 'Route master',
        'image': 'champion.png',
      });

      final result = await datasource.getTrophies('en');

      expect(result.length, 2);
      expect(result[0]['name'], 'Explorer');
      expect(result[1]['name'], 'Champion');
    });

    test('returns empty list on error', () async {
      when(mockFirestore.collection('trophy')).thenThrow(Exception('Firestore error'));

      final result = await datasource.getTrophies('en');

      expect(result, isEmpty);
    });

  });

  group('FirebaseRewardsDatasource.getMyOwnTrophies', () {
    test('getMyOwnTrophies returns list of trophy IDs for user', () async {
      const userId = 'user123';

      when(mockFirestore.collection('myOwnTrophies')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockDoc1.data()).thenReturn({'trophyId': 'trophy1'});
      when(mockDoc2.data()).thenReturn({'trophyId': 'trophy2'});
      when(mockDoc1['trophyId']).thenReturn('trophy1');
      when(mockDoc2['trophyId']).thenReturn('trophy2');

      final trophies = await datasource.getMyOwnTrophies(userId);

      expect(trophies, equals(['trophy1', 'trophy2']));
    });

    test('getMyOwnTrophies returns empty list on Firestore error', () async {
      const userId = 'user123';

      when(mockFirestore.collection('myOwnTrophies')).thenThrow(Exception('Firestore failure'));

      final trophies = await datasource.getMyOwnTrophies(userId);

      expect(trophies, isEmpty);
    });
  });

  group('FirebaseRewardsDatasource.addUserTrophy', () {
    test('addUserTrophy adds trophy if not already present', () async {
      const userId = 'user123';
      const trophyId = 'trophy456';

      when(mockFirestore.collection('myOwnTrophies')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery);
      when(mockQuery.where('trophyId', isEqualTo: trophyId)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(mockCollection.add({
        'userId': userId,
        'trophyId': trophyId,
      })).thenAnswer((_) async => MockDocumentReference());

      await datasource.addUserTrophy(userId, trophyId);

      verify(mockCollection.add({
        'userId': userId,
        'trophyId': trophyId,
      })).called(1);
    });

    test('addUserTrophy does not add trophy if already exists', () async {
      const userId = 'user123';
      const trophyId = 'trophy456';

      when(mockFirestore.collection('myOwnTrophies')).thenReturn(mockCollection);
      when(mockCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery);
      when(mockQuery.where('trophyId', isEqualTo: trophyId)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1]);

      await datasource.addUserTrophy(userId, trophyId);

      verifyNever(mockCollection.add(any));
    });

    test('addUserTrophy handles Firestore error gracefully', () async {
      const userId = 'user123';
      const trophyId = 'trophy456';

      when(mockFirestore.collection('myOwnTrophies')).thenThrow(Exception('Firestore failure'));

      await datasource.addUserTrophy(userId, trophyId);

      verifyNever(mockCollection.add(any)); // Since collection call itself failed
    });
  });
  
}
