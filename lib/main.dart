import 'package:bumblebee_school_final/bloc/admin+teacher/class_bloc/class_bloc.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/class_repository.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/user_repository.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/auth/splashscreen.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/navi_drawer/drawer_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => ClassBloc(ClassRepository(), UserRepository()),
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), 
      onGenerateRoute: DrawerRoutes.generateRoute
    );
  }
}
