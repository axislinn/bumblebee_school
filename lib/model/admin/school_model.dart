class SchoolModel {
  final String id;
  final String schoolName;
  final String address;
  final String phone;
  final String email;

  SchoolModel({
    required this.id,
    required this.schoolName,
    required this.address,
    required this.phone,
    required this.email,
  });

  // a factory method to create a School object from a JSON map.
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['_id'] ?? '',
      schoolName: json['schoolName'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  // convert a School object to a JSON map.
  Map<String, dynamic> toJson({bool includeId = true}) {
    final Map<String, dynamic> data = {
      'schoolName': schoolName,
      'address': address,
      'phone': phone,
      'email': email,
    };
    if (includeId && id.isNotEmpty) {
      data['_id'] = id;
    }
    return data;
  }
}
