import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {
  ///အဲ့အပိုင်းမှာကို ထပ်ပြီး​ောတ့ ပြင်ပြီးတော့ကို ထည့်ပေးဖို့ကို လိုမည်
}

// Success state when posts are successfully loaded or an action is completed (like deletion)
class PostLoaded extends PostState {
  final List<PostModel> posts;
  PostLoaded(this.posts);
  // Optionally, you can add methods to check if the list is empty, etc.
  bool get isEmpty => posts.isEmpty;
}

class PostSuccess extends PostState {
  final List<PostModel> posts; // Add a field to store the list of posts
  PostSuccess(this.posts); // Update the constructor
}

class PostFailure extends PostState {
  final String error;
  PostFailure(this.error);
}

class PostDeleted extends PostState {
  final List<PostModel> posts;
  PostDeleted(this.posts);
}
