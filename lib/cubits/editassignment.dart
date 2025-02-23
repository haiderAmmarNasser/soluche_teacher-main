import 'package:eschool_teacher/data/repositories/assignmentRepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EditAssignmentState {}

class EditAssignmentInitial extends EditAssignmentState {}

class EditAssignmentInProgress extends EditAssignmentState {}

class EditAssignmentSuccess extends EditAssignmentState {}

class EditAssignmentFailure extends EditAssignmentState {
  final String errorMessage;

  EditAssignmentFailure(this.errorMessage);
}

class EditAssignmentCubit extends Cubit<EditAssignmentState> {
  final AssignmentRepository _assignmentRepository;

  EditAssignmentCubit(this._assignmentRepository)
      : super(EditAssignmentInitial());

  Future<void> editAssignment({
    required int assignmentId,
    required int classSelectionId,
    required int subjectId,
    required String name,
    required String dateTime,
    required String instruction,
    required String points,
    required int resubmission,
    required String extraDayForResubmission,
    required List<PlatformFile> filePaths,
  }) async {
    emit(EditAssignmentInProgress());
    try {
      await _assignmentRepository.editassignment(
        assignmentId: assignmentId,
        classSelectionId: classSelectionId,
        dateTime: dateTime,
        name: name,
        subjectId: subjectId,
        extraDayForResubmission: int.parse(
          extraDayForResubmission.isEmpty ? "0" : extraDayForResubmission,
        ),
        instruction: instruction,
        points: int.parse(points.isEmpty ? "0" : points),
        resubmission: resubmission,
        filePaths: filePaths,
      );
      emit(EditAssignmentSuccess());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(EditAssignmentFailure(e.toString()));
    }
  }
}
