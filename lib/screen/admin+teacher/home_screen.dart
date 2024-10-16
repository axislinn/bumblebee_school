import 'dart:async';

import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_bloc.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_event.dart';
import 'package:bumblebee_school_final/bloc/admin+teacher/post/post_state.dart';
import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';
import 'package:bumblebee_school_final/repositories/admin+teacher/post_repository.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/body_widget.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/bottom_nav/bottom_nav.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/navi_drawer/navi_drawer_screen.dart';
import 'package:bumblebee_school_final/screen/admin+teacher/post/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(postRepository: PostRepository())
        ..add(FetchPosts()), // Fetch posts when screen is created
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Home Screen'),
        ),
        endDrawer: const NaviDrawer(),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PostSuccess) {
              final posts = state.posts;
              if (posts.isEmpty) {
                return Center(child: Text('No posts available'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(FetchPosts());
                },
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostWidget(post: post);
                  },
                ),
              );
            } else if (state is PostFailure) {
              return Center(
                  child: Text('Failed to load posts: ${state.error}'));
            } else {
              return Center(child: Text('Unexpected error occurred.'));
            }
          },
        ),
        floatingActionButton: _currentIndex == 0
            ? Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: FloatingActionButton(
                  onPressed: () {
                    navigateToCreatePostScreen(context);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.grey,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomNav(
            // selectedIndex: _currentIndex,
            // onItemTapped: (index) {
            //   setState(() {
            //     _currentIndex = index;
            //   });
            // },
            ),
      ),
    );
  }

  void navigateToCreatePostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => PostBloc(postRepository: PostRepository()),
          child: CreatePostScreen(),
        ),
      ),
    ).then(() {
      if (_currentIndex == 0) {
        context.read<PostBloc>().add(FetchPosts());
      }
    } as FutureOr Function(dynamic value));
  }
}
