import 'dart:math';
import 'package:eschool_teacher/app/routes.dart';
// import 'package:eschool/cubits/chat/chatMessagesCubit.dart';
import 'package:eschool_teacher/cubits/chat/newChatCubit.dart';
import 'package:eschool_teacher/data/models/group_model.dart';
import 'package:eschool_teacher/data/repositories/newChatRepository.dart';
import 'package:eschool_teacher/ui/screens/chat/widget/attachmentDialog.dart';
import 'package:eschool_teacher/ui/screens/chat/widget/messageSendingWidget.dart';
import 'package:eschool_teacher/ui/screens/chat/widget/newSingleMessageItem.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/customBackButton.dart';
import 'package:eschool_teacher/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_teacher/ui/widgets/customShimmerContainer.dart';
import 'package:eschool_teacher/ui/widgets/errorContainer.dart';
import 'package:eschool_teacher/ui/widgets/noDataContainer.dart';
import 'package:eschool_teacher/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool_teacher/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool_teacher/utils/animationConfiguration.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/notificationUtils/chatNotificationsUtils.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:eschool_teacher/cubits/authCubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NewChatMessagesScreen extends StatefulWidget {
  final GroupModel group;
  final int lessonId;
  const NewChatMessagesScreen({
    super.key,
    required this.group,
    required this.lessonId,
  });

  @override
  State<NewChatMessagesScreen> createState() => _NewChatMessagesScreenState();

  static route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider<NewChatMessagesCubit>(
        create: (context) => NewChatMessagesCubit(
          lessonId: arguments['lessonId'] as int,
          groupId: (arguments['group'] as GroupModel).id!,
          messagesRepo: NewChatRepository(),
        ),
        child: NewChatMessagesScreen(
          group: arguments['group'] as GroupModel,
          lessonId: arguments['lessonId'] as int,
        ),
      ),
    );
  }
}

