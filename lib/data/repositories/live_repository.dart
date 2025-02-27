import 'dart:convert';
import 'dart:math';
import 'package:eschool_teacher/data/models/live.dart';
import 'package:eschool_teacher/utils/api.dart';
import 'package:eschool_teacher/utils/hiveBoxKeys.dart';
import 'package:flutter_zoom_meeting/zoom_options.dart';
import 'package:flutter_zoom_meeting/zoom_view.dart'; // Import Zoom package
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

String formatDateTimeToUTC(String fullDate, String hour, String minute) {
  // Extract only the date part
  String dateOnly = fullDate.split(' ')[0];

  // Ensure hour and minute have two digits
  String formattedHour = hour.padLeft(2, '0');
  String formattedMinute = minute.padLeft(2, '0');

  // Create a DateTime object in UTC
  DateTime dateTime =
      DateTime.parse("$dateOnly $formattedHour:$formattedMinute:00").toUtc();

  // Convert to ISO 8601 format and ensure it ends with 'Z' (UTC)
  return dateTime.toIso8601String().split('.')[0] + "Z";
}

int calculateDurationInMinutes(
    String startHour, String startMinute, String endHour, String endMinute) {
  int startH = int.parse(startHour);
  int startM = int.parse(startMinute);
  int endH = int.parse(endHour);
  int endM = int.parse(endMinute);

  int startTotalMinutes = (startH * 60) + startM;
  int endTotalMinutes = (endH * 60) + endM;

  if (endTotalMinutes < startTotalMinutes) {
    endTotalMinutes += 24 * 60; // Add 24 hours in minutes
  }

  // Calculate duration
  int duration = endTotalMinutes - startTotalMinutes;

  return duration;
}

class LiveRepository {
  // Function to create live session
  bool meetingCreated = false;
  String meetingId = '';
  String meetingPasswd = '';
  String joinUrl = '';
  String startUrl = '';
  // Future<void> createLive({
  //   required int subjectId,
  //   required String liveDescription,
  //   required List<Map<String, dynamic>> files,
  //   required String date,
  //   required String fromTime,
  //   required String toTime,
  //   required String meetingId,
  //   required String meetingPasswd,
  //   required String joinUrl,
  //   required String startUrl,
  // }) async {
  //   try {
  //     print("hereeeeeeeeeeeeeeeeeeeee");
  //     Map<String, dynamic> body = {
  //       "subject_id": subjectId,
  //       "description": liveDescription,
  //       "date": date,
  //       "from": fromTime,
  //       "to": toTime,
  //       // "meeting_id":this.meetingId,
  //       // "meeting_password": meetingPasswd.toString(),
  //       // "join_url": joinUrl.toString(),
  //       // "start_url": startUrl.toString(),

  //        "meeting_id":"s",
  //       "meeting_password":"sd",
  //       "join_url":" joinUrl.toString(),",
  //       "start_url": "startUrl.toString(),",
  //     };
  //     print("hereeeeeeeeeeee");

  //     if (files.isNotEmpty) {
  //       body['files'] = files;
  //     }
  //      var responce=Api.post(body: body, url: Api.createLive, useAuthToken: true);

  //      print(responce);
  //   } catch (e) {
  //     print("e excpetion");
  //     throw ApiException(e.toString());
  //   }
  // }

