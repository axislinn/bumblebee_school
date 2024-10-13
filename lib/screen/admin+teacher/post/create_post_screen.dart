import 'dart:io';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/post_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final PostRepository postRepository = PostRepository();
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? selectedClassName;
  String? selectedGradeName;
  List<String> classNames = [];
  List<String> gradeNames = [];
  String? selectedContentType;
  List<File> _images = [];
  List<File> _documents = [];
  final List<String> contentTypes = ['feed', 'announcement'];
  final ImagePicker _picker = ImagePicker();
  String? schoolId;
  String? schoolName;
  bool _isSubmitting = false; // Track whether the post is being created

  @override
  void initState() {
    super.initState();
    _fetchClassAndGradeNames();
    _fetchSchoolData();
  }

  // Fetch school data (schoolId and schoolName)
  Future<void> _fetchSchoolData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token != null) {
      try {
        List<Map<String, dynamic>> schoolsData =
            await PostRepository.fetchSchoolData(token);
        if (schoolsData.isNotEmpty) {
          setState(() {
            schoolId = schoolsData[0]["_id"];
            schoolName = schoolsData[0]["schoolName"];
          });
        }
      } catch (e) {
        print("Error fetching school data: $e");
      }
    }
  }

  // Fetch class names and grade names
  Future<void> _fetchClassAndGradeNames() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token != null) {
      List<String> fetchedClassNames =
          await PostRepository.fetchClassNames(token);
      List<String> fetchedGradeNames =
          await PostRepository.fetchGradeNames(token);

      setState(() {
        classNames = fetchedClassNames;
        gradeNames = fetchedGradeNames;
      });
    }
  }

  // Pick images from gallery
  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Pick documents using file picker
  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
    );

    if (result != null) {
      setState(() {
        _documents = result.files.map((file) => File(file.path!)).toList();
      });
    }
  }

  // Validate form fields
  String? _validateForm() {
    if (_headingController.text.isEmpty) {
      return 'Please enter a heading';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post created successfully!')),
          );
          setState(() {
            _isSubmitting = false; // Re-enable the button after success
          });
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });
        } else if (state is PostFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create post: ${state.error}')),
          );
          setState(() {
            _isSubmitting = false; // Re-enable the button after failure
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Post', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedContentType,
                  items: contentTypes.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedContentType = newValue;
                      // Clear the selected values when the content type changes
                      if (newValue == 'feed') {
                        selectedGradeName = null;
                        selectedClassName = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Content Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                // Disable these fields if 'feed' is selected
                if (selectedContentType == 'announcement') ...[
                  Text('Select Grade and Class',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedGradeName,
                          items: gradeNames.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedGradeName = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Grade',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedClassName,
                          items: classNames.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedClassName = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Class',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],

                TextField(
                  controller: _headingController,
                  decoration: InputDecoration(
                    labelText: 'Heading',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                // Other fields for feed type
                if (selectedContentType == 'feed' ||
                    selectedContentType == 'announcement') ...[
                  TextField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      labelText: 'Body',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 20),
                ],

                // Image and Document Pickers
                Center(
                  child: _images.isNotEmpty
                      ? Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _images
                              .map((image) => Image.file(image,
                                  height: 100, width: 100, fit: BoxFit.cover))
                              .toList(),
                        )
                      : TextButton.icon(
                          icon: Icon(Icons.photo, color: Colors.blue),
                          label: Text('Add Images',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: _pickImage,
                        ),
                ),
                SizedBox(height: 20),
                Center(
                  child: _documents.isNotEmpty
                      ? Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _documents
                              .map((doc) => Text(doc.path.split('/').last))
                              .toList(),
                        )
                      : TextButton.icon(
                          icon: Icon(Icons.file_present, color: Colors.blue),
                          label: Text('Add Documents',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: _pickDocuments,
                        ),
                ),
                SizedBox(height: 40),

                // Buttons Row (Create Post and Cancel)
// Action buttons
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align buttons to the right
                  children: [
                    // Cancel button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Cancel button color
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 10), // Space between buttons

                    // Submit button with BlocBuilder
                    BlocBuilder<PostBloc, PostState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is PostLoading
                              ? null // Disable button if in loading state
                              : () {
                                  final validationError = _validateForm();
                                  if (validationError != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(validationError)),
                                    );
                                  } else if (schoolId == null ||
                                      selectedContentType == null) {
                                    // Show error message if any of the required fields are null
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please fill out all the required fields.'),
                                      ),
                                    );
                                  } else {
                                    // Only proceed if all required fields are not null
                                    context.read<PostBloc>().add(CreatePost(
                                          heading: _headingController.text,
                                          body: _bodyController.text,
                                          classId: selectedClassName ?? '',
                                          schoolId: schoolId!,
                                          contentType: selectedContentType!,
                                          contentPictures: _images,
                                          documents:
                                              _documents, // Include documents
                                          gradeName: selectedGradeName ?? '',
                                          className: selectedClassName ??
                                              '', // Include documents
                                        ));
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Submit button color
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state is PostLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text('Submit',
                                  style: TextStyle(color: Colors.white)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
