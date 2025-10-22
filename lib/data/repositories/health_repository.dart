import '../../models/health_entry.dart';

abstract class HealthRepository {
  Stream<List<HealthEntry>> watchEntries({int limit = 10});

  Future<void> addEntry(HealthEntry entry);

  Future<void> deleteEntry(String id);

  Future<void> updateEntry(HealthEntry entry);

  Future<List<HealthEntry>> getEntriesInRange(DateTime start, DateTime end);
}
