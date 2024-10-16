import 'package:bumblebee_school_final/model/admin+teacher/post_model.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {
  ///အဲ့အပိုင်းမှာကို ထပ်ပြီး​ောတ့ ပြင်ပြီးတော့ကို ထည့်ပေးဖို့ကို လိုမည်
}

class PostSuccess extends PostState {
  final List<PostModel> posts; // Add a field to store the list of posts

  PostSuccess(this.posts); // Update the constructor
}

class PostFailure extends PostState {
  final String error;

  PostFailure(this.error);
}
