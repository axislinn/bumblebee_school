class SchoolModel {
  final String id;
  final String schoolName;
  final String address;
  final String phone;
  final String email;
  final String? website;
  final String? logoUrl;
  final DateTime? establishedDate;
  final List<String>? departments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SchoolModel({
    required this.id,
    required this.schoolName,
    required this.address,
    required this.phone,
    required this.email,
    this.website,
    this.logoUrl,
    this.establishedDate,
    this.departments,
    this.createdAt,
    this.updatedAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['_id'] ?? '',
      schoolName: json['schoolName'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      logoUrl: json['logoUrl'],
      establishedDate: json['establishedDate'] != null
          ? DateTime.parse(json['establishedDate'])
          : null,
      departments: json['departments'] != null
          ? List<String>.from(json['departments'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'schoolName': schoolName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'establishedDate': establishedDate?.toIso8601String(),
      'departments': departments,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
