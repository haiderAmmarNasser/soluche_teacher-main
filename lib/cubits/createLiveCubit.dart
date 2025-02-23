import 'package:eschool_teacher/data/models/pickedStudyMaterial.dart';
import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateLiveState {}

class CreateLiveInitial extends CreateLiveState {}

class CreateLiveInProgress extends CreateLiveState {}

class CreateLiveSuccess extends CreateLiveState {}

class CreateLiveFailure extends CreateLiveState {
  final String errorMessage;

  CreateLiveFailure(this.errorMessage);
}

class CreateLiveCubit extends Cubit<CreateLiveState> {
  final LiveRepository _liveRepository;

  CreateLiveCubit(this._liveRepository) : super(CreateLiveInitial());

  Future<void> createLive({
    required int subjectId,
    required String liveDescription,
    required List<PickedStudyMaterial> files,
    required String date,
    required String fromTime,
    required String toTime,
  }) async {
    // emit(CreateLiveInProgress());
    try {
      await _liveRepository.scheduleZoomMeeting();
      // List<Map<String, dynamic>> filesJosn = [];
      // for (var file in files) {
      //   filesJosn.add(await file.toJson());
      // }

      // await _liveRepository.createLive(
      //   subjectId: subjectId,
      //   files: filesJosn,
      //   fromTime: fromTime,
      //   toTime: toTime,
      //   liveDescription: liveDescription,
      //   date: date,
      // );
      // emit(CreateLiveSuccess());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(CreateLiveFailure(e.toString()));
    }
  }
}
