import 'package:eschool_teacher/app/routes.dart';
import 'package:eschool_teacher/cubits/announcementsCubit.dart';
import 'package:eschool_teacher/cubits/lessonsCubit.dart';
import 'package:eschool_teacher/cubits/livesCubit.dart';
import 'package:eschool_teacher/cubits/myClassesCubit.dart';
import 'package:eschool_teacher/cubits/subjectsOfClassSectionCubit.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/repositories/announcementRepository.dart';
import 'package:eschool_teacher/data/repositories/lessonRepository.dart';
import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:eschool_teacher/ui/widgets/announcementsContainer.dart';
import 'package:eschool_teacher/ui/widgets/appBarSubTitleContainer.dart';
import 'package:eschool_teacher/ui/widgets/appBarTitleContainer.dart';
import 'package:eschool_teacher/ui/widgets/customDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/customFloatingActionButton.dart';
import 'package:eschool_teacher/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool_teacher/ui/widgets/customTabBarContainer.dart';
import 'package:eschool_teacher/ui/widgets/lessonsContainer.dart';
import 'package:eschool_teacher/ui/widgets/lives_container.dart';
import 'package:eschool_teacher/ui/widgets/noDataContainer.dart';
import 'package:eschool_teacher/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool_teacher/ui/widgets/svgButton.dart';
import 'package:eschool_teacher/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubjectScreen extends StatefulWidget {
  final Subject subject;
  final ClassSectionDetails classSectionDetails;

  const SubjectScreen({
    super.key,
    required this.subject,
    required this.classSectionDetails,
  });

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LessonsCubit(LessonRepository()),
          ),
          BlocProvider(
            create: (context) => AnnouncementsCubit(AnnouncementRepository()),
          ),
          BlocProvider(
            create: (context) => LivesCubit(LiveRepository()),
          ),
        ],
        child: SubjectScreen(
          classSectionDetails: arguments['classSectionDetails'],
          subject: arguments['subject'],
        ),
      ),
    );
  }
}

