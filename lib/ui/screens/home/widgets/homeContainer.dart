import 'package:eschool_teacher/app/routes.dart';
import 'package:eschool_teacher/cubits/authCubit.dart';
import 'package:eschool_teacher/cubits/chat/chatUsersCubit.dart';
import 'package:eschool_teacher/cubits/myClassesCubit.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool_teacher/ui/widgets/customShimmerContainer.dart';
import 'package:eschool_teacher/ui/widgets/errorContainer.dart';
import 'package:eschool_teacher/ui/widgets/noDataContainer.dart';
import 'package:eschool_teacher/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool_teacher/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool_teacher/utils/animationConfiguration.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({Key? key}) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  List<MenuContainerDetails> _menuItems = [];
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<MyClassesCubit>().fetchMyClasses();
    });
    super.initState();
  }

  TextStyle _titleFontStyle() {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 17.0,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildMyClassesLabel() {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            UiUtils.getTranslatedLabel(context, myClassesKey),
            style: _titleFontStyle(),
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget _buildTopProfileContainer(BuildContext context) {
    return ScreenTopBackgroundContainer(
      padding: const EdgeInsets.all(0),
      heightPercentage: UiUtils.appBarMediumHeightPercentage,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              //Bordered circles
              PositionedDirectional(
                top: MediaQuery.of(context).size.width * (-0.15),
                start: MediaQuery.of(context).size.width * (-0.225),
                child: Container(
                  padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.1),
                    ),
                    shape: BoxShape.circle,
                  ),
                  width: MediaQuery.of(context).size.width * (0.6),
                  height: MediaQuery.of(context).size.width * (0.6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.1),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              //bottom fill circle
              // PositionedDirectional(
              //   bottom: MediaQuery.of(context).size.width * (-0.15),
              //   end: MediaQuery.of(context).size.width * (-0.15),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Theme.of(context)
              //           .scaffoldBackgroundColor
              //           .withOpacity(0.1),
              //       shape: BoxShape.circle,
              //     ),
              //     width: MediaQuery.of(context).size.width * (0.4),
              //     height: MediaQuery.of(context).size.width * (0.4),
              //   ),
              // ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                    start: boxConstraints.maxWidth * (0.05),
                    bottom: boxConstraints.maxHeight * (0.1),
                    end: boxConstraints.maxWidth * (0.05),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2.0,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        width: boxConstraints.maxWidth * (0.175),
                        height: boxConstraints.maxWidth * (0.175),
                        child: CustomUserProfileImageWidget(
                          profileUrl: context
                              .read<AuthCubit>()
                              .getTeacherDetails()
                              .image,
                        ),
                      ),
                      SizedBox(
                        width: boxConstraints.maxWidth * (0.05),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context
                                  .read<AuthCubit>()
                                  .getTeacherDetails()
                                  .getFullName(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // _buildChatIcon(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassShimmerLoading(BoxConstraints boxConstraints) {
    return ShimmerLoadingContainer(
      child: CustomShimmerContainer(
        height: 100,
        borderRadius: 10,
        width: boxConstraints.maxWidth * (0.45),
      ),
    );
  }

  Widget _buildClassContainer({
    required BoxConstraints boxConstraints,
    required ClassSectionDetails classSectionDetails,
    required int index,
    required bool isClassTeacher,
  }) {
    return Animate(
      effects: customItemZoomAppearanceEffects(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.classScreen,
              arguments: {
                "isClassTeacher": isClassTeacher,
                "classSection": classSectionDetails
              },
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              //Displaying different(4) class color
              color: UiUtils.getClassColor(index),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: UiUtils.getClassColor(index).withOpacity(0.2),
                  offset: const Offset(0, 2.5),
                )
              ],
            ),
            width: boxConstraints.maxWidth * 0.46,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 5,
                      left: 2,
                      right: 2,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          classSectionDetails.getClassSectionName(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${classSectionDetails.classDetails.medium.name} ${UiUtils.getTranslatedLabel(context, "medium")}${classSectionDetails.classDetails.shift != null ? '\n${classSectionDetails.classDetails.shift!.title} ${UiUtils.getTranslatedLabel(context, "shift")}' : ''}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: (boxConstraints.maxWidth * 0.225) - 15, //0.45
                  child: Container(
                    alignment: Alignment.center,
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 20,
                        )
                      ],
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyClasses() {
    final classes = context.read<MyClassesCubit>().classes();
    return classes.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMyClassesLabel(),
              LayoutBuilder(
                builder: (context, boxConstraints) {
                  return Wrap(
                    spacing: boxConstraints.maxWidth * (0.07),
                    runSpacing: boxConstraints.maxWidth * (0.07),
                    children: List.generate(classes.length, (index) => index)
                        .map(
                          (index) => _buildClassContainer(
                            boxConstraints: boxConstraints,
                            classSectionDetails: classes[index],
                            index: index,
                            isClassTeacher: false,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
  }

  Widget _buildClassTeacherLabel() {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            UiUtils.getTranslatedLabel(context, classTeacherKey),
            style: _titleFontStyle(),
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget _buildClassTeacher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClassTeacherLabel(),
        LayoutBuilder(
          builder: (context, boxConstraints) {
            final primaryClass = context.read<MyClassesCubit>().primaryClass();
            return Wrap(
              spacing: boxConstraints.maxWidth * (0.07),
              runSpacing: boxConstraints.maxWidth * (0.07),
              children: List.generate(primaryClass!.length, (index) => index)
                  .map(
                    (index) => _buildClassContainer(
                      boxConstraints: boxConstraints,
                      classSectionDetails: primaryClass[index],
                      index: index,
                      isClassTeacher: true,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuContainer({
    required int itemIndex,
  }) {
    return Animate(
      effects: listItemAppearanceEffects(
          itemIndex: itemIndex, totalLoadedItems: _menuItems.length),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).pushNamed(_menuItems[itemIndex].route);
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.25),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.225),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      width: boxConstraints.maxWidth * (0.225),
                      child: SvgPicture.asset(_menuItems[itemIndex].iconPath),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      _menuItems[itemIndex].title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      radius: 17.5,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 22.5,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformationAndMenuLabel() {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            UiUtils.getTranslatedLabel(context, informationKey),
            style: _titleFontStyle(),
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget _buildInformationShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      height: 80,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Row(
            children: [
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  height: 60,
                  width: boxConstraints.maxWidth * (0.225),
                ),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.05),
              ),
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  width: boxConstraints.maxWidth * (0.475),
                ),
              ),
              const Spacer(),
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  borderRadius: boxConstraints.maxWidth * (0.035),
                  height: boxConstraints.maxWidth * (0.07),
                  width: boxConstraints.maxWidth * (0.07),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInformationAndMenu() {
    return Column(
      children: [
        _buildInformationAndMenuLabel(),
        ...List.generate(_menuItems.length,
            (index) => _buildMenuContainer(itemIndex: index)),
      ],
    );
  }

  Widget _buildChatIcon() {
    return BlocBuilder<ParentChatUserCubit, ChatUsersState>(
      builder: (context, stateParentChats) {
        return BlocBuilder<StudentChatUsersCubit, ChatUsersState>(
          builder: (context, stateChildChats) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.chatUserPage);
              },
              child: SizedBox(
                height: 40,
                width: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      UiUtils.getImagePath("chat_icon.svg"),
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    //notification count showing on top of the icon
                    if (stateParentChats is ChatUsersFetchSuccess &&
                        stateChildChats is ChatUsersFetchSuccess &&
                        stateParentChats.totalUnreadUsers +
                                stateChildChats.totalUnreadUsers !=
                            0)
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: redColor,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            stateParentChats.totalUnreadUsers +
                                        stateChildChats.totalUnreadUsers >
                                    9
                                ? "9+"
                                : (stateParentChats.totalUnreadUsers +
                                        stateChildChats.totalUnreadUsers)
                                    .toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: RefreshIndicator(
            displacement: UiUtils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: UiUtils.appBarMediumHeightPercentage,
            ),
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () {
              context.read<MyClassesCubit>().fetchMyClasses();
              return Future.value();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * (0.075),
                right: MediaQuery.of(context).size.width * (0.075),
                bottom: UiUtils.getScrollViewBottomPadding(context),
                top: UiUtils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: UiUtils.appBarMediumHeightPercentage,
                ),
              ),
              child: BlocBuilder<MyClassesCubit, MyClassesState>(
                builder: (context, state) {
                  if (state is MyClassesFetchSuccess) {
                    _menuItems = [
                      MenuContainerDetails(
                        route: Routes.assignments,
                        iconPath: UiUtils.getImagePath("assignment_icon.svg"),
                        title:
                            UiUtils.getTranslatedLabel(context, assignmentsKey),
                      ),
                      MenuContainerDetails(
                        route: Routes.announcements,
                        iconPath: UiUtils.getImagePath("announcment_icon.svg"),
                        title: UiUtils.getTranslatedLabel(
                            context, announcementsKey),
                      ),
                      MenuContainerDetails(
                        route: Routes.lessons,
                        iconPath: UiUtils.getImagePath("lesson.svg"),
                        title: UiUtils.getTranslatedLabel(context, chaptersKey),
                      ),
                      MenuContainerDetails(
                        route: Routes.topics,
                        iconPath: UiUtils.getImagePath("topics.svg"),
                        title: UiUtils.getTranslatedLabel(context, topicsKey),
                      ),
                      MenuContainerDetails(
                        route: Routes.academicCalendar,
                        iconPath: UiUtils.getImagePath("holiday_icon.svg"),
                        title: UiUtils.getTranslatedLabel(
                            context, academicCalendarKey),
                      ),
                      MenuContainerDetails(
                        route: Routes.exams,
                        iconPath: UiUtils.getImagePath("exam_icon.svg"),
                        title: UiUtils.getTranslatedLabel(context, examsKey),
                      ),
                      if (context.read<MyClassesCubit>().primaryClass() != null)
                        MenuContainerDetails(
                          route: Routes.addResultForAllStudents,
                          iconPath: UiUtils.getImagePath("result_icon.svg"),
                          title:
                              UiUtils.getTranslatedLabel(context, addResultKey),
                        ),
                      MenuContainerDetails(
                        route: Routes.manageLeaves,
                        iconPath: UiUtils.getImagePath("manage_leaves.svg"),
                        title: UiUtils.getTranslatedLabel(
                            context, manageLeavesKey),
                      ),
                    ];
                    final primaryClass = state.primaryClass;
                    if (primaryClass == null && state.classes.isEmpty) {
                      return Center(
                        child: NoDataContainer(
                          titleKey: noClassAssignedKey,
                          showRetryButton: true,
                          onTapRetry: () {
                            context.read<MyClassesCubit>().fetchMyClasses();
                          },
                        ),
                      );
                    }
                    return Column(
                      children: [
                        _buildMyClasses(),
                        const SizedBox(
                          height: 20.0,
                        ),
                        if (primaryClass != null) _buildClassTeacher(),
                        if (primaryClass != null)
                          const SizedBox(
                            height: 20.0,
                          ),
                        _buildInformationAndMenu()
                      ],
                    );
                  }
                  if (state is MyClassesFetchFailure) {
                    return Center(
                      child: ErrorContainer(
                        errorMessageCode: state.errorMessage,
                        onTapRetry: () {
                          context.read<MyClassesCubit>().fetchMyClasses();
                        },
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, boxConstraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMyClassesLabel(),
                          Wrap(
                            spacing: boxConstraints.maxWidth * (0.07),
                            runSpacing: boxConstraints.maxWidth * (0.07),
                            children: List.generate(
                              UiUtils.defaultShimmerLoadingContentCount,
                              (index) => index,
                            )
                                .map(
                                  (index) =>
                                      _buildClassShimmerLoading(boxConstraints),
                                )
                                .toList(),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          _buildClassTeacherLabel(),
                          Wrap(
                            spacing: boxConstraints.maxWidth * (0.07),
                            runSpacing: boxConstraints.maxWidth * (0.07),
                            children: List.generate(
                              2,
                              (index) => index,
                            )
                                .map(
                                  (index) =>
                                      _buildClassShimmerLoading(boxConstraints),
                                )
                                .toList(),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          _buildInformationAndMenuLabel(),
                          ...List.generate(
                            UiUtils.defaultShimmerLoadingContentCount,
                            (index) => index,
                          ).map(
                            (e) => _buildInformationShimmerLoadingContainer(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildTopProfileContainer(context),
        ),
      ],
    );
  }
}

//class to maintain details required by each menu items
class MenuContainerDetails {
  String iconPath;
  String title;
  String route;
  Object? arguments;

  MenuContainerDetails({
    required this.iconPath,
    required this.title,
    required this.route,
    this.arguments,
  });
}
