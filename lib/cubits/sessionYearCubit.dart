import 'package:eschool_teacher/data/models/sessionYear.dart';
import 'package:eschool_teacher/data/repositories/systemInfoRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SessionYearState {}

class SessionYearInitial extends SessionYearState {}

class SessionYearFetchSuccess extends SessionYearState {
  final List<SessionYear> sessionYearList;

  SessionYearFetchSuccess({required this.sessionYearList});
}

class SessionYearFetchFailure extends SessionYearState {
  final String errorMessage;

  SessionYearFetchFailure(this.errorMessage);
}

class SessionYearFetchInProgress extends SessionYearState {}

class SessionYearCubit extends Cubit<SessionYearState> {
  final SystemRepository _systemRepository;

  SessionYearCubit(this._systemRepository) : super(SessionYearInitial());

  Future<void> fetchSessionYears() async {
    emit(SessionYearFetchInProgress());
    try {
      emit(SessionYearFetchSuccess(
          sessionYearList: await _systemRepository.fetchSessionYears()));
    } catch (e) {
      emit(SessionYearFetchFailure(e.toString()));
    }
  }
}
