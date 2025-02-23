// import 'package:eschool_teacher/data/models/live.dart';
// import 'package:eschool_teacher/utils/api.dart';

// class LiveRepository {

//   Future<void> createLive({
//     required int subjectId,
//     required String liveDescription,
//     required List<Map<String, dynamic>> files,
//     required String date,
//     required String fromTime,
//     required String toTime,
//   }) async {
//     try {

//       Map<String, dynamic> body = {
//         "subject_id": subjectId,
//         "description": liveDescription,
//         "date": date,
//         "from": fromTime,
//         "to": toTime,
//       };

//       if (files.isNotEmpty) {
//         body['files'] = files;
//       }

//       await Api.post(body: body, url: Api.createLive, useAuthToken: true);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }

//   Future<List<Live>> getLives({required int subjectId}) async {
//     try {
//       Map<String, dynamic> body = {
//         "subject_id": subjectId,
//       };
//       final result = await Api.get(
//         url: Api.getLives,
//         useAuthToken: true,
//         body: body,
//       );
//       return (result['data'] as List)
//           .map((live) => Live.fromJson(Map.from(live)))
//           .toList();
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }

//   Future<void> deleteLive({required int liveId}) async {
//     try {
//       await Api.delete(
//         url: '${Api.deleteLive}/$liveId',
//         useAuthToken: true,
//       );
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }

//   Future<void> toggleLiveStatus({required int liveId}) async {
//     try {
//       await Api.post(
//         url: '${Api.toggleLiveStatus}/$liveId',
//         useAuthToken: true,
//         body: {}
//       );
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
// }
import 'dart:convert';

import 'package:eschool_teacher/data/models/live.dart';
import 'package:eschool_teacher/utils/api.dart';
import 'package:flutter_zoom_meeting/zoom_options.dart';
import 'package:flutter_zoom_meeting/zoom_view.dart'; // Import Zoom package
import 'package:jose/jose.dart';

class LiveRepository {
  // Function to create live session
  Future<void> createLive({
    required int subjectId,
    required String liveDescription,
    required List<Map<String, dynamic>> files,
    required String date,
    required String fromTime,
    required String toTime,
  }) async {
    try {
      Map<String, dynamic> body = {
        "subject_id": subjectId,
        "description": liveDescription,
        "date": date,
        "from": fromTime,
        "to": toTime,
      };

      if (files.isNotEmpty) {
        body['files'] = files;
      }
      await this.scheduleZoomMeeting();
      await Api.post(body: body, url: Api.createLive, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

// Future<String?> getZoomAccessToken(String token) async {
//   final url = Uri.parse('https://zoom.us/oauth/token');

//   // Base64 encode the client_id:client_secret
//   // final credentials = base64Encode(utf8.encode('K6jnLPjR9Omo23zPBAnZg:phHpYobpZsICyj3cWYRs5vm6zVnpT6SL'));
//   final credentials ='SzZqbkxQalI5T21vMjN6UEJBblpnOnBoSHBZb2JwWnNJQ3lqM2NXWVJzNXZtNnpWbnBUNlNM';

//   final headers = {
//     'Authorization': 'Basic $credentials',
//     'Content-Type': 'application/x-www-form-urlencoded',
//     'Accept': 'application/json',
//   };

//   final body = {
//     'grant_type': 'client_credentials', // or 'client_credentials'
//     // 'code': token,
//     // 'redirect_uri': 'com.dcs.soluche://zoom-callback',
//   };

//   print('Sending request to Zoom OAuth endpoint...');
//   print('Headers: $headers');
//   print('Body: $body');

//   final response = await http.post(
//     url,
//     headers: headers,
//     body: body,
//   );

//   print('Response Status Code: ${response.statusCode}');
//   print('Response Body: ${response.body}');

//   if (response.statusCode == 200) {
//     final responseData = json.decode(response.body);
//     return responseData['access_token']; // This will be your access token
//   } else {
//     print('Failed to get access token: ${response.body}');
//     return null;
//   }
// }

  // Function to schedule Zoom meeting with only required params

  String generateJwtToken() {
    print("1");
    // Create the JWT claims
    final claims = JsonWebTokenClaims.fromJson({
      'iss': 'K6jnLPjR9Omo23zPBAnZg',
      'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000, // Expiration time
    });

    // Create the JWT builder
    final builder = JsonWebSignatureBuilder()
      ..jsonContent = claims.toJson()
      ..addRecipient(
        JsonWebKey.fromJson({
          'kty': 'oct',
          'k': base64Url.encode(utf8.encode(
              'phHpYobpZsICyj3cWYRs5vm6zVnpT6SL')), // Your Zoom client secret
        }),
        algorithm: 'HS256',
      );

    // Build the JWT token
    final token = builder.build().toCompactSerialization();
    print("2");
    print(token);
    print("3");
    return token;
  }

  Future<void> scheduleZoomMeeting() async {
    ZoomView zoom = ZoomView();
    var token = await this.generateJwtToken();
  
    try {
      print("1");
      zoom.initZoom(ZoomOptions(domain: 'zoom.us', jwtToken: token));
      zoom.startMeeting(ZoomMeetingOptions());
      print("2");
    } catch (e) {
      print(e.toString());
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
