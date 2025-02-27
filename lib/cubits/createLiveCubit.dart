import 'package:eschool_teacher/data/models/pickedStudyMaterial.dart';
import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:eschool_teacher/utils/hiveBoxKeys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

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
  void onSuccess() {
    emit(CreateLiveSuccess());
  }

  void onFailur() {
    emit(CreateLiveFailure("error "));
  }

  Future<void> createLive({
    required int subjectId,
    required String liveDescription,
    required List<PickedStudyMaterial> files,
    required String date,
    required String fromTime,
    required String toTime,
    required String hour,
    required String minute,
    required String endHour,
    required String endMinute,
  }) async {
    emit(CreateLiveInProgress());
    try {
      List<Map<String, dynamic>> filesJosn = [];
      for (var file in files) {
        filesJosn.add(await file.toJson());
      }
      await _liveRepository.scheduleZoomMeeting(
          liveDescription, date, hour, minute, endHour, endMinute);
      print("b");
      print("meeting created: " + _liveRepository.meetingCreated.toString());
      if (_liveRepository.meetingCreated) {
        print("--------------------");
        print(this._liveRepository.meetingId);
        print(this._liveRepository.meetingPasswd);
        print(this._liveRepository.joinUrl);
        print(this._liveRepository.startUrl);
        print("-----------------------------");
        Map<String, dynamic> body = {
          "subject_id": subjectId.toString(),
          "description": liveDescription,
          "date": date,
          "from": fromTime,
          "to": toTime,
          "meeting_id": this._liveRepository.meetingId,
          "meeting_password": this._liveRepository.meetingPasswd.toString(),
          "join_url": this._liveRepository.joinUrl.toString(),
          "start_url": this._liveRepository.startUrl.toString(),
        };
        final String jwtToken = Hive.box(authBoxKey).get(jwtTokenKey) ?? "";
        var response = await http.post(
          Uri.parse('https://solucheonline.com/api/lives/store'),
          body: body,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer ${jwtToken}",
          },
        );
        print("a");
        print(response.statusCode);
        print(response.body);
        print("B");
        if (response.statusCode == 200 || response.statusCode == 201) {
          emit(CreateLiveSuccess());
        } else {
          emit(CreateLiveFailure("cxvxv"));
        }
      } else {
        emit(CreateLiveFailure("error "));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(CreateLiveFailure(e.toString()));
    }
  }
}
