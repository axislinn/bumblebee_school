import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});
}

class PostRepository {
  // // Function to create announcement post
  // Future<ApiResponse> createAnnouncement(
  //   String? token,
  //   String selectedHeading,
  //   String? bodyText,
  //   String? selectedClassName,
  //   String? schoolId,
  //   List<String> contentPictures,
  //   List<String> documents,
  //   String? gradeName,
  //   String? className,
  //   String contentType,
  // ) async {
  //   final url = 'http://18.138.29.140:3000/api/posts/create';

  //   // Debug print for checking token
  //   print('Token: $token');

  //   if (token == null || token.isEmpty) {
  //     print('Token is missing.');
  //     return ApiResponse(success: false, message: "Token is missing.");
  //   }

  //   // Create request body for announcement
  //   final requestBody = {
  //     'heading': selectedHeading,
  //     'body': bodyText ?? '',
  //     'classId': selectedClassName,
  //     'schoolId': schoolId ?? '',
  //     'contentPictures': contentPictures,
  //     'documents': documents,
  //     'className': className ?? '',
  //     'gradeName': gradeName ?? '',
  //     'contentType': contentType
  //   };

  //   print('Announcement Request Body: $requestBody');

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(requestBody),
  //     );

  //     print('Response Status: ${response.statusCode}');
  //     print('Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //       return ApiResponse(
  //         success: jsonResponse['con'] ?? false,
  //         message: jsonResponse['msg'] ?? 'No message received',
  //       );
  //     } else {
  //       print('Failed to create announcement: ${response.reasonPhrase}');
  //       return ApiResponse(
  //         success: false,
  //         message: 'Failed to create announcement: ${response.reasonPhrase}',
  //       );
  //     }
  //   } catch (e) {
  //     print('An error occurred: $e');
  //     return ApiResponse(success: false, message: 'An error occurred: $e');
  //   }
  // }

  // Function to create an announcement post
  Future<ApiResponse> createAnnouncement(
    String token,
    String heading,
    String? body,
    String classId,
    String schoolId,
    List<http.MultipartFile> contentPictures,
    List<http.MultipartFile> documents,
    String? gradeName,
    String? className,
    String contentType,
  ) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://18.138.29.140:3000/api/posts/create'));

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['heading'] = heading;
    request.fields['classId'] = classId;
    request.fields['schoolId'] = schoolId;
    if (body != null) request.fields['body'] = body;
    if (gradeName != null) request.fields['gradeName'] = gradeName;
    if (className != null) request.fields['className'] = className;
    request.fields['contentType'] = contentType;

    // Add image and document files to the request
    request.files.addAll(contentPictures);
    request.files.addAll(documents);

    // Send request and get the response
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return ApiResponse(success: true, message: 'Post created successfully');
    } else {
      return ApiResponse(success: false, message: 'Failed to create post');
    }
  }

// // Function to create feed post
//   Future<ApiResponse> createFeedPost(
//     String? token,
//     String selectedHeading,
//     String? bodyText,
//     String? schoolId,
//     List<String> contentPictures,
//     List<String> documents,
//     String contentType,
//   ) async {
//     final url = 'http://18.138.29.140:3000/api/posts/create';

//     // Debug print for checking token
//     print('Token: $token');

//     if (token == null || token.isEmpty) {
//       print('Token is missing.');
//       return ApiResponse(success: false, message: "Token is missing.");
//     }

//     // Create request body for feed post
//     final requestBody = {
//       'heading': selectedHeading,
//       'body': bodyText ?? '',
//       'schoolId': schoolId ?? '',
//       'contentPictures': contentPictures,
//       'documents': documents,
//       'contentType': contentType,
//     };

