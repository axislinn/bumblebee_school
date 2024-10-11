abstract class SchoolEvent {}

class RegisterSchool extends SchoolEvent {
  final String schoolName;
  final String address;
  final String phone;
  final String email;
  final String? website;
  final String? logoUrl;
  final DateTime? establishedDate;
  final List<String>? departments;

  RegisterSchool({
    required this.schoolName,
    required this.address,
    required this.phone,
    required this.email,
    this.website,
    this.logoUrl,
    this.establishedDate,
    this.departments,
  });
}
