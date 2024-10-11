import 'package:bumblebee_school_final/bloc/admin/school_bloc/school_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin/school_bloc/school_register_event.dart';
import 'package:bumblebee_school_final/bloc/admin/school_bloc/school_state.dart';
import 'package:bumblebee_school_final/repositories/admin/school_repository.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchoolForm extends StatefulWidget {
  @override
  _SchoolFormState createState() => _SchoolFormState();
}

class _SchoolFormState extends State<SchoolForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    schoolNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolRepository = SchoolRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text('Register School'),
      ),
      body: BlocProvider<SchoolBloc>(
        create: (context) => SchoolBloc(schoolRepository: schoolRepository),
        child: BlocListener<SchoolBloc, SchoolState>(
          listener: (context, state) {
            if (state is SchoolSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('School registered successfully!')),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else if (state is SchoolFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to register: ${state.error}')),
              );
            }
          },
          child: BlocBuilder<SchoolBloc, SchoolState>(
            builder: (context, state) {
              bool isButtonDisabled = state is SchoolLoading;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: schoolNameController,
                        decoration: InputDecoration(labelText: 'School Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the school name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the phone number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isButtonDisabled
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  final schoolBloc = BlocProvider.of<SchoolBloc>(context);
                                  schoolBloc.add(
                                    RegisterSchool(
                                      schoolName: schoolNameController.text,
                                      address: addressController.text,
                                      phone: phoneController.text,
                                      email: emailController.text,
                                    ),
                                  );
                                }
                              },
                        child: isButtonDisabled
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Register School'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
