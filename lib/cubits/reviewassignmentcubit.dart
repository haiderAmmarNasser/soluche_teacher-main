// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:eschool_teacher/data/repositories/reviewAssignmentRepository.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages

import 'package:eschool_teacher/data/models/reviewAssignmentssubmition.dart';

@immutable
abstract class ReviewAssignmentState {}

class ReviewAssignmentInitial extends ReviewAssignmentState {}

class ReviewAssignmentInProcess extends ReviewAssignmentState {}

class ReviewAssignmentSuccess extends ReviewAssignmentState {
  final List<ReviewAssignmentsSubmission> reviewAssignment;

  ReviewAssignmentSuccess({
    required this.reviewAssignment,
  });
}

class ReviewAssignmentFailure extends ReviewAssignmentState {
  final String errorMessage;
  ReviewAssignmentFailure({
    required this.errorMessage,
  });
}

class ReviewAssignmentCubit extends Cubit<ReviewAssignmentState> {
  final ReviewAssignmentRepository _reviewAssignmentRepository;
  ReviewAssignmentCubit(this._reviewAssignmentRepository)
      : super(ReviewAssignmentInitial());

  Future<void> fetchReviewAssignment({
    required int assignmentId,
  }) async {
    try {
      emit(ReviewAssignmentInProcess());
      await _reviewAssignmentRepository
          .fetchReviewAssignment(assignmetId: assignmentId)
          .then((value) {
        emit(
          ReviewAssignmentSuccess(
            reviewAssignment: value,
          ),
        );
      });
    } catch (e) {
      if (kDebugMode) {
        print(" reviewassignment$e");
      }
      emit(ReviewAssignmentFailure(errorMessage: e.toString()));
    }
  }

  Future<void> updateReviewAssignmet({
    required ReviewAssignmentsSubmission updatedReviewAssignmentSubmition,
  }) async {
    try {
      List<ReviewAssignmentsSubmission> currentassignment =
          (state as ReviewAssignmentSuccess).reviewAssignment;
      List<ReviewAssignmentsSubmission> updateassignment =
          List.from(currentassignment);
      int reviewAssignmentIndex = currentassignment.indexWhere(
        (element) => element.id == updatedReviewAssignmentSubmition.id,
      );
      updateassignment[reviewAssignmentIndex] =
          updatedReviewAssignmentSubmition;
      emit(ReviewAssignmentSuccess(reviewAssignment: updateassignment));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(ReviewAssignmentFailure(errorMessage: e.toString()));
    }
  }

  List<ReviewAssignmentsSubmission> reviewAssignment() {
    return (state as ReviewAssignmentSuccess).reviewAssignment;
  }
}
