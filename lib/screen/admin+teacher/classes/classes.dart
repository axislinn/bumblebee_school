import 'package:bumblebee_school_final/bloc/admin/teacher-requests_bloc/teacher_requests_bloc.dart';
import 'package:bumblebee_school_final/repositories/admin/teacher_requests_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/class_bloc/class_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/class_bloc/class_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/class_bloc/class_state.dart';
import 'package:bumblebee_school_final/model/admin+teacher/class_model.dart';
import 'package:bumblebee_school_final/screen/admin/teacher_list.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/classes/student_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClassDisplayScreen extends StatefulWidget {
  @override
  _ClassDisplayScreenState createState() => _ClassDisplayScreenState();
}

class _ClassDisplayScreenState extends State<ClassDisplayScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage(); // For secure storage
  String userRole = ''; // To hold the user role
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole(); // Load the user role when initializing
    // Trigger loading of classes when the screen is initialized
    context.read<ClassBloc>().add(LoadClasses());
  }

  Future<void> _loadUserRole() async {
    String? storedRole = await storage.read(key: 'userRole');

    setState(() {
      userRole = storedRole ?? ''; // Set the user role
      print('Loaded user role: $userRole');
    });
  }

  void _showEditDialog(ClassModel classToEdit) {
    final classNameController = TextEditingController(text: classToEdit.className);
    final gradeController = TextEditingController(text: classToEdit.grade);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: classNameController,
                decoration: InputDecoration(labelText: 'Class Name'),
              ),
              TextField(
                controller: gradeController,
                decoration: InputDecoration(labelText: 'Grade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final updatedClassData = {
                  'classId': classToEdit.id,
                  'grade': gradeController.text,
                  'className': classNameController.text,
                };

                context.read<ClassBloc>().add(EditClass(updatedClassData)); // Send updated class data
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ClassBloc, ClassState>(
        builder: (context, state) {
          if (state is ClassLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ClassError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ClassLoaded) {
            return ListView.builder(
              itemCount: state.classes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.classes[index].className),
                  subtitle: Text('Grade: ${state.classes[index].grade}'),
                  onTap: () {
                    // Now userRole is available after loading
                    print('Loaded user role: $userRole');

                    if (userRole == 'admin') {
                      // Navigate to TeacherList screen if the user is an admin
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<TeacherRequestBloc>(
                            create: (context) => TeacherRequestBloc(teacherRequestRepository: TeacherRequestRepository(token)),
                            child: TeacherList(classId: state.classes[index].id), // Use the current class ID
                          ),
                        ),
                      );
                    } else if (userRole == 'teacher') {
                      // Navigate to StudentList screen if the user is a teacher
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentList(classId: state.classes[index].id),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role not recognized')),
                      );
                    }
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(state.classes[index]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Delete Class'),
                                content: Text('Are you sure you want to delete this class?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      context.read<ClassBloc>().add(DeleteClass(state.classes[index].id));
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
