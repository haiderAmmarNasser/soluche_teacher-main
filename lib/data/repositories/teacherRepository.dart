import 'package:eschool_teacher/data/models/attendanceReport.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/customNotification.dart';
import 'package:eschool_teacher/data/models/holiday.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/models/timeTableSlot.dart';
import 'package:eschool_teacher/utils/api.dart';
import 'package:flutter/foundation.dart';

class TeacherRepository {
  Future<Map<String, dynamic>> myClasses() async {
    try {
      final result = await Api.get(url: Api.getClasses, useAuthToken: true);

      return {
        "primaryClass": result['data']['class_teacher'].isEmpty
            ? null
            : (result['data']['class_teacher'] as List)
                .map((e) => ClassSectionDetails.fromJson(Map.from(e)))
                .toList(),
        "classes": (result['data']['other'] as List)
            .map((e) => ClassSectionDetails.fromJson(Map.from(e)))
            .toList()
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Subject>> subjectsByClassSection(int classSectionId) async {
    try {
      final result = await Api.get(
        url: Api.getSubjectByClassSection,
        useAuthToken: true,
        queryParameters: {"class_section_id": classSectionId},
      );
      return (result['data'] as List)
          .map(
            (subjectJson) => Subject.fromJson(Map.from(subjectJson['subject'])),
          )
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getClassAttendanceReports({
    required int classSectionId,
    required String date,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getAttendance,
        useAuthToken: true,
        queryParameters: {"class_section_id": classSectionId, "date": date},
      );

      return {
        "attendanceReports": (result['data'] as List)
            .map(
              (attendanceReport) => AttendanceReport.fromJson(attendanceReport),
            )
            .toList(),
        "isHoliday": result['is_holiday'],
        "holidayDetails": Holiday.fromJson(
          //
          Map.from(
            result['holiday'] == null ? {} : (result['holiday'] as List).first,
          ),
        )
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> submitClassAttendance({
    required int classSectionId,
    required String date,
    required List<Map<String, dynamic>> attendance,
  }) async {
    try {
      await Api.post(
        url: Api.submitAttendance,
        useAuthToken: true,
        body: {
          "class_section_id": classSectionId,
          "date": date,
          "attendance": attendance,
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<TimeTableSlot>> fetchTimeTable() async {
    try {
      final result = await Api.get(url: Api.timeTable, useAuthToken: true);

      return (result['data'] as List)
          .map(
            (timetableSlot) => TimeTableSlot.fromJson(Map.from(timetableSlot)),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw ApiException(e.toString());
    }
  }

  //get custom notifications for parent
  Future<Map<String, dynamic>> fetchNotifications({required int page}) async {
    try {
      final response = await Api.get(
        url: Api.getNotifications,
        useAuthToken: true,
        queryParameters: {"page": page},
      );

      List<CustomNotification> notifications = [];

      for (int i = 0; i < response['data']['data'].length; i++) {
        notifications.add(
          CustomNotification.fromJson(
            response['data']['data'][i],
          ),
        );
      }

      return {
        "notifications": notifications,
        "currentPage": response['data']['current_page'],
        "totalPage": response['data']['last_page'],
      };
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw ApiException(error.toString());
    }
  }
}
