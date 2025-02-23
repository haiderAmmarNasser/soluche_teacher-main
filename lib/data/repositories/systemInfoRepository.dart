import 'package:eschool_teacher/data/models/event.dart';
import 'package:eschool_teacher/data/models/eventSchedule.dart';
import 'package:eschool_teacher/data/models/holiday.dart';
import 'package:eschool_teacher/data/models/sessionYear.dart';
import 'package:eschool_teacher/utils/api.dart';
import 'package:flutter/foundation.dart';

class SystemRepository {
  Future<dynamic> fetchSettings({required String type}) async {
    try {
      final result = await Api.get(
        queryParameters: {"type": type},
        url: Api.settings,
        useAuthToken: false,
      );

      return result['data'];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw ApiException(e.toString());
    }
  }

  Future<List<Holiday>> fetchHolidays() async {
    try {
      final result = await Api.get(url: Api.holidays, useAuthToken: false);
      return ((result['data'] ?? []) as List)
          .map((holiday) => Holiday.fromJson(Map.from(holiday)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Event>> fetchEvents() async {
    try {
      final result = await Api.get(url: Api.events, useAuthToken: true);
      return ((result['data'] ?? []) as List)
          .map((event) => Event.fromJson(Map.from(event)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<EventSchedule>> fetchEventDetails(
      {required String eventId}) async {
    try {
      final result = await Api.get(
          url: Api.eventDetails,
          useAuthToken: true,
          queryParameters: {"event_id": eventId});
      return ((result['data'] ?? []) as List)
          .map((event) => EventSchedule.fromJson(Map.from(event)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<SessionYear>> fetchSessionYears() async {
    try {
      final result = await Api.get(url: Api.sessionYears, useAuthToken: true);
      return ((result['data'] ?? []) as List)
          .map((event) => SessionYear.fromJson(Map.from(event)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
