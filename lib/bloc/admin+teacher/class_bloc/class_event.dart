import 'package:bumblebee_school_final/model/admin+teacher/class_model.dart';

abstract class ClassEvent {}

class LoadClasses extends ClassEvent {}

class CreateClass extends ClassEvent {
  final ClassModel newClass;
  CreateClass(this.newClass);
}

class EditClass extends ClassEvent {
  final Map<String, dynamic> updatedClassData; // Accepts a Map
  EditClass(this.updatedClassData);
}


class DeleteClass extends ClassEvent {
  final String classId;
  DeleteClass(this.classId);
}