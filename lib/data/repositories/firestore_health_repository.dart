import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/health_entry.dart';
import 'health_repository.dart';

class FirestoreHealthRepository implements HealthRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'health_entries';

  FirestoreHealthRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<HealthEntry>> watchEntries({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HealthEntry.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> addEntry(HealthEntry entry) async {
    await _firestore.collection(_collection).add(entry.toFirestore());
  }

  @override
  Future<void> deleteEntry(String id) {
    return _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<void> updateEntry(HealthEntry entry) {
    if (entry.id == null) {
      throw ArgumentError('Entry ID cannot be null for an update');
    }
    return _firestore
        .collection(_collection)
        .doc(entry.id!)
        .update(entry.toFirestore());
  }

  @override
  Future<List<HealthEntry>> getEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => HealthEntry.fromFirestore(doc))
        .toList();
  }
}