//     print('Feed Post Request Body: $requestBody');

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(requestBody),
//       );

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         return ApiResponse(
//           success: jsonResponse['con'] ?? false,
//           message: jsonResponse['msg'] ?? 'No message received',
//         );
//       } else {
//         print('Failed to create feed post: ${response.reasonPhrase}');
//         return ApiResponse(
//           success: false,
//           message: 'Failed to create feed post: ${response.reasonPhrase}',
//         );
//       }
//     } catch (e) {
//       print('An error occurred: $e');
//       return ApiResponse(success: false, message: 'An error occurred: $e');
//     }
//   }

  // Function to create feed post
  Future<ApiResponse> createFeedPost(
    String token,
    String heading,
    String? body,
    String schoolId,
    List<http.MultipartFile> contentPictures,
    List<http.MultipartFile> documents,
    String contentType,
  ) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://18.138.29.140:3000/api/posts/create'));

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['heading'] = heading;
    request.fields['schoolId'] = schoolId;
    if (body != null) request.fields['body'] = body;
    request.fields['contentType'] = contentType;

    // Add image and document files to the request
    request.files.addAll(contentPictures);
    request.files.addAll(documents);

    // Send request and get the response
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return ApiResponse(success: true, message: 'Post created successfully');
    } else {
      return ApiResponse(success: false, message: 'Failed to create post');
    }
  }

  Future<List<PostModel>> fetchPosts(String? token) async {
    final url = 'http://18.138.29.140:3000/api/posts/getFeeds';

    // Check if the token is null or empty
    if (token == null || token.isEmpty) {
      print("Error: Token is missing.");
      return []; // Or handle it as appropriate
    }

    try {
      print("Fetching posts from URL: $url with token: $token");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Response body: ${response.body}");

      // Check the response status
      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Debugging: Log the response structure
        print("Response structure: ${jsonResponse.keys}");

        // Check if the result field exists and has items
        if (jsonResponse.containsKey('result') &&
            jsonResponse['result'].containsKey('items')) {
          final List<dynamic> jsonPosts = jsonResponse['result']['items'];

          // Debugging: Log the number of posts fetched
          print("Number of posts fetched: ${jsonPosts.length}");

          // Convert the items to PostModel objects
          return jsonPosts.map((json) => PostModel.fromJson(json)).toList();
        } else {
          print("Key 'items' not found in 'result'");
          return [];
        }
      } else {
        print("Failed to fetch posts: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Debugging: Log any errors
      print("Error fetching posts: $e");
      return [];
    }
  }

  // Fetch class names
  static Future<List<String>> fetchClassNames(String token) async {
    final response = await http.get(
      Uri.parse('http://18.138.29.140:3000/api/class/classNames'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Debugging the structure
      print(jsonResponse);

      if (jsonResponse["con"] == true) {
        // The result is directly a list of class names
        var classNamesResult = jsonResponse["result"];

        // Ensure it's a list, and then return it
        if (classNamesResult is List) {
          return List<String>.from(classNamesResult);
        } else {
          throw Exception(
              "Expected a list of class names, but got something else.");
        }
      } else {
        throw Exception("Error fetching class names: ${jsonResponse['msg']}");
      }
    } else {
      throw Exception('Failed to fetch class names');
    }
  }

  //fetch Grade Names
  static Future<List<String>> fetchGradeNames(String token) async {
    final response = await http.get(
      Uri.parse('http://18.138.29.140:3000/api/class/gradeNames'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Debugging the structure
      print(jsonResponse);

      if (jsonResponse["con"] == true) {
        // The result is directly a list of grade names
        var gradeNamesResult = jsonResponse["result"];

        // Ensure it's a list, and then return it
        if (gradeNamesResult is List) {
          return List<String>.from(gradeNamesResult);
        } else {
          throw Exception(
              "Expected a list of grade names, but got something else.");
        }
      } else {
        throw Exception("Error fetching grade names: ${jsonResponse['msg']}");
      }
    } else {
      throw Exception('Failed to fetch grade names');
    }
  }

  //get schoolName and schoolId
  static Future<List<Map<String, dynamic>>> fetchSchoolData(
      String token) async {
    final response = await http.get(
      Uri.parse(
          'http://18.138.29.140:3000/api/school/getSchool'), // Replace with actual endpoint
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Debugging: print the whole JSON response
      print('JSON Response: $jsonResponse');

      // Check if the expected fields exist in the response
      if (jsonResponse["con"] == true && jsonResponse["result"] is List) {
        // Return the list of schools
        return List<Map<String, dynamic>>.from(jsonResponse["result"]);
      } else {
        throw Exception("Error fetching school data: ${jsonResponse['msg']}");
      }
    } else {
      throw Exception('Failed to fetch school data: ${response.statusCode}');
    }
  }

  Future<void> _attachImages(
      List<String> contentPictures, http.MultipartRequest request) async {
    for (var picturePath in contentPictures) {
      request.files.add(await http.MultipartFile.fromPath(
          'images', picturePath)); // Change 'images' if needed
    }
  }

  Future<void> _attachDocuments(
      List<String> documents, http.MultipartRequest request) async {
    for (var documentPath in documents) {
      request.files.add(await http.MultipartFile.fromPath(
          'documents', documentPath)); // Change 'documents' if needed
    }
  }
}
