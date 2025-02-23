// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_teacher/data/repositories/studentRepository.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

@immutable
abstract class SubjectMarksBySubjectIdState {}

class SubjectMarksBySubjectIdInitial extends SubjectMarksBySubjectIdState {}

class SubjectMarksBySubjectIdSubmitInProgress
    extends SubjectMarksBySubjectIdState {}

class SubjectMarksBySubjectIdSubmitSuccess
    extends SubjectMarksBySubjectIdState {
  final bool isMarksUpdated;
  final String successMessage;

  SubjectMarksBySubjectIdSubmitSuccess({
    required this.isMarksUpdated,
    required this.successMessage,
  });
}

class SubjectMarksBySubjectIdSubmitFailure
    extends SubjectMarksBySubjectIdState {
  final String errorMessage;

  SubjectMarksBySubjectIdSubmitFailure({required this.errorMessage});
}

class SubjectMarksBySubjectIdCubit extends Cubit<SubjectMarksBySubjectIdState> {
  StudentRepository studentRepository;

  SubjectMarksBySubjectIdCubit({required this.studentRepository})
      : super(SubjectMarksBySubjectIdInitial());
//
  //This method is used to submit subject marks by student Id
  Future<void> submitSubjectMarksBySubjectId({
    required int subjectId,
    required int examId,
    required int classSectionId,
    required List<Map<String, dynamic>> bodyParameter,
  }) async {
    try {
      var parameter = {"marks_data": bodyParameter};
      emit(SubjectMarksBySubjectIdSubmitInProgress());
      Map<String, dynamic> result =
          await studentRepository.updateSubjectMarksBySubjectId(
        subjectId: subjectId,
        examId: examId,
        bodyParameter: parameter,
        classSectionId: classSectionId,
      );

      emit(
        SubjectMarksBySubjectIdSubmitSuccess(
          isMarksUpdated: !result['error'],
          successMessage: result['message'],
        ),
      );
    } catch (e) {
      emit(SubjectMarksBySubjectIdSubmitFailure(errorMessage: e.toString()));
    }
  }
}
