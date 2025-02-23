// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:eschool_teacher/data/repositories/reviewAssignmentRepository.dart';

@immutable
abstract class EditReviewAssignmetState {}

class EditReviewAssignmetInitial extends EditReviewAssignmetState {}

class EditReviewAssignmetInProgress extends EditReviewAssignmetState {}

class EditReviewAssignmetSuccess extends EditReviewAssignmetState {}

class EditReviewAssignmetFailure extends EditReviewAssignmetState {
  final String errorMessage;
  EditReviewAssignmetFailure({
    required this.errorMessage,
  });
}

class EditReviewAssignmetCubit extends Cubit<EditReviewAssignmetState> {
  final ReviewAssignmentRepository _reviewAssignmentRepository;
  EditReviewAssignmetCubit(
    this._reviewAssignmentRepository,
  ) : super(EditReviewAssignmetInitial());

  Future<void> updateReviewAssignmet({
    required int reviewAssignmetId,
    required int reviewAssignmentStatus,
    String? reviewAssignmentPoints,
    String? reviewAssignmentFeedBack,
  }) async {
    if (kDebugMode) {
      print(reviewAssignmentPoints);
    }
    try {
      emit(EditReviewAssignmetInProgress());
      await _reviewAssignmentRepository.updateReviewAssignment(
        reviewAssignmetId: reviewAssignmetId,
        reviewAssignmentStatus: reviewAssignmentStatus,
        reviewAssignmentPoints: reviewAssignmentPoints!.isNotEmpty
            ? int.parse(reviewAssignmentPoints)
            : 0,
        reviewAssignmentFeedBack: reviewAssignmentFeedBack!,
      );
      emit(EditReviewAssignmetSuccess());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(EditReviewAssignmetFailure(errorMessage: e.toString()));
    }
  }
}
