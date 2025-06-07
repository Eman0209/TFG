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
  late MockCollectionReference<Map<String, dynamic>> mockMysteryCollection;
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
    mockMysteryCollection = MockCollectionReference<Map<String, dynamic>>();
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

  group('FirebaseMysteryDatasource.addCompletedStep', () {
    test('adds completed step to Firestore when steps exist and user doc exists', () async {
      const userId = 'user123';
      const mysteryId = 'mystery123';
      const order = 1;
      const stepIdEn = 'stepEn';

      // Setup firestore.collection('doneSteps')
      when(mockFirestore.collection('doneSteps')).thenReturn(mockDoneStepsCollection);

      // Setup firestore.collection('mystery')
      when(mockFirestore.collection('mystery')).thenReturn(mockMysteryCollection);

      // Setup mystery doc ref and subcollections for steps_en, steps_es, steps
      when(mockMysteryCollection.doc(mysteryId)).thenReturn(mockMysteryDocRef);

      // When collection('steps_en') called on mystery doc
      when(mockMysteryDocRef.collection('steps_en')).thenReturn(mockSubCollection);
      when(mockMysteryDocRef.collection('steps_es')).thenReturn(mockSubCollection);
      when(mockMysteryDocRef.collection('steps')).thenReturn(mockSubCollection);

      // Setup queries for each language subcollection: where('order', isEqualTo: order+1).limit(1).get()
      when(mockSubCollection.where('order', isEqualTo: order + 1)).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);

      // Mock query.get() to return snapshot with a doc having the stepId
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Return different step IDs for each call
      int callCount = 0;
      when(mockQuerySnapshot.docs).thenAnswer((_) {
        callCount++;
        if (callCount == 1) return [mockDoc]; // steps_en
        if (callCount == 2) return [mockDoc]; // steps_es
        if (callCount == 3) return [mockDoc]; // steps_ca
        return [];
      });

      when(mockDoc.id).thenReturn(stepIdEn); // Return the same id for simplicity

      // Setup doneStepsCollection query for userId existing doc
      when(mockDoneStepsCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Mock querySnapshot.docs with one existing document
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // docRef for update is the reference of the existing doc
      when(mockDoc.reference).thenReturn(mockDocumentRef);

      // Mock update call on the docRef
      when(mockDocumentRef.update(any)).thenAnswer((_) async {});

      // Run the method
      await datasource.addCompletedStep(userId, mysteryId, order);

      // Verify update was called with correct FieldValue.arrayUnion for each language
      verify(mockDocumentRef.update(argThat(
        allOf(
          contains('steps_en'),
          contains('steps_es'),
          contains('steps'),
        ),
      ))).called(1);
    });

    test('adds completed step to Firestore when no existing user doc', () async {
      const userId = 'user123';
      const mysteryId = 'mystery123';
      const order = 1;
      const stepIdEn = 'stepEn';

      // Mocks for subcollections
      final mockQueryEn = MockQuery<Map<String, dynamic>>();
      final mockQueryEs = MockQuery<Map<String, dynamic>>();
      final mockQueryCa = MockQuery<Map<String, dynamic>>();

      final mockQuerySnapshotEn = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQuerySnapshotEs = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQuerySnapshotCa = MockQuerySnapshot<Map<String, dynamic>>();

      final mockDocEn = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('mystery')).thenReturn(mockMysteryCollection);
      when(mockMysteryCollection.doc(mysteryId)).thenReturn(mockMysteryDocRef);

      // steps_en subcollection returns a doc
      when(mockMysteryDocRef.collection('steps_en')).thenReturn(mockSubCollection);
      when(mockSubCollection.where('order', isEqualTo: order + 1)).thenReturn(mockQueryEn);
      when(mockQueryEn.limit(1)).thenReturn(mockQueryEn);
      when(mockQueryEn.get()).thenAnswer((_) async => mockQuerySnapshotEn);
      when(mockQuerySnapshotEn.docs).thenReturn([mockDocEn]);
      when(mockDocEn.id).thenReturn(stepIdEn);

      // steps_es subcollection returns empty
      when(mockMysteryDocRef.collection('steps_es')).thenReturn(mockSubCollection);
      when(mockSubCollection.where('order', isEqualTo: order + 1)).thenReturn(mockQueryEs);
      when(mockQueryEs.limit(1)).thenReturn(mockQueryEs);
      when(mockQueryEs.get()).thenAnswer((_) async => mockQuerySnapshotEs);
      when(mockQuerySnapshotEs.docs).thenReturn([]);

      // steps (Catalan) subcollection returns empty
      when(mockMysteryDocRef.collection('steps')).thenReturn(mockSubCollection);
      when(mockSubCollection.where('order', isEqualTo: order + 1)).thenReturn(mockQueryCa);
      when(mockQueryCa.limit(1)).thenReturn(mockQueryCa);
      when(mockQueryCa.get()).thenAnswer((_) async => mockQuerySnapshotCa);
      when(mockQuerySnapshotCa.docs).thenReturn([]);

      // doneStepsCollection mocks
      when(mockFirestore.collection('doneSteps')).thenReturn(mockDoneStepsCollection);
      when(mockDoneStepsCollection.where('userId', isEqualTo: userId)).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]); 

      when(mockDoneStepsCollection.add({
        'userId': userId,
        'steps_en': [],
        'steps_es': [],
        'steps_ca': [],
      })).thenAnswer((_) async => mockDocumentRef);

      when(mockDocumentRef.update(any)).thenAnswer((_) async {});

      // Run the function
      await datasource.addCompletedStep(userId, mysteryId, order);

      // Verify add() and update() calls
      verifyNever(mockDoneStepsCollection.add({
        'userId': userId,
        'steps_en': [],
        'steps_es': [],
        'steps_ca': [],
      }));

      verifyNever(mockDocumentRef.update(argThat(contains('steps_en'))));
    });
  });

}