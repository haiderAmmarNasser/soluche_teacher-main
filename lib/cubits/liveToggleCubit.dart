import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LiveToggleState {}

class LiveToggleInitial extends LiveToggleState {}

class LiveToggleInProgress extends LiveToggleState {}

class LiveToggleSuccess extends LiveToggleState {}

class LiveToggleFailure extends LiveToggleState {
  final String errorMessage;

  LiveToggleFailure(this.errorMessage);
}

class LiveToggleCubit extends Cubit<LiveToggleState> {
  final LiveRepository _liveRepository;

  LiveToggleCubit(this._liveRepository) : super(LiveToggleInitial());

  Future<void> toggleLive(int liveId) async {
    emit(LiveToggleInProgress());
    try {
      await _liveRepository.toggleLiveStatus(liveId: liveId);

      emit(LiveToggleSuccess());
    } catch (e) {
      emit(LiveToggleFailure(e.toString()));
    }
  }
}
