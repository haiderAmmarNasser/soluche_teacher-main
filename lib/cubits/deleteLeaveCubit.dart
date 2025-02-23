import 'package:eschool_teacher/data/repositories/leaveRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteLeaveState {}

class DeleteLeaveInitial extends DeleteLeaveState {}

class DeleteLeaveInProgress extends DeleteLeaveState {}

class DeleteLeaveSuccess extends DeleteLeaveState {}

class DeleteLeaveFailure extends DeleteLeaveState {
  final String errorMessage;

  DeleteLeaveFailure(this.errorMessage);
}

class DeleteLeaveCubit extends Cubit<DeleteLeaveState> {
  final LeaveRepository _leaveRepository;

  DeleteLeaveCubit(this._leaveRepository) : super(DeleteLeaveInitial());

  Future<void> deleteLeave({required int leaveId}) async {
    emit(DeleteLeaveInProgress());
    try {
      await _leaveRepository.deleteLeave(leaveId: leaveId);
      emit(DeleteLeaveSuccess());
    } catch (e) {
      emit(DeleteLeaveFailure(e.toString()));
    }
  }
}
