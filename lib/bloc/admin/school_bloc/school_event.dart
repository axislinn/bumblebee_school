abstract class SchoolEvent {}

class RegisterSchool extends SchoolEvent {
  final String schoolName;
  final String address;
  final String phone;
  final String email;
  final String id;

  RegisterSchool({
    required this.id,
    required this.schoolName,
    required this.address,
    required this.phone,
    required this.email,
  });
}
