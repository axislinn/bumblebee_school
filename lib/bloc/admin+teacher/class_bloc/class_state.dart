import 'package:bumblebee_school_final/model/admin+teacher/class_model.dart';

abstract class ClassState {}

class ClassInitial extends ClassState {}

class ClassLoading extends ClassState {}

class ClassLoaded extends ClassState {
  final List<ClassModel> classes;
  ClassLoaded(this.classes);
}

class ClassError extends ClassState {
  final String message;
  ClassError(this.message);
}