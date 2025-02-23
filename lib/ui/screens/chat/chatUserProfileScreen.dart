import 'package:eschool_teacher/data/models/chatUser.dart';
import 'package:eschool_teacher/ui/widgets/customBackButton.dart';
import 'package:eschool_teacher/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool_teacher/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatUserProfileScreen extends StatefulWidget {
  final ChatUser chatUser;
  const ChatUserProfileScreen({super.key, required this.chatUser});

  static route(RouteSettings routeSettings) {
    final ChatUser user =
        (routeSettings.arguments as Map<String, dynamic>?)?["chatUser"] ??
            ChatUser.fromJsonAPI({});
    return CupertinoPageRoute(
      builder: (_) => ChatUserProfileScreen(chatUser: user),
    );
  }

  @override
  State<ChatUserProfileScreen> createState() => _ChatUserProfileScreenState();
}

class _ChatUserProfileScreenState extends State<ChatUserProfileScreen> {
  Widget _buildProfileDetailsTile({
    required String label,
    required String value,
    required String iconUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.5),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1a212121),
                  offset: Offset(0, 10),
                  blurRadius: 16,
                )
              ],
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SvgPicture.asset(iconUrl),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * (0.05),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildSmallChildDetailContainer({required ChildSmallData childDetails}) {
    return Container(
      margin: const EdgeInsets.only(top: 15.0),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12.50, vertical: 15.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: CustomUserProfileImageWidget(
              profileUrl: childDetails.profileUrl,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  childDetails.name,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: UiUtils.screenSubTitleFontSize,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text(
                      UiUtils.getTranslatedLabel(context, classKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Flexible(
                      child: Text(
                        ": ${childDetails.className}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                if (childDetails.subjectsString.isNotEmpty)
                  Text.rich(
                    TextSpan(
                      text:
                          "${UiUtils.getTranslatedLabel(context, subjectsKey)}: ",
                      children: [
                        TextSpan(text: childDetails.subjectsString),
                      ],
                      style: const TextStyle(fontSize: 12),
                    ),
                    maxLines: 10,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: UiUtils.getScrollViewBottomPadding(context),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.3),
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  ScreenTopBackgroundContainer(
                    child: Stack(
                      children: [
                        const CustomBackButton(),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            UiUtils.getTranslatedLabel(context, profileKey),
                            style: TextStyle(
                              fontSize: UiUtils.screenTitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width * (0.3),
                      height: MediaQuery.of(context).size.width * (0.3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CustomUserProfileImageWidget(
                            profileUrl: widget.chatUser.profileUrl),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.chatUser.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              widget.chatUser.isParent
                  ? widget.chatUser.occupation ?? ""
                  : widget.chatUser.className ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (0.075),
              ),
              child: Divider(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (0.075),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      UiUtils.getTranslatedLabel(context, personalDetailsKey),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.chatUser.isParent) ...[
                    _buildProfileDetailsTile(
                      label: UiUtils.getTranslatedLabel(context, emailKey),
                      value:
                          UiUtils.formatEmptyValue(widget.chatUser.email ?? ""),
                      iconUrl: UiUtils.getImagePath("user_pro_icon.svg"),
                    ),
                    _buildProfileDetailsTile(
                      label:
                          UiUtils.getTranslatedLabel(context, phoneNumberKey),
                      value: UiUtils.formatEmptyValue(
                          widget.chatUser.mobileNumber ?? ""),
                      iconUrl: UiUtils.getImagePath("phone-call.svg"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.chatUser.children?.isNotEmpty ?? false)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          UiUtils.getTranslatedLabel(
                              context, childrenDetailsKey),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (widget.chatUser.children?.isNotEmpty ?? false)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            widget.chatUser.children!.length,
                            (index) => _buildSmallChildDetailContainer(
                                childDetails:
                                    widget.chatUser.children![index])),
                      )
                  ] else ...[
                    _buildProfileDetailsTile(
                      label: UiUtils.getTranslatedLabel(context, rollNoKey),
                      value: UiUtils.formatEmptyValue(
                        widget.chatUser.rollNo.toString(),
                      ),
                      iconUrl: UiUtils.getImagePath("user_pro_info.svg"),
                    ),
                    _buildProfileDetailsTile(
                      label: UiUtils.getTranslatedLabel(context, subjectsKey),
                      value: UiUtils.formatEmptyValue(
                        widget.chatUser.subjects,
                      ),
                      iconUrl: UiUtils.getImagePath("user_pro_class_icon.svg"),
                    ),
                    if (widget.chatUser.subjectNames?.isNotEmpty ?? false)
                      _buildProfileDetailsTile(
                        label:
                            UiUtils.getTranslatedLabel(context, dateOfBirthKey),
                        value: DateTime.tryParse(widget.chatUser.dob ?? "") ==
                                null
                            ? widget.chatUser.dob ?? ""
                            : UiUtils.formatDate(
                                DateTime.tryParse(widget.chatUser.dob ?? "")!),
                        iconUrl: UiUtils.getImagePath("user_pro_dob_icon.svg"),
                      ),
                    _buildProfileDetailsTile(
                      label: UiUtils.getTranslatedLabel(context, genderKey),
                      value: UiUtils.formatEmptyValue(
                          widget.chatUser.gender ?? ""),
                      iconUrl: UiUtils.getImagePath("gender.svg"),
                    ),
                    _buildProfileDetailsTile(
                      label: UiUtils.getTranslatedLabel(
                        context,
                        addressKey,
                      ),
                      value: UiUtils.formatEmptyValue(
                          widget.chatUser.address ?? ""),
                      iconUrl:
                          UiUtils.getImagePath("user_pro_address_icon.svg"),
                    ),
                  ],
                  const SizedBox(
                    height: 7.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
