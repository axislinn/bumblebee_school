part of 'teacher_requests_bloc.dart';

abstract class TeacherRequestState {}

class TeacherRequestInitial extends TeacherRequestState {}

class TeacherRequestLoading extends TeacherRequestState {}

class TeacherRequestLoaded extends TeacherRequestState {
  final List<TeacherRequestModel> teacherRequests;

  TeacherRequestLoaded(this.teacherRequests);
}

class TeacherRequestError extends TeacherRequestState {
  final String message;

  TeacherRequestError(this.message);
}

class TeacherRequestProcessed extends TeacherRequestState {
  final String message;

  TeacherRequestProcessed(this.message);
}

class CurrentTeachersLoaded extends TeacherRequestState {
  final List<String> teachers;

  CurrentTeachersLoaded(this.teachers);
}

class CurrentTeachersError extends TeacherRequestState {
  final String message;

  CurrentTeachersError(this.message);
}
