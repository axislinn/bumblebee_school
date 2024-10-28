import 'package:bumblebee_school_final/bloc/teacher/student_bloc/student_bloc.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/class_repository.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/user_repository.dart';
import 'package:bumblebee_school_final/repositories/teacher/teacher_repository.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/classes/request_to_join_class.dart';
import 'package:bumblebee_school_final/screen/admin/register_school.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchoolSelect extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('School'),
      
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SchoolForm(),
                  ),
                );
              },
              child: Text('Register School'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<StudentBloc>(
          create: (context) => StudentBloc(ClassRepository(), UserRepository(), TeacherRepository()),
          child: RequestToJoinClass(),
        ),
      ),
    );
  },
  child: Text('Link With School'),
),

          ],
        ),
      ),
    );
  }
}
