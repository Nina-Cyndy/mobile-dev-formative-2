class OpportunityModel {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String requirements;
  final String category;
  final String location;
  final bool isOpen;
  final DateTime createdAt;

  OpportunityModel({
    required this.id,
    required this.startupId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.createdAt,
    this.startupName = '',
    this.category = 'General',
    this.location = 'Remote',
    this.isOpen = true,
  });

  factory OpportunityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OpportunityModel(
      id: id,
      startupId: data['startupId'] ?? '',
      startupName: data['startupName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requirements: data['requirements'] ?? '',
      category: data['category'] ?? 'General',
      location: data['location'] ?? 'Remote',
      isOpen: data['isOpen'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'requirements': requirements,
      'category': category,
      'location': location,
      'isOpen': isOpen,
      'createdAt': createdAt,
    };
  }
}
