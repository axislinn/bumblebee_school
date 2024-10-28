part of 'teacher_requests_bloc.dart';

abstract class TeacherRequestEvent {}

class FetchTeacherRequests extends TeacherRequestEvent {
  final String classId;

  FetchTeacherRequests(this.classId);

  List<Object?> get props => [classId];
}

class AcceptTeacherRequest extends TeacherRequestEvent {
  final String requestId;
  final String classId;

  AcceptTeacherRequest(this.requestId, this.classId);
}

class RejectTeacherRequest extends TeacherRequestEvent {
  final String requestId;
  final String classId;

  RejectTeacherRequest(this.requestId, this.classId);
}

class FetchCurrentTeachers extends TeacherRequestEvent {
  final String classId;

  FetchCurrentTeachers(this.classId);

  List<Object?> get props => [classId];
}
