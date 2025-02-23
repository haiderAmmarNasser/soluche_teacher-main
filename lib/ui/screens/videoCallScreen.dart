import 'dart:math';

import 'package:eschool_teacher/cubits/authCubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key, required this.callID});
  final String callID;

  static Route route(RouteSettings routeSettings) {
    final String callID =
        (routeSettings.arguments as Map<String, dynamic>)['callID'];
    return CupertinoPageRoute(
      builder: (_) => VideoCallScreen(callID: callID),
    );
  }

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  String generateRandomNumber() {
    return Random().nextInt(1000000).toString();
  }

  @override
  Widget build(BuildContext context) {
  return Container(
  color: Colors.amber,
  );
    // return ZegoUIKitPrebuiltCall(
    //   appID: int.parse(dotenv.get('ZEGO_APP_ID')),
    //   appSign: dotenv.get('ZEGO_APP_SIGN'),
    //   userID: generateRandomNumber(),
    //   userName: context.read<AuthCubit>().getTeacherDetails().getFullName(),
    //   callID: widget.callID,
      // config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
    // );
  }
}
