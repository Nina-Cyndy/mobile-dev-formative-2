import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';

/// One startup profile per founder account, keyed by founderUid so lookups
/// are O(1) instead of a filtered query.
class StartupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<StartupModel?> startupForFounder(String founderUid) {
    return _firestore.collection('startups').doc(founderUid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return StartupModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  Future<void> saveStartupProfile(StartupModel startup) async {
    await _firestore
        .collection('startups')
        .doc(startup.founderUid)
        .set(startup.toMap(), SetOptions(merge: true));
  }

  Future<StartupModel?> getStartup(String startupId) async {
    final doc = await _firestore.collection('startups').doc(startupId).get();
    if (!doc.exists || doc.data() == null) return null;
    return StartupModel.fromFirestore(doc.data()!, doc.id);
  }
}
