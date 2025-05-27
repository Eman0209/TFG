import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:app/data/datasources/mystery_datasource.dart';

import '../mocks.mocks.dart';

void main() {
  late FirebaseMysteryDatasource datasource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late MockCollectionReference<Map<String, dynamic>> mockSubCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc;
  late MockCollectionReference<Map<String, dynamic>> mockDoneStepsCollection;
  late MockQuerySnapshot<Map<String, dynamic>> mockDoneStepsSnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoneStepsDoc;
  late MockDocumentReference<Map<String, dynamic>> mockMysteryDocRef;
  late MockCollectionReference<Map<String, dynamic>> mockStepCollection;
  late MockDocumentSnapshot<Map<String, dynamic>> mockStepSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
    mockSubCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDoneStepsCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDoneStepsSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDoneStepsDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockMysteryDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockStepCollection = MockCollectionReference<Map<String, dynamic>>();
    mockStepSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    datasource = FirebaseMysteryDatasource(mockFirestore);
  });

  group('FirebaseMysteryDatasource.getStepInfo', () {
    test('returns StepData when step exists', () async {
      const mysteryId = 'mystery123';
      const order = 1;
      const step = 'clues';
      final stepMap = {
        'order': 2,
        'title': 'Clue Title',
        'narration': 'Clue Narration',
        'resum': 'Clue Resum',
        'instructions': 'Clue Instructions',
      };

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.collection(step)).thenReturn(mockSubCollection);
      when(mockSubCollection.where('order', isEqualTo: order + 1)).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
      when(mockDoc.data()).thenReturn(stepMap);

      final result = await datasource.getStepInfo(mysteryId, order, step);

      expect(result, isNotNull);
      expect(result!.order, equals(2));
      expect(result.title, equals('Clue Title'));
      expect(result.narration, equals('Clue Narration'));
      expect(result.resum, equals('Clue Resum'));
      expect(result.instructions, equals('Clue Instructions'));
    });

    test('returns null when no step found', () async {
      const mysteryId = 'mystery123';
      const order = 1;
      const step = 'clues';

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.collection(step)).thenReturn(mockSubCollection);
      when(mockSubCollection.where('order', isEqualTo: order + 1)).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      final result = await datasource.getStepInfo(mysteryId, order, step);

      expect(result, isNull);
    });

    test('returns null on Firestore error', () async {
      const mysteryId = 'mystery123';
      const order = 1;
      const step = 'clues';

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenThrow(Exception('Firestore error'));

      final result = await datasource.getStepInfo(mysteryId, order, step);

      expect(result, isNull);
    });
  });

  group('FirebaseMysteryDatasource.getCompletedSteps', () {
    test('returns sorted StepData list when completed steps are found', () async {
      const userId = 'user123';
      const mysteryId = 'mystery123';
      const step = 'clues';
      final completedIds = ['step1', 'step2'];

      final doneStepData = {
        step: completedIds,
      };    

      when(mockFirestore.collection('doneSteps')).thenReturn(mockDoneStepsCollection);
      when(mockDoneStepsCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockDoneStepsSnapshot);
      when(mockDoneStepsSnapshot.docs).thenReturn([mockDoneStepsDoc]);
      when(mockDoneStepsDoc.data()).thenReturn(doneStepData);

      when(mockFirestore.collection('mystery')).thenReturn(mockDoneStepsCollection); 
      when(mockDoneStepsCollection.doc(mysteryId)).thenReturn(mockMysteryDocRef);
      when(mockMysteryDocRef.collection(step)).thenReturn(mockStepCollection);

      final mockStep1DocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockStep2DocRef = MockDocumentReference<Map<String, dynamic>>();

      final mockStep1Snapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockStep2Snapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockStepCollection.doc('step1')).thenReturn(mockStep1DocRef);
      when(mockStep1DocRef.get()).thenAnswer((_) async {
        when(mockStep1Snapshot.exists).thenReturn(true);
        when(mockStep1Snapshot.data()).thenReturn({
          'order': 2,
          'title': 'Title 2',
          'narration': 'Narration 2',
          'resum': 'Resum 2',
          'instructions': 'Instructions 2',
        });
        return mockStep1Snapshot;
      });

      when(mockStepCollection.doc('step2')).thenReturn(mockStep2DocRef);
      when(mockStep2DocRef.get()).thenAnswer((_) async {
        when(mockStep2Snapshot.exists).thenReturn(true);
        when(mockStep2Snapshot.data()).thenReturn({
          'order': 1,
          'title': 'Title 1',
          'narration': 'Narration 1',
          'resum': 'Resum 1',
          'instructions': 'Instructions 1',
        });
        return mockStep2Snapshot;
      });

      final result = await datasource.getCompletedSteps(userId, mysteryId, step);

      expect(result.length, 2);
      expect(result[0].order, equals(1));
      expect(result[1].order, equals(2));
    });

    test('returns empty list when no document found', () async {
      const userId = 'user123';
      const mysteryId = 'mystery123';
      const step = 'clues';

      when(mockFirestore.collection('doneSteps')).thenReturn(mockDoneStepsCollection);
      when(mockDoneStepsCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockDoneStepsSnapshot);
      when(mockDoneStepsSnapshot.docs).thenReturn([]);

      final result = await datasource.getCompletedSteps(userId, mysteryId, step);

      expect(result, isEmpty);
    });

    test('returns empty list on Firestore exception', () async {
      const userId = 'user123';
      const mysteryId = 'mystery123';
      const step = 'clues';

      when(mockFirestore.collection('doneSteps')).thenThrow(Exception('Firestore error'));

      final result = await datasource.getCompletedSteps(userId, mysteryId, step);

      expect(result, isEmpty);
    });

  });

  group('FirebaseMysteryDatasource.getIntroduction', () {
    test('returns localized introduction when available', () async {
      const mysteryId = 'mystery1';
      const language = 'en';
      final data = {'introduction_en': 'Welcome to the mystery!'};

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockStepSnapshot);
      when(mockStepSnapshot.exists).thenReturn(true);
      when(mockStepSnapshot.data()).thenReturn(data);

      final result = await datasource.getIntroduction(mysteryId, language);

      expect(result, equals('Welcome to the mystery!'));
    });

    test('falls back to default introduction when localized is missing', () async {
      const mysteryId = 'mystery1';
      const language = 'fr';
      final data = {'introduction': 'Default intro'};

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockStepSnapshot);
      when(mockStepSnapshot.exists).thenReturn(true);
      when(mockStepSnapshot.data()).thenReturn(data);

      final result = await datasource.getIntroduction(mysteryId, language);

      expect(result, equals('Default intro'));
    });

    test('returns null when document does not exist', () async {
      const mysteryId = 'missingMystery';
      const language = 'en';

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.get()).thenAnswer((_) async => mockStepSnapshot);
      when(mockStepSnapshot.exists).thenReturn(false);

      final result = await datasource.getIntroduction(mysteryId, language);

      expect(result, isNull);
    });
  });

  group('FirebaseMysteryDatasource.getStepsLength', () {
    test('returns step count when steps exist', () async {
      const mysteryId = 'mystery1';

      final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.collection('steps')).thenReturn(mockStepCollection);
      when(mockStepCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]); // <- 2 mock docs
      when(mockQuerySnapshot.size).thenReturn(2); // Optional, some versions use this

      final result = await datasource.getStepsLength(mysteryId);

      expect(result, equals(2));
    });

    test('returns 0 when no steps exist', () async {
      const mysteryId = 'mystery1';

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.collection('steps')).thenReturn(mockStepCollection);
      when(mockStepCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      final result = await datasource.getStepsLength(mysteryId);

      expect(result, equals(0));
    });

    test('returns 0 on Firestore exception', () async {
      const mysteryId = 'mystery1';

      when(mockFirestore.collection('mystery')).thenReturn(mockCollection);
      when(mockCollection.doc(mysteryId)).thenReturn(mockDocumentRef);
      when(mockDocumentRef.collection('steps')).thenThrow(Exception('Firestore error'));

      final result = await datasource.getStepsLength(mysteryId);

      expect(result, equals(0));
    });
  });

}