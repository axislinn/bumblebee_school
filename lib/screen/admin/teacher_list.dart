import 'package:bumblebee_school_final/bloc/admin/teacher-requests_bloc/teacher_requests_bloc.dart';
import 'package:bumblebee_school_final/model/admin/teacher_requests_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherList extends StatefulWidget {
  final String classId;

  const TeacherList({required this.classId, Key? key}) : super(key: key);

  @override
  State<TeacherList> createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.classId.isNotEmpty) {
      final teacherRequestBloc = context.read<TeacherRequestBloc>();
      teacherRequestBloc.add(FetchTeacherRequests(widget.classId));
      teacherRequestBloc.add(FetchCurrentTeachers(widget.classId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Class ID cannot be empty.')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Current Teachers'),
            Tab(text: 'Teacher Requests'),
          ],
        ),
      ),
      body: BlocListener<TeacherRequestBloc, TeacherRequestState>(
        listener: (context, state) {
          if (state is TeacherRequestProcessed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TeacherRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CurrentTeachersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            BlocBuilder<TeacherRequestBloc, TeacherRequestState>(
              builder: (context, state) {
                if (state is TeacherRequestLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is CurrentTeachersLoaded) {
                  return _buildCurrentTeachers(state.teachers);
                } else {
                  return Center(child: Text('No data available for current teachers.'));
                }
              },
            ),
            BlocBuilder<TeacherRequestBloc, TeacherRequestState>(
              builder: (context, state) {
                if (state is TeacherRequestLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is TeacherRequestLoaded) {
                  return _buildTeacherRequests(state.teacherRequests);
                } else {
                  return Center(child: Text('No teacher requests available.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCurrentTeachers(List<String> currentTeachers) {
    if (currentTeachers.isEmpty) {
      return Center(child: Text('No current teachers available.'));
    }

    return ListView.builder(
      itemCount: currentTeachers.length,
      itemBuilder: (context, index) {
        final teacherName = currentTeachers[index];
        return Card(
          child: ListTile(
            title: Text('Teacher: $teacherName'),
          ),
        );
      },
    );
  }


  Widget _buildTeacherRequests(List<TeacherRequestModel> teacherRequests) {
    final pendingRequests = teacherRequests.where((req) => !req.response).toList();

    if (pendingRequests.isEmpty) {
      return Center(child: Text('No pending teacher requests.'));
    }

    return ListView.builder(
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return Card(
          child: ListTile(
            title: Text('Request from Teacher ${request.requestId}'),
            subtitle: Text('Class ID: ${request.classId}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    context.read<TeacherRequestBloc>().add(
                      AcceptTeacherRequest(request.requestId, request.classId),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    context.read<TeacherRequestBloc>().add(
                      RejectTeacherRequest(request.requestId, request.classId),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
