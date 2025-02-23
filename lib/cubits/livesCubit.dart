import 'package:eschool_teacher/data/models/live.dart';
import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LivesState {}

class LivesInitial extends LivesState {}

class LivesFetchInProgress extends LivesState {}

class LivesFetchSuccess extends LivesState {
  final List<Live> lives;

  LivesFetchSuccess(this.lives);
}

class LivesFetchFailure extends LivesState {
  final String errorMessage;

  LivesFetchFailure(this.errorMessage);
}

class LivesCubit extends Cubit<LivesState> {
  final LiveRepository _liveRepository;

  LivesCubit(this._liveRepository) : super(LivesInitial());

  Future<void> fetchLives({required int subjectId}) async {
    emit(LivesFetchInProgress());
    try {
      emit(
        LivesFetchSuccess(
          await _liveRepository.getLives(subjectId: subjectId),
        ),
      );
    } catch (e) {
      emit(LivesFetchFailure(e.toString()));
    }
  }

  void deleteLive(int liveId) {
    if (state is LivesFetchSuccess) {
      List<Live> lives = (state as LivesFetchSuccess).lives;
      lives.removeWhere((element) => element.id == liveId);
      emit(LivesFetchSuccess(lives));
    }
  }
}
