import 'package:bumblebee_school_final/model/admin/teacher_requests_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherRequestRepository {
  final String token;

  TeacherRequestRepository(this.token);

  Future<List<TeacherRequestModel>> fetchTeacherRequests(String classId, String token) async {
    if (classId.isEmpty) {
      throw Exception('Class ID is required for fetching teacher requests.');
    }

    try {
      final response = await http.get(
        Uri.parse('https://tharhtetaung.xyz/api/request/readTeacherRequests?classId=$classId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody is List) {
          return responseBody.map((json) => TeacherRequestModel.fromJson(json)).toList();
        } else if (responseBody is Map<String, dynamic>) {
          return [TeacherRequestModel.fromJson(responseBody)];
        } else {
          throw Exception('Unexpected response format: $responseBody');
        }
      } else {
        print('Error fetching teacher requests: ${response.body}');
        throw Exception('Failed to load teacher requests: ${response.body}');
      }
    } catch (error) {
      print('Exception in fetchTeacherRequests: $error');
      rethrow;
    }
  }

  Future<void> respondToRequest(String requestId, bool response, String classId, String token) async {
    if (classId.isEmpty) {
      throw Exception('Class ID is required for responding to a request.');
    }

    try {
      final apiUrl = 'https://tharhtetaung.xyz/api/request/respondTeacherReq/$classId';

      final httpResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'classId': classId,
          'requestId': requestId,
          'response': response,
        }),
      );

      if (httpResponse.statusCode != 200) {
        print('Error responding to request: ${httpResponse.body}');
        throw Exception('Failed to respond to request: ${httpResponse.body}');
      }
    } catch (error) {
      print('Exception in respondToRequest: $error');
      rethrow;
    }
  }

Future<List<String>> fetchCurrentTeachers(String classId, String token) async {
  try {
    final response = await http.get(
      Uri.parse('https://tharhtetaung.xyz/api/class/classById/$classId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // Adjust the parsing to access teachers within result
      if (responseBody is Map<String, dynamic> && responseBody['result'] != null && responseBody['result']['teachers'] != null) {
        return List<String>.from(responseBody['result']['teachers']);
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load current teachers: ${response.body}');
    }
  } catch (error) {
    print('Exception in fetchCurrentTeachers: $error');
    rethrow;
  }
}

}
