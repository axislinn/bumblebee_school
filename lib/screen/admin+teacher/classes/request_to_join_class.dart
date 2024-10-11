import 'package:bumblebee_school_final/bloc/teacher/student_bloc/student_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestToJoinClass extends StatefulWidget {
  @override
  _RequestToJoinClassState createState() => _RequestToJoinClassState();
}

class _RequestToJoinClassState extends State<RequestToJoinClass> {
  final TextEditingController _classCodeController = TextEditingController();
  bool _isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            // Handle success and error states
            if (state is JoinClassSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Requested to join class successfully'),
              ));
              setState(() {
                _isButtonDisabled = false;
              });
              _classCodeController.clear(); // Clear the text field
              
            } else if (state is JoinClassErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error joining class: ${state.message}'),
              ));
              setState(() {
                _isButtonDisabled = false;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
              controller: _classCodeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your Class Code',
              ),
            ),
              SizedBox(height: 20),
              Center( 
                child: ElevatedButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          setState(() {
                            _isButtonDisabled = true;
                          });
                          _requestToJoinClass(context);
                        },
                  child: _isButtonDisabled
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Join Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // function to handle the join class request
  void _requestToJoinClass(BuildContext context) {
    String classCode = _classCodeController.text;
    if (classCode.isNotEmpty) {
      context.read<StudentBloc>().add(RequestToJoinClassEvent(classCode));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid class code'),
      ));
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }
}
