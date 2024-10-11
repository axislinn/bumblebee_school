import 'dart:convert';
import 'package:bumblebee_school_final/model/admin/school_model.dart';
import 'package:http/http.dart' as http;

class SchoolRepository {
  static const String _baseUrl = 'http://18.138.29.140:3000';

  Future<void> registerSchool(SchoolModel school, String token) async {
    final url = Uri.parse('$_baseUrl/api/school/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(school.toJson()),
    );

    if (response.statusCode != 200) {
      // Log response status and body for more details
      print('Error registering school: ${response.statusCode} ${response.body}');
      throw Exception('Failed to register school. Status code: ${response.statusCode}. Error: ${response.body}');
    }
  }
}

