import 'package:eschool_teacher/cubits/authCubit.dart';
import 'package:eschool_teacher/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool_teacher/ui/widgets/dynamicFieldListContainer.dart';
import 'package:eschool_teacher/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileContainer extends StatefulWidget {
  const ProfileContainer({super.key});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
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
                    value.trim().isEmpty ? "-" : value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final teacher = context.read<AuthCubit>().getTeacherDetails();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: UiUtils.getScrollViewBottomPadding(context),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.325),
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  ScreenTopBackgroundContainer(
                    child: Stack(
                      children: [
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
                            profileUrl: teacher.image),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              teacher.getFullName(),
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
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(context, emailKey),
                    value: teacher.email,
                    iconUrl: UiUtils.getImagePath("user_pro_icon.svg"),
                  ),
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(context, phoneNumberKey),
                    value: teacher.mobile,
                    iconUrl: UiUtils.getImagePath("phone-call.svg"),
                  ),
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(context, dateOfBirthKey),
                    value: DateTime.tryParse(teacher.dob) == null
                        ? teacher.dob
                        : UiUtils.formatDate(DateTime.tryParse(teacher.dob)!),
                    iconUrl: UiUtils.getImagePath("user_pro_dob_icon.svg"),
                  ),
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(context, genderKey),
                    value: teacher.gender,
                    iconUrl: UiUtils.getImagePath("gender.svg"),
                  ),
                  _buildProfileDetailsTile(
                    label:
                        UiUtils.getTranslatedLabel(context, qualificationKey),
                    value: teacher.qualification,
                    iconUrl: UiUtils.getImagePath("qualification.svg"),
                  ),
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(
                      context,
                      currentAddressKey,
                    ),
                    value: teacher.currentAddress,
                    iconUrl: UiUtils.getImagePath("user_pro_address_icon.svg"),
                  ),
                  _buildProfileDetailsTile(
                    label: UiUtils.getTranslatedLabel(
                      context,
                      permanentAddressKey,
                    ),
                    value: teacher.permanentAddress,
                    iconUrl: UiUtils.getImagePath("user_pro_address_icon.svg"),
                  ),
                  if (teacher.dynamicFields?.isNotEmpty ?? false) ...[
                    Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.75),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    DynamicFieldListContainer(
                      dynamicFields: teacher.dynamicFields!,
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
