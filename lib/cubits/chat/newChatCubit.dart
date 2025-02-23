import 'package:eschool_teacher/data/models/message_model/message_model.dart';
import 'package:eschool_teacher/data/repositories/newChatRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

abstract class NewChatMessagesState {}

final class NewChatMessagesInitial extends NewChatMessagesState {}

final class NewChatMessagesLoadingState extends NewChatMessagesState {}

final class NewChatMessagesSuccessState extends NewChatMessagesState {
  final int page;
  final List<MessageModel> messages;
  final bool reachedEnd;
  final bool loadingExtra;

  NewChatMessagesSuccessState({
    required this.page,
    required this.messages,
    required this.reachedEnd,
    this.loadingExtra = false,
  });
}

final class NewChatMessagesLoadingPusherState extends NewChatMessagesState {}

final class NewChatMessagesFailureState extends NewChatMessagesState {
  final String errMessage;

  NewChatMessagesFailureState({required this.errMessage});
}

class NewChatMessagesCubit extends Cubit<NewChatMessagesState> {
  NewChatMessagesCubit({
    required this.messagesRepo,
    required this.groupId,
    required this.lessonId,
  }) : super(NewChatMessagesInitial()) {
    fetchMessages();
    initPusher();
  }

  final NewChatRepository messagesRepo;
  final int groupId;
  final int lessonId;
  List<MessageModel> messages = [];

  Future<void> fetchNextPage() async {
    final currentState = state;
    if (currentState is NewChatMessagesSuccessState &&
        !currentState.loadingExtra) {
      int nextPage = currentState.page + 1;

      if (!currentState.reachedEnd) {
        emit(NewChatMessagesSuccessState(
          messages: currentState.messages,
          page: currentState.page,
          reachedEnd: currentState.reachedEnd,
          loadingExtra: true,
        ));

        final result = await messagesRepo.fetchGroupMessages(
          lessonId: lessonId,
          page: nextPage,
        );
        result.fold(
          (failure) => emit(NewChatMessagesFailureState(errMessage: failure)),
          (success) => emit(
            NewChatMessagesSuccessState(
              messages: [...currentState.messages, ...success],
              page: nextPage,
              reachedEnd: success.isEmpty,
            ),
          ),
        );
      }
    }
  }

  Future<void> fetchMessages() async {
    emit(NewChatMessagesLoadingState());

    final result = await messagesRepo.fetchGroupMessages(
      lessonId: lessonId,
      page: 1,
    );
    result.fold(
      (failure) => emit(NewChatMessagesFailureState(errMessage: failure)),
      (success) => emit(NewChatMessagesSuccessState(
        messages: success,
        page: 1,
        reachedEnd: false,
      )),
    );
  }

  // send message
  Future<void> sendMessage({
    String? message,
    List<String>? attachments,
  }) async {
    try {
      await messagesRepo.sendChatMessage(
        message: message,
        groupId: groupId,
        filePaths: attachments ?? [],
      );
    } catch (e) {
      emit(NewChatMessagesFailureState(errMessage: e.toString()));
    }
  }

  
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  // init pusher
  void initPusher() async {
    try {
      await pusher.init(
        apiKey: '1e9c3e31e2e83a5d0fe9',
        cluster: 'ap2',
        onConnectionStateChange: onConnectionStateChange,
        onError: onErrorPusher,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
      );
      await pusher.subscribe(channelName: 'chat');
      await pusher.connect();
      developer.log('connected');
    } catch (e) {
      developer.log("ERROR: $e");
    }
  }

  void onEvent(PusherEvent event) {
    developer.log("onEvent: $event");
    developer.log("onEventData: ${event.data}");
    if (event.data != null) {
      developer.log('condition true');
      Map<String, dynamic> data = jsonDecode(event.data.toString());
      if (data['message'] != null && data['groupId'] == groupId) {
        developer.log("data: ${data['message']}");
        MessageModel newMessage = MessageModel.fromJson(data['message']);
        developer.log('message: $newMessage');
        final currentState = state;
        if (currentState is NewChatMessagesSuccessState) {
          developer.log('currentState: $currentState');
          emit(NewChatMessagesLoadingPusherState());
          emit(NewChatMessagesSuccessState(
            messages: [newMessage, ...currentState.messages],
            page: currentState.page,
            reachedEnd: currentState.reachedEnd,
          ));
        }
      }
    } else {
      developer.log('condition false');
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    developer.log("Connection: $currentState");
  }

  void onErrorPusher(String message, int? code, dynamic e) {
    developer.log("onError: $message code: $code exception: $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    developer.log("onSubscriptionSucceeded: $channelName data: $data");
  }

  void onSubscriptionError(String message, dynamic e) {
    developer.log("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    developer.log("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    developer.log("onMemberAdded: $channelName member: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    developer.log("onMemberRemoved: $channelName member: $member");
  }
}
