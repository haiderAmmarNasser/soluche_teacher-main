import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:eschool_teacher/data/models/message_model/message_model.dart';
import 'package:eschool_teacher/utils/api.dart';
import 'package:eschool_teacher/utils/constants.dart';
import 'package:flutter/foundation.dart';

class NewChatRepository {
  Future<Either<String, List<MessageModel>>> fetchGroupMessages({
    required int lessonId,
    required int page,
  }) async {
    try {
      final result = await Api.get(
        url: '${databaseUrl}group-chat/$lessonId/getGroupsByLessonId',
        useAuthToken: true,
        queryParameters: {
          "page": page,
          "pageSize": offsetLimitPaginationAPIDefaultItemFetchLimit,
        },
      );

      List<MessageModel> messages = [];
      for (var message in result['messages']['data']) {
        messages.add(MessageModel.fromJson(message));
      }

      return Right(messages);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return Left(error.toString());
    }
  }

  Future<void> sendChatMessage({
    String? message,
    List<String> filePaths = const [],
    required int groupId,
  }) async {
    try {
      List<MultipartFile> files = [];
      for (var filePath in filePaths) {
        files.add(await MultipartFile.fromFile(filePath));
      }
      await Api.post(
        url: '${databaseUrl}group-chat/$groupId/send-message',
        useAuthToken: true,
        body: {
          "message": message ?? '.',
          if (filePaths.isNotEmpty) "media": files.first, // TODO: handle multiple files
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
