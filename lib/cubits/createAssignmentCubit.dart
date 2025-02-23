import 'package:eschool_teacher/data/repositories/assignmentRepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateAssignmentState {}

class CreateAssignmentInitial extends CreateAssignmentState {}

class CreateAssignmentInProcess extends CreateAssignmentState {}

class CreateAssignmentSuccess extends CreateAssignmentState {}

class CreateAssignmentFailure extends CreateAssignmentState {
  final String errormessage;
  CreateAssignmentFailure({
    required this.errormessage,
  });
}

class CreateAssignmentCubit extends Cubit<CreateAssignmentState> {
  final AssignmentRepository _assignmentRepository;

  CreateAssignmentCubit(this._assignmentRepository)
      : super(CreateAssignmentInitial());

  Future<void> createAssignment({
    required int classsId,
    required int subjectId,
    required String name,
    required String instruction,
    required String datetime,
    required String points,
    required bool resubmission,
    required String extraDayForResubmission,
    List<PlatformFile>? file,
  }) async {
    if (kDebugMode) {
      print("bodypoints $points");
    }
    emit(CreateAssignmentInProcess());
    try {
      await _assignmentRepository
          .createAssignment(
            classsId: classsId,
            subjectId: subjectId,
            name: name,
            datetime: datetime,
            resubmission: resubmission,
            extraDayForResubmission: int.parse(
              extraDayForResubmission.isEmpty ? "0" : extraDayForResubmission,
            ),
            filePaths: file,
            instruction: instruction,
            points: int.parse(points.isEmpty ? "0" : points),
          )
          .then((value) => emit(CreateAssignmentSuccess()));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(CreateAssignmentFailure(errormessage: e.toString()));
    }
  }
}