class _SubjectScreenState extends State<SubjectScreen> {
  late String _selectedTabTitle = chaptersKey;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_announcementsScrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<LessonsCubit>().fetchLessons(
            classSectionId: widget.classSectionDetails.id,
            subjectId: widget.subject.id,
          );
      context.read<AnnouncementsCubit>().fetchAnnouncements(
            classSectionId: widget.classSectionDetails.id,
            subjectId: widget.subject.id,
          );
      context.read<LivesCubit>().fetchLives(
            subjectId: widget.subject.id,
          );
    });
  }

  void _announcementsScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<AnnouncementsCubit>().hasMore()) {
        context.read<AnnouncementsCubit>().fetchMoreAnnouncements(
              subjectId: widget.subject.id,
              classSectionId: widget.classSectionDetails
                  .id, //widget.classSectionDetails.classTeacherId
            );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_announcementsScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTapFloatingActionAddButton() {
    Navigator.of(context)
        .pushNamed(
      _selectedTabTitle == chaptersKey
          ? Routes.addOrEditLesson
          : _selectedTabTitle == announcementKey
              ? Routes.addOrEditAnnouncement
              : Routes.addLive,
      arguments: _selectedTabTitle == chaptersKey
          ? {
              "subject": widget.subject,
              "classSectionDetails": widget.classSectionDetails
            }
          : _selectedTabTitle == announcementKey
              ? {
                  "subject": widget.subject,
                  "classSectionDetails": widget.classSectionDetails
                }
              : {
                  "subject": widget.subject,
                  "classSectionDetails": widget.classSectionDetails
                },
    )
        .then((value) {
      if (value != null && value is bool && value) {
        //reload after adding new lesson or announcement
        if (_selectedTabTitle == chaptersKey) {
          context.read<LessonsCubit>().fetchLessons(
                classSectionId: widget.classSectionDetails.id,
                subjectId: widget.subject.id,
              );
        } else if (_selectedTabTitle == announcementKey) {
          context.read<AnnouncementsCubit>().fetchAnnouncements(
                classSectionId: widget.classSectionDetails.id,
                subjectId: widget.subject.id,
              );
        } else if (_selectedTabTitle == liveKey) {
          context.read<LivesCubit>().fetchLives(
                subjectId: widget.subject.id,
              );
        }
      }
    });
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: ScreenTopBackgroundContainer(
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: UiUtils.screenContentHorizontalPadding,
                    ),
                    child: SvgButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      svgIconUrl: UiUtils.getImagePath("back_icon.svg"),
                    ),
                  ),
                ),
                AppBarTitleContainer(
                  boxConstraints: boxConstraints,
                  title: widget.subject.showType
                      ? widget.subject.subjectNameWithType
                      : widget.subject.name,
                ),
                AppBarSubTitleContainer(
                  boxConstraints: boxConstraints,
                  subTitle:
                      "${UiUtils.getTranslatedLabel(context, classKey)} ${widget.classSectionDetails.getFullClassSectionName()}",
                ),
                AnimatedAlign(
                  curve: UiUtils.tabBackgroundContainerAnimationCurve,
                  duration: UiUtils.tabBackgroundContainerAnimationDuration,
                  alignment: _selectedTabTitle == chaptersKey
                      ? AlignmentDirectional.centerStart
                      : _selectedTabTitle == announcementKey
                          ? AlignmentDirectional.center
                          : AlignmentDirectional.centerEnd,
                  child: TabBackgroundContainer(
                    boxConstraints: BoxConstraints(
                      maxWidth: boxConstraints.maxWidth * 0.75,
                      maxHeight: boxConstraints.maxHeight,
                    ),
                  ),
                ),
                CustomTabBarContainer(
                  boxConstraints: BoxConstraints(
                    maxWidth: boxConstraints.maxWidth * 0.75,
                    maxHeight: boxConstraints.maxHeight,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  isSelected: _selectedTabTitle == chaptersKey,
                  onTap: () {
                    setState(() {
                      _selectedTabTitle = chaptersKey;
                    });
                  },
                  titleKey: chaptersKey,
                ),
                CustomTabBarContainer(
                  boxConstraints: boxConstraints,
                  alignment: AlignmentDirectional.center,
                  isSelected: _selectedTabTitle == announcementKey,
                  onTap: () {
                    setState(() {
                      _selectedTabTitle = announcementKey;
                    });
                  },
                  titleKey: announcementKey,
                ),
                CustomTabBarContainer(
                  boxConstraints: BoxConstraints(
                    maxWidth: boxConstraints.maxWidth * 0.75,
                    maxHeight: boxConstraints.maxHeight,
                  ),
                  alignment: AlignmentDirectional.centerEnd,
                  isSelected: _selectedTabTitle == liveKey,
                  onTap: () {
                    setState(() {
                      _selectedTabTitle = liveKey;
                    });
                  },
                  titleKey: liveKey,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionAddButton(onTap: _onTapFloatingActionAddButton),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: CustomRefreshIndicator(
              onRefreshCallback: () {
                if (_selectedTabTitle == chaptersKey) {
                  context.read<LessonsCubit>().fetchLessons(
                        classSectionId: widget.classSectionDetails.id,
                        subjectId: widget.subject.id,
                      );
                } else if (_selectedTabTitle == announcementKey) {
                  context.read<AnnouncementsCubit>().fetchAnnouncements(
                        classSectionId: widget.classSectionDetails.id,
                        subjectId: widget.subject.id,
                      );
                } else if (_selectedTabTitle == liveKey) {
                  context.read<LivesCubit>().fetchLives(
                        subjectId: widget.subject.id,
                      );
                }
              },
              displacement: UiUtils.getScrollViewTopPadding(
                context: context,
                appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
              ),
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: UiUtils.getScrollViewBottomPadding(context),
                  top: UiUtils.getScrollViewTopPadding(
                    context: context,
                    appBarHeightPercentage:
                        UiUtils.appBarBiggerHeightPercentage,
                  ),
                ),
                children: [
                  _selectedTabTitle == chaptersKey
                      ? LessonsContainer(
                          classSectionDetails: widget.classSectionDetails,
                          subject: widget.subject,
                        )
                      : _selectedTabTitle == announcementKey
                          ? AnnouncementsContainer(
                              classSectionDetails: widget.classSectionDetails,
                              subject: widget.subject,
                            )
                          : BlocBuilder<LivesCubit, LivesState>(
                              builder: (context, state) {
                              if (state is LivesFetchSuccess) {
                                return state.lives.isEmpty
                                    ? const NoDataContainer(
                                        titleKey: noLivesKey)
                                    : LivesContainer(
                                        subject: widget.subject,
                                        classSectionDetails:
                                            widget.classSectionDetails,
                                     
                                      );
                              }
                              return Container();
                            }),
                ],
              ),
            ),
          ),
          _buildAppBar(),
        ],
      ),
    );
  }
}
