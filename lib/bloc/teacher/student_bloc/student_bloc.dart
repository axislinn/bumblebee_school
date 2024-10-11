import 'package:bloc/bloc.dart';
import 'package:bumblebee_school_final/model/admin+teacher/user_model.dart';
import 'package:bumblebee_school_final/model/admin+teacher/class_model.dart';
import 'package:bumblebee_school_final/model/teacher/student_model.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/class_repository.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/user_repository.dart';
import 'package:bumblebee_school_final/repositories/teacher/teacher_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final ClassRepository classRepository;
  final UserRepository userRepository;
  final TeacherRepository teacherRepository;

  StudentBloc(this.classRepository, this.userRepository, this.teacherRepository) : super(StudentInitial()) {

    on<FetchClassesEvent>(_onFetchClasses);
    on<RequestToJoinClassEvent>(_onRequestToJoinClass);
    on<FetchStudentsEvent>(_onFetchStudents);
    on<AddStudentEvent>(_onAddStudent);
    on<FetchUserEvent>(_onFetchUser);
    on<FetchGuardiansEvent>(_onFetchGuardians);
    on<FetchPendingRequestsEvent>(_onFetchPendingRequests); 
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  void _onFetchClasses(FetchClassesEvent event, Emitter<StudentState> emit) async {

    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

  print('Loading classes...');
  emit(ClassLoading());
  try {
    final classes = await classRepository.fetchClasses(token);
    print('Classes loaded: ${classes.length}');
    emit(ClassLoaded(classes));
  } catch (e) {
    print('Error loading classes: $e');
    emit(ClassError(e.toString()));
  }
}

  void _onRequestToJoinClass(RequestToJoinClassEvent event, Emitter<StudentState> emit) async {
    try {
      final token = await _getToken();

      if (token != null) {
        await teacherRepository.requestToJoinClass(token, event.classCode);
        emit(JoinClassSuccessState());
      } else {
        emit(JoinClassErrorState("Token not found"));
      }
    } catch (e) {
      emit(JoinClassErrorState(e.toString()));
    }
  }

    void _onFetchStudents(FetchStudentsEvent event, Emitter<StudentState> emit) async {
    emit(StudentsLoadingState());
    try {
      final token = await _getToken();

      if (token != null) {
        final students = await teacherRepository.getStudentsByClassId(token, event.classId);
        emit(StudentsLoadedState(students));
      } else {
        emit(StudentsErrorState("Token not found"));
      }
    } catch (e) {
      emit(StudentsErrorState(e.toString()));
    }
  }

  void _onAddStudent(AddStudentEvent event, Emitter<StudentState> emit) async {

    try {
      final token = await _getToken();

      if (token != null) {
        await teacherRepository.addStudentToClass(token, event.classId, event.studentName, event.dob);
        emit(AddStudentSuccessState());
      } else {
        emit(AddStudentErrorState("Token not found"));
      }
    } catch (e) {
      emit(AddStudentErrorState('Error adding student: $e'));
    }
  }


void _onFetchUser(FetchUserEvent event, Emitter<StudentState> emit) async {
  emit(UserLoadingState());
  try {
    final user = await userRepository.getUserById(event.userId);  // Use the instance
    emit(UserLoadedState(user));
  } catch (e) {
    emit(UserErrorState(e.toString()));
  }
}


void _onFetchGuardians(FetchGuardiansEvent event, Emitter<StudentState> emit) async {
  emit(GuardiansLoadingState());
  List<UserModel> guardiansList = [];

  if (event.guardianIds.isEmpty) {
    emit(GuardiansLoadedState(guardiansList));
    return;  
  }

  for (String guardianId in event.guardianIds) {
    try {
      UserModel guardian = await userRepository.getUserById(guardianId);  
      guardiansList.add(guardian);
      emit(GuardiansLoadedState(guardiansList));
    } catch (e) {
      print('Failed to fetch guardian with ID $guardianId: $e');
      emit(GuardiansErrorState('Failed to load some guardians.'));
    }
  }
}


  void _onFetchPendingRequests(FetchPendingRequestsEvent event, Emitter<StudentState> emit) async {
   print("Fetching pending requests for classId: ${event.classId}, studentId: ${event.studentId}");
   emit(PendingRequestsLoadingState()); 
   try {
     final token = await _getToken();
     print("got token $token");
     if (token != null) {
        print("token not null");
       final pendingRequests = await teacherRepository.getPendingGuardianRequests(token, event.classId, event.studentId);
       print("Fetched pending requests: $pendingRequests");
       emit(PendingRequestsLoadedState(pendingRequests));
     } else {
       emit(PendingRequestsErrorState("Token not found"));
     }
   } catch (e) {
     emit(PendingRequestsErrorState(e.toString()));
   }
  }
  

}


