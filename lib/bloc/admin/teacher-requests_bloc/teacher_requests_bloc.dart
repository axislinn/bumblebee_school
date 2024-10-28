import 'package:bloc/bloc.dart';
import 'package:bumblebee_school_final/model/admin/teacher_requests_model.dart';
import 'package:bumblebee_school_final/repositories/admin/teacher_requests_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'teacher_requests_event.dart';
part 'teacher_requests_state.dart';

class TeacherRequestBloc extends Bloc<TeacherRequestEvent, TeacherRequestState> {
  final TeacherRequestRepository teacherRequestRepository;

  TeacherRequestBloc({required this.teacherRequestRepository}) : super(TeacherRequestInitial()) {
    on<FetchTeacherRequests>(_onFetchTeacherRequests);
    on<AcceptTeacherRequest>(_onAcceptTeacherRequest);
    on<RejectTeacherRequest>(_onRejectTeacherRequest);
    on<FetchCurrentTeachers>(_onFetchCurrentTeachers);
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> _onFetchTeacherRequests(FetchTeacherRequests event, Emitter<TeacherRequestState> emit) async {
    if (event.classId.isEmpty) {
      print('Error: Class ID cannot be empty.');
      emit(TeacherRequestError('Class ID cannot be empty.'));
      return;
    }

    emit(TeacherRequestLoading());

    final token = await _getToken();
    if (token == null) {
      print('Error: Authentication token not found');
      emit(TeacherRequestError('Authentication token not found'));
      return;
    }

    try {
      final teacherRequests = await teacherRequestRepository.fetchTeacherRequests(event.classId, token);
      emit(TeacherRequestLoaded(teacherRequests));
    } catch (error) {
      print('Failed to load teacher requests: $error');
      emit(TeacherRequestError('Failed to load teacher requests'));
    }
  }

  Future<void> _onAcceptTeacherRequest(AcceptTeacherRequest event, Emitter<TeacherRequestState> emit) async {
    if (event.classId.isEmpty) {
      print('Error: Class ID cannot be empty.');
      emit(TeacherRequestError('Class ID cannot be empty.'));
      return;
    }

    final token = await _getToken();
    if (token == null) {
      print('Error: Authentication token not found');
      emit(TeacherRequestError('Authentication token not found'));
      return;
    }

    try {
      await teacherRequestRepository.respondToRequest(event.requestId, true, event.classId, token);
      emit(TeacherRequestProcessed('Teacher request accepted successfully.'));
      add(FetchTeacherRequests(event.classId));
    } catch (error) {
      print('Failed to accept teacher request: $error');
      emit(TeacherRequestError('Failed to accept teacher request: $error'));
    }
  }

  Future<void> _onRejectTeacherRequest(RejectTeacherRequest event, Emitter<TeacherRequestState> emit) async {
    if (event.classId.isEmpty) {
      print('Error: Class ID cannot be empty.');
      emit(TeacherRequestError('Class ID cannot be empty.'));
      return;
    }

    final token = await _getToken();
    if (token == null) {
      print('Error: Authentication token not found');
      emit(TeacherRequestError('Authentication token not found'));
      return;
    }

    try {
      await teacherRequestRepository.respondToRequest(event.requestId, false, event.classId, token);
      emit(TeacherRequestProcessed('Teacher request rejected successfully.'));
      add(FetchTeacherRequests(event.classId)); // Refresh requests
    } catch (error) {
      print('Failed to reject teacher request: $error');
      emit(TeacherRequestError('Failed to reject teacher request: $error'));
    }
  }

  Future<void> _onFetchCurrentTeachers(FetchCurrentTeachers event, Emitter<TeacherRequestState> emit) async {
    emit(TeacherRequestLoading());

    final token = await _getToken();
    if (token == null) {
      print('Error: Authentication token not found');
      emit(CurrentTeachersError('Authentication token not found'));
      return;
    }

    try {
      final teachers = await teacherRequestRepository.fetchCurrentTeachers(event.classId, token);
      emit(CurrentTeachersLoaded(teachers));
    } catch (error) {
      print('Failed to load current teachers: $error');
      emit(CurrentTeachersError('Failed to load current teachers: $error'));
    }
  }
}

