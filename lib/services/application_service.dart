import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitApplication(ApplicationModel app) async {
    await _firestore.collection('applications').add(app.toMap());
  }

  Stream<QuerySnapshot> getStudentApplications(String studentUid) {
    return _firestore
        .collection('applications')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots();
  }

  Stream<List<ApplicationModel>> watchStudentApplications(String studentUid) {
    return _firestore
        .collection('applications')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ApplicationModel.fromFirestore(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt)));
  }
}
