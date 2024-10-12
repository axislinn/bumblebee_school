part of 'leave_request_bloc.dart';

sealed class LeaveRequestState extends Equatable {
  const LeaveRequestState();
  
  @override
  List<Object> get props => [];
}

final class LeaveRequestInitial extends LeaveRequestState {}
