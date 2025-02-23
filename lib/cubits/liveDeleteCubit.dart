import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LiveDeleteState {}

class LiveDeleteInitial extends LiveDeleteState {}

class LiveDeleteInProgress extends LiveDeleteState {}

class LiveDeleteSuccess extends LiveDeleteState {}

class LiveDeleteFailure extends LiveDeleteState {
  final String errorMessage;

  LiveDeleteFailure(this.errorMessage);
}

class LiveDeleteCubit extends Cubit<LiveDeleteState> {
  final LiveRepository _liveRepository;

  LiveDeleteCubit(this._liveRepository) : super(LiveDeleteInitial());

  Future<void> deleteLive(int liveId) async {
    emit(LiveDeleteInProgress());
    try {
      await _liveRepository.deleteLive(liveId: liveId);

      emit(LiveDeleteSuccess());
    } catch (e) {
      emit(LiveDeleteFailure(e.toString()));
    }
  }
}
