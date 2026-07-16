class StartupModel {
  final String id;
  final String name;
  final String description;
  final String industry;
  final String founderUid;
  final String contactEmail;
  final bool isVerified;
  final DateTime? createdAt;

  StartupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.founderUid,
    this.contactEmail = '',
    this.isVerified = false,
    this.createdAt,
  });

  factory StartupModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StartupModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      industry: data['industry'] ?? '',
      founderUid: data['founderUid'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'industry': industry,
      'founderUid': founderUid,
      'contactEmail': contactEmail,
      'isVerified': isVerified,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }
}
