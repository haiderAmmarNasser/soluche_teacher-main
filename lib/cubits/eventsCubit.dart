import 'package:eschool_teacher/data/models/event.dart';
import 'package:eschool_teacher/data/repositories/systemInfoRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsFetchInProgress extends EventsState {}

class EventsFetchSuccess extends EventsState {
  final List<Event> events;

  EventsFetchSuccess({required this.events});
}

class EventsFetchFailure extends EventsState {
  final String errorMessage;

  EventsFetchFailure(this.errorMessage);
}

class EventsCubit extends Cubit<EventsState> {
  final SystemRepository _systemRepository;

  EventsCubit(this._systemRepository) : super(EventsInitial());

  Future<void> fetchEvents() async {
    emit(EventsFetchInProgress());
    try {
      emit(
        EventsFetchSuccess(
          events: await _systemRepository.fetchEvents(),
        ),
      );
    } catch (e) {
      emit(EventsFetchFailure(e.toString()));
    }
  }

  List<Event> events() {
    if (state is EventsFetchSuccess) {
      return (state as EventsFetchSuccess).events;
    }
    return [];
  }
}
