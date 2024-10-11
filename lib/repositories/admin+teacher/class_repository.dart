import 'dart:convert';
import 'package:bumblebee_school_final/model/admin+teacher/class_model.dart';
import 'package:http/http.dart' as http;


class ClassRepository {
  final String baseUrl = 'http://18.138.29.140:3000';

  Future<List<ClassModel>> fetchClasses(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/class/readByAdmin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }, 
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['result'] != null && jsonResponse['result']['classes'] != null) {
        List<dynamic> jsonList = jsonResponse['result']['classes'];
        return jsonList.map((json) => ClassModel.fromJson(json)).toList();
      } else {
        throw Exception('Invalid data: classes not found in response');
      }
    } else {
      print('Failed to load classes: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load classes');
    }
  }

  Future<void> createClass(ClassModel newClass, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/class/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
      body: json.encode({
        'className': newClass.className,
        'grade': newClass.grade,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var jsonResponse = json.decode(response.body);

    print('Parsed JSON response: $jsonResponse');

}

Future<void> editClass(Map<String, dynamic> updatedClassData, String token) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/class/edit'), 
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(updatedClassData),
  );

  if (response.statusCode != 200) {
    print('Failed to edit class: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to edit class');
  }
}

Future<void> deleteClass(String classId, String token) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/class/delete'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({"classId" : '$classId'}),
  );

  if (response.statusCode == 200) {
    print('Class deleted successfully.');
  } else {
    print('Failed to delete class: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to delete class');
  }
}


}