  String generateZoomJWT() {
    final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30;
    final exp = iat + 60 * 60 * 2;

    final oPayload = {
      'sdkKey': 'ImSXMTjoTyE2a8WgqwQaw',
      'iat': iat,
      'exp': exp,
      'appKey': 'ImSXMTjoTyE2a8WgqwQaw',
      'tokenExp': iat + 60 * 60 * 2
    };

    final jwt = JWT(
      oPayload,
      header: {
        'alg': 'HS256',
        'typ': 'JWT',
      },
    );
    final jwtToken = jwt.sign(SecretKey('n0Ie97c2u1HUOYvTqQ5gNkUXJEvDC4yu'));
    return jwtToken;
  }

//
  // String startToken = '';
  ZoomView zoom = ZoomView();
  var meeting;
  var token;
  generateZoomAccessToken() async {
    var url = Uri.https('zoom.us', '/oauth/token');
    String basicAuth = 'Basic ' +
        'SzZqbkxQalI5T21vMjN6UEJBblpnOnBoSHBZb2JwWnNJQ3lqM2NXWVJzNXZtNnpWbnBUNlNM';
    var response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': basicAuth,
    }, body: {
      'grant_type': 'account_credentials',
      'account_id': 'Zy3tSoasQLOwjT6CLWTJsg'
    });
    print("get tokeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeen");
    print('Response vv status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return jsonDecode(response.body);
  }

  createMeeting(zoomAccessToken, String description, String dueDate,
      String hour, String minute, String endHour, String endMinute) async {
    var url = Uri.https('api.zoom.us', '/v2/users/me/meetings');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $zoomAccessToken',
        },
        body: jsonEncode({
          "topic": description,
          "type": 2,
          "start_time": formatDateTimeToUTC(dueDate, hour, minute),
          // "start_time":'2025-02-24T00:42:00Z',

          "duration":
              calculateDurationInMinutes(hour, minute, endHour, endMinute),
          "password": "123456",
          "timezone": "UTC",
          "settings": {
            //"auto_recording": "cloud"
          }
        }));
    print("creare the meeting resojce");
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<void> scheduleZoomMeeting(String description, String dueDate,
      String hour, String minute, String endHour, String endMinute) async {
    this.meetingCreated = false;
    this.token = await this.generateZoomJWT();
    print("2");
    print(token);
    print("3");
    try {
      print("1");
      await zoom.initZoom(ZoomOptions(domain: 'zoom.us', jwtToken: token));
      var newToken = await this.generateZoomAccessToken();
      print("4");
      print(newToken['access_token']);
      print("5");

      this.meeting = await this.createMeeting(newToken['access_token'],
          description, dueDate, hour, minute, endHour, endMinute);
      print("2");
      print(meeting);
      this.startUrl = this.extractTextAfterZak(meeting['start_url']);
      this.joinUrl = meeting['join_url'];
      this.meetingId = meeting['id'].toString();
      this.meetingPasswd = meeting['password'];
      this.meetingCreated = true;
      print("-------------------");
      print(this.meetingId);
      print(startUrl);
      print("---------------------");
    } catch (e) {
      print(e.toString());
    }
  }

  Future startMeet(String description, String liveId) async {
    print("1");

    final String jwtToken = Hive.box(authBoxKey).get(jwtTokenKey) ?? "";
    print("2");
    var response = await http.get(
      Uri.parse('https://solucheonline.com/api/live/${liveId}'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${jwtToken}",
      },
    );
    var decodedRes = json.decode(response.body);
    print("a");
    print(response.statusCode);
    print(response.body);
    print(decodedRes);
    print(decodedRes["data"]['meeting_id']);
    print(decodedRes["data"]['start_url']);
    var id = decodedRes["data"]['meeting_id'];
    var url = decodedRes["data"]['start_url'];
    this.token = await this.generateZoomJWT();
    await zoom.initZoom(ZoomOptions(domain: 'zoom.us', jwtToken: token));
    await zoom.startMeeting(ZoomMeetingOptions(
        meetingId: id,
        // meetingId: '86835722449',
        zoomAccessToken: url,
        // zoomAccessToken: 'eyJ0eXAiOiJKV1QiLCJzdiI6IjAwMDAwMSIsInptX3NrbSI6InptX28ybSIsImFsZyI6IkhTMjU2In0.eyJpc3MiOiJ3ZWIiLCJjbHQiOjAsIm1udW0iOiI4NjgzNTcyMjQ0OSIsImF1ZCI6ImNsaWVudHNtIiwidWlkIjoiZUhGRzcyWHNTbnl5Q3N4RVVpYXNRUSIsInppZCI6IjgyMTljNGU3YzY3NzRhYmE5MTE3Y2EzNjQwNjIwMjIyIiwic2siOiIzNDE2OTYxNzg2NzQ0MjY1MTE0Iiwic3R5IjoxMDAsIndjZCI6InVzMDYiLCJleHAiOjE3NDA2NTQ4MTQsImlhdCI6MTc0MDY0NzYxNCwiYWlkIjoiWnkzdFNvYXNRTE93alQ2Q0xXVEpzZyIsImNpZCI6IiJ9.wVn6rVeonKf5U74xNaynItRXDBPwaj2YdsQCextgl4M',
        displayName: "new meeting",
        disableDialIn: "false",
        disableDrive: "false",
        disableInvite: "false",
        disableShare: "false",
        disableTitlebar: "false",
        viewOptions: "false",
        noAudio: "false",
        noDisconnectAudio: "false"));
  }

  String extractTextAfterZak(String url) {
    int index = url.indexOf('zak=');
    if (index != -1) {
      // Extract the substring after 'zak='
      return url.substring(index + 4);
    } else {
      return ''; // If 'zak=' not found, return an empty string
    }
  }

  Future<List<Live>> getLives({required int subjectId}) async {
    try {
      Map<String, dynamic> body = {
        "subject_id": subjectId,
      };
      final result = await Api.get(
        url: Api.getLives,
        useAuthToken: true,
        body: body,
      );
      return (result['data'] as List)
          .map((live) => Live.fromJson(Map.from(live)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteLive({required int liveId}) async {
    try {
      await Api.delete(
        url: '${Api.deleteLive}/$liveId',
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> toggleLiveStatus({required int liveId}) async {
    try {
      await Api.post(
          url: '${Api.toggleLiveStatus}/$liveId', useAuthToken: true, body: {});
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