class _NewChatMessagesScreenState extends State<NewChatMessagesScreen> {
  final ValueNotifier<bool> _isAttachmentDialogOpen = ValueNotifier(false);
  final _chatMessageSendTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<NewChatMessagesCubit>().fetchNextPage();
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchChatMessages();
      context.read<AuthCubit>().getTeacherDetails().userId;
    });
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _isAttachmentDialogOpen.dispose();
    _chatMessageSendTextController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchChatMessages() {
    context.read<NewChatMessagesCubit>().fetchMessages();
  }

  Widget _buildAppBar(BuildContext context) {
    return ScreenTopBackgroundContainer(
      heightPercentage: 0.13,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomBackButton(
            onTap: () {
              if (_isAttachmentDialogOpen.value) {
                _isAttachmentDialogOpen.value = false;
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const Spacer(flex: 2),
          Text(
            widget.group.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: UiUtils.screenTitleFontSize,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return SizedBox(
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                UiUtils.defaultChatShimmerLoaders,
                (index) => _buildOneChatShimmerLoader(boxConstraints),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOneChatShimmerLoader(BoxConstraints boxConstraints) {
    final bool isStart = Random().nextBool();
    return Align(
      alignment: isStart
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: ShimmerLoadingContainer(
          child: CustomShimmerContainer(
            height: 30,
            width: boxConstraints.maxWidth * 0.8,
            customBorderRadius: BorderRadiusDirectional.only(
              topStart: isStart ? Radius.zero : const Radius.circular(12),
              topEnd: isStart ? const Radius.circular(12) : Radius.zero,
              bottomEnd: const Radius.circular(12),
              bottomStart: const Radius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateLabel({required DateTime date}) {
    return Text(
      date.isToday()
          ? UiUtils.getTranslatedLabel(context, todayKey)
          : date.isYesterday()
              ? UiUtils.getTranslatedLabel(context, yesterdayKey)
              : date.isCurrentYear()
                  ? DateFormat("dd MMMM").format(date)
                  : DateFormat("dd MMM yyyy").format(date),
      style: TextStyle(
        color: secondaryColor.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }

  Widget _loadingMoreChatsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: secondaryColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CustomCircularProgressIndicator(
              indicatorColor: primaryColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Text(
              UiUtils.getTranslatedLabel(context, loadingMoreChatsKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        //removing currently talking user's id
        ChatNotificationsUtils.currentChattingUserId = null;
        //clearing current route when going back to make the onTap of notification routing properly work
        Routes.currentRoute = "";
        if (_isAttachmentDialogOpen.value) {
          _isAttachmentDialogOpen.value = false;
        } else {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  bottom: 10, start: 15, end: 15),
              child: BlocBuilder<NewChatMessagesCubit, NewChatMessagesState>(
                builder: (context, state) {
                  if (state is NewChatMessagesSuccessState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.loadingExtra)
                          Padding(
                            padding: EdgeInsets.only(
                              top: UiUtils.getScrollViewTopPadding(
                                context: context,
                                appBarHeightPercentage: 0.12,
                              ),
                              bottom: 10,
                            ),
                            child: Center(child: _loadingMoreChatsWidget()),
                          ),
                        Expanded(
                          child: state.messages.isEmpty
                              ? ListView(
                                  children: const [
                                    NoDataContainer(
                                      titleKey: noChatsWithUserKey,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  padding: EdgeInsets.only(
                                    top: UiUtils.getScrollViewTopPadding(
                                      context: context,
                                      appBarHeightPercentage: 0.13,
                                    ),
                                  ),
                                  itemCount: state.messages.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        //if it's 1st item - reverse scroll so last then show date label
                                        //or if an item's date is not the same as next item, show date label
                                        if (index == (state.messages.length - 1) ||
                                            (!(state.messages[index].createdAt!
                                                .isSameAs(state
                                                    .messages[index ==
                                                            (state.messages
                                                                    .length -
                                                                1)
                                                        ? (state.messages
                                                                .length -
                                                            1)
                                                        : index + 1]
                                                    .createdAt!))))
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: _buildDateLabel(
                                                  date: state.messages[index]
                                                      .createdAt!),
                                            ),
                                          ),
                                        NewSingleChatMessageItem(
                                          key: ValueKey(
                                              state.messages[index].id),
                                          currentUserId: context
                                              .read<AuthCubit>()
                                              .getTeacherDetails()
                                              .userId,
                                          chatMessage: state.messages[index],
                                        ),
                                        if (index == 0)
                                          const SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder<bool>(
                              valueListenable: _isAttachmentDialogOpen,
                              builder: (context, value, child) => value
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Animate(
                                        effects:
                                            customItemFadeAppearanceEffects(),
                                        child: AttachmentDialogWidget(
                                          onCancel: () {
                                            _isAttachmentDialogOpen.value =
                                                false;
                                          },
                                          onItemSelected:
                                              (selectedFilePaths, isImage) {
                                            _isAttachmentDialogOpen.value =
                                                false;
                                            context
                                                .read<NewChatMessagesCubit>()
                                                .sendMessage(
                                                  attachments:
                                                      selectedFilePaths,
                                                );
                                          },
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            ChatMessageSendingWidget(
                              backgroundColor: primaryColor.withOpacity(0.25),
                              onMessageSend: () {
                                if (_chatMessageSendTextController.text
                                    .trim()
                                    .isNotEmpty) {
                                  context
                                      .read<NewChatMessagesCubit>()
                                      .sendMessage(
                                        message:
                                            _chatMessageSendTextController.text,
                                      );
                                  _chatMessageSendTextController.clear();
                                }
                              },
                              onAttachmentTap: () {
                                _isAttachmentDialogOpen.value =
                                    !_isAttachmentDialogOpen.value;
                                //if attachment adding is being shown, hide the keyboard
                                if (_isAttachmentDialogOpen.value) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              },
                              textController: _chatMessageSendTextController,
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  if (state is NewChatMessagesFailureState) {
                    return Center(
                      child: ErrorContainer(
                        errorMessageCode: state.errMessage,
                        onTapRetry: () => fetchChatMessages(),
                      ),
                    );
                  }
                  return _buildShimmerLoader();
                },
              ),
            ),
            Align(alignment: Alignment.topCenter, child: _buildAppBar(context)),
          ],
        ),
      ),
    );
  }
}
