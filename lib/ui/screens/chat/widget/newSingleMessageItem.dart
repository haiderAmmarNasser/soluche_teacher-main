import 'package:any_link_preview/any_link_preview.dart';
import 'package:eschool_teacher/app/routes.dart';
import 'package:eschool_teacher/data/models/message_model/message_model.dart';
import 'package:eschool_teacher/data/models/studyMaterial.dart';
import 'package:eschool_teacher/ui/screens/chat/widget/messageItemComponents.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/customImageWidget.dart';
import 'package:eschool_teacher/utils/constants.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class NewSingleChatMessageItem extends StatefulWidget {
  final MessageModel chatMessage;
  final bool? isLoading;
  final bool? isError;
  final int currentUserId;
  final Function(MessageModel chatMessage)? onRetry;
  final bool showTime;

  const NewSingleChatMessageItem({
    super.key,
    required this.chatMessage,
    this.isLoading,
    this.isError,
    this.onRetry,
    required this.currentUserId,
    this.showTime = true,
  });

  @override
  State<NewSingleChatMessageItem> createState() =>
      _SingleChatMessageItemState();
}

class _SingleChatMessageItemState extends State<NewSingleChatMessageItem> {
  final double _messageItemBorderRadius = 12;

  //note: opacity is used in UI with this color
  final Color _sentMessageBackgroundColor = secondaryColor;

  final Color _receivedMessageBackgroundColor = primaryColor;

  final ValueNotifier _linkAddNotifier = ValueNotifier("");

  @override
  void dispose() {
    _linkAddNotifier.dispose();
    super.dispose();
  }

