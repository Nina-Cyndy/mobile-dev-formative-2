import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String studentUid;
  final String studentName;
  final String status; // pending | accepted | rejected
  final DateTime appliedAt;

  ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.studentUid,
    required this.studentName,
    required this.status,
    required this.appliedAt,
    this.opportunityTitle = '',
    this.startupId = '',
  });

  factory ApplicationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ApplicationModel(
      id: id,
      opportunityId: data['opportunityId'] ?? '',
      opportunityTitle: data['opportunityTitle'] ?? '',
      startupId: data['startupId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      studentName: data['studentName'] ?? '',
      status: data['status'] ?? 'pending',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'opportunityId': opportunityId,
    'opportunityTitle': opportunityTitle,
    'startupId': startupId,
    'studentUid': studentUid,
    'studentName': studentName,
    'status': status,
    'appliedAt': appliedAt,
  };
}