  Widget _buildTextMessageWidget({
    required BuildContext context,
    required BoxConstraints constraints,
    required MessageModel textMessage,
  }) {
    return Row(
      mainAxisAlignment: textMessage.userId == widget.currentUserId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (textMessage.userId != widget.currentUserId)
          TriangleContainer(
            isFlipped: Directionality.of(context) == TextDirection.rtl,
            size: const Size(10, 10),
            color: _receivedMessageBackgroundColor,
          ),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.8,
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: textMessage.userId == widget.currentUserId
                  ? _sentMessageBackgroundColor.withOpacity(0.05)
                  : _receivedMessageBackgroundColor,
              borderRadius: BorderRadiusDirectional.only(
                topEnd: textMessage.userId == widget.currentUserId
                    ? Radius.zero
                    : Radius.circular(_messageItemBorderRadius),
                topStart: textMessage.userId == widget.currentUserId
                    ? Radius.circular(_messageItemBorderRadius)
                    : Radius.zero,
                bottomEnd: Radius.circular(_messageItemBorderRadius),
                bottomStart: Radius.circular(_messageItemBorderRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: (textMessage.userId == widget.currentUserId)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                //This is preview builder for image
                ValueListenableBuilder(
                    valueListenable: _linkAddNotifier,
                    builder: (context, dynamic value, c) {
                      if (value == null) {
                        return const SizedBox.shrink();
                      }
                      return FutureBuilder(
                        future: AnyLinkPreview.getMetadata(link: value),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data == null) {
                              return const SizedBox.shrink();
                            }
                            return LinkPreviw(
                              snapshot: snapshot,
                              link: value,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    }),
                SelectableText.rich(
                  TextSpan(
                    style: TextStyle(
                      color: textMessage.userId == widget.currentUserId
                          ? Colors.black
                          : Colors.white,
                    ),
                    children: replaceLink(text: textMessage.message ?? '')
                        .map((data) {
                      //This will add link to msg
                      if (isLink(data)) {
                        //This will notify priview object that it has link
                        _linkAddNotifier.value = data;

                        return TextSpan(
                          text: data,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunchUrl(Uri.parse(data))) {
                                await launchUrl(Uri.parse(data),
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor:
                                textMessage.userId == widget.currentUserId
                                    ? Colors.black
                                    : Colors.white,
                            color: textMessage.userId == widget.currentUserId
                                ? Colors.black
                                : Colors.white,
                          ),
                        );
                      }
                      //This will make text bold
                      return TextSpan(
                        text: "",
                        children: matchAstric(data).map((text) {
                          if (text.toString().startsWith("*") &&
                              text.toString().endsWith("*")) {
                            return TextSpan(
                                text: text.replaceAll("*", ""),
                                style: TextStyle(
                                  color:
                                      textMessage.userId == widget.currentUserId
                                          ? Colors.black
                                          : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ));
                          }
                          return TextSpan(
                            text: text,
                            style: TextStyle(
                              color: textMessage.userId == widget.currentUserId
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          );
                        }).toList(),
                        style: TextStyle(
                          color: textMessage.userId == widget.currentUserId
                              ? Colors.black
                              : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: textMessage.userId == widget.currentUserId
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (textMessage.userId == widget.currentUserId)
          TriangleContainer(
            isFlipped: !(Directionality.of(context) == TextDirection.rtl),
            size: const Size(10, 10),
            color: _sentMessageBackgroundColor.withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildImageMessageWidget({
    required BuildContext context,
    required BoxConstraints constraints,
    required MessageModel imageMessage,
  }) {
    return SizedBox(
      width: constraints.maxWidth * 0.45,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            Routes.imageFileView,
            arguments: {
              "studyMaterial":
                  StudyMaterial.fromURL('$baseUrl/${imageMessage.media}'),
              "isFile": false,
              "multiStudyMaterial": <StudyMaterial>[],
              "initialPage": null,
            },
          );
        },
        child: Container(
          width: (constraints.maxWidth * 0.8) / 2 - 10,
          height: (constraints.maxWidth * 0.8) / 2 - 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
              topEnd: imageMessage.userId == widget.currentUserId
                  ? Radius.zero
                  : Radius.circular(_messageItemBorderRadius),
              topStart: imageMessage.userId == widget.currentUserId
                  ? Radius.circular(_messageItemBorderRadius)
                  : Radius.zero,
              bottomEnd: Radius.circular(_messageItemBorderRadius),
              bottomStart: Radius.circular(_messageItemBorderRadius),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomImageWidget(
            isFile: false, //imageMessage.isLocallyStored,
            imagePath: '$baseUrl/${imageMessage.media}',
          ),
        ),
      ),
    );
  }

  Widget _buildFileMessageWidget({
    required BuildContext context,
    required BoxConstraints constraints,
    required MessageModel fileMessage,
  }) {
    final filePath = fileMessage.media!;
    bool isPdf = filePath.split(".").last.toLowerCase() == "pdf";
    return SizedBox(
      width: constraints.maxWidth * 0.7,
      child: GestureDetector(
        onTap: () {
          if (isPdf) {
            Navigator.of(context).pushNamed(
              Routes.pdfFileView,
              arguments: {
                "studyMaterial": StudyMaterial.fromURL('$baseUrl/$filePath'),
              },
            );
          } else {
            UiUtils.openDownloadBottomsheet(
              context: context,
              studyMaterial: StudyMaterial.fromURL('$baseUrl/$filePath'),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
              topEnd: fileMessage.userId == widget.currentUserId
                  ? Radius.zero
                  : Radius.circular(_messageItemBorderRadius),
              topStart: fileMessage.userId == widget.currentUserId
                  ? Radius.circular(_messageItemBorderRadius)
                  : Radius.zero,
              bottomEnd: Radius.circular(_messageItemBorderRadius),
              bottomStart: Radius.circular(_messageItemBorderRadius),
            ),
            color: primaryColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: SvgPicture.asset(
                      UiUtils.getImagePath(isPdf
                          ? "pdf_file_message.svg"
                          : "any_file_message.svg"),
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.maxFinite,
                    color: UiUtils.getColorScheme(context).surface,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      filePath.split("/").last.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.showTime ? 10 : 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.chatMessage.userId != widget.currentUserId)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '${widget.chatMessage.user!.firstName ?? ""} ${widget.chatMessage.user!.lastName ?? ""}',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor.withOpacity(0.4),
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isTextMessage = widget.chatMessage.media == null;
              bool isImage = widget.chatMessage.media != null &&
                  (["jpg", "jpeg", "png"].contains(
                      widget.chatMessage.media!.split(".").last.toLowerCase()));
              return Align(
                alignment: widget.chatMessage.userId == widget.currentUserId
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: isTextMessage
                    ? _buildTextMessageWidget(
                        context: context,
                        constraints: constraints,
                        textMessage: widget.chatMessage,
                      )
                    : isImage
                        ? _buildImageMessageWidget(
                            context: context,
                            constraints: constraints,
                            imageMessage: widget.chatMessage,
                          )
                        : _buildFileMessageWidget(
                            context: context,
                            constraints: constraints,
                            fileMessage: widget.chatMessage,
                          ),
              );
            },
          ),
          if (widget.showTime)
            Align(
              alignment: widget.chatMessage.userId == widget.currentUserId
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: Text(
                UiUtils.formatTimeWithDateTime(
                  widget.chatMessage.createdAt!,
                  is24: false,
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor.withOpacity(0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
