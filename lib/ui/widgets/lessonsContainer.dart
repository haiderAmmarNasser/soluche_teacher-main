import 'package:eschool_teacher/app/routes.dart';
import 'package:eschool_teacher/cubits/lessonDeleteCubit.dart';
import 'package:eschool_teacher/cubits/lessonsCubit.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/lesson.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/repositories/lessonRepository.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/attachmentsBottomsheetContainer.dart';
import 'package:eschool_teacher/ui/widgets/confirmDeleteDialog.dart';
import 'package:eschool_teacher/ui/widgets/customShimmerContainer.dart';
import 'package:eschool_teacher/ui/widgets/deleteButton.dart';
import 'package:eschool_teacher/ui/widgets/editButton.dart';
import 'package:eschool_teacher/ui/widgets/errorContainer.dart';
import 'package:eschool_teacher/ui/widgets/noDataContainer.dart';
import 'package:eschool_teacher/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool_teacher/utils/animationConfiguration.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonsContainer extends StatelessWidget {
  final ClassSectionDetails classSectionDetails;
  final Subject subject;

  const LessonsContainer({
    super.key,
    required this.classSectionDetails,
    required this.subject,
  });

  Widget _buildLessonDetailsShimmerContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        width: MediaQuery.of(context).size.width * (0.85),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.7),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.5),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.7),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    margin: EdgeInsetsDirectional.only(
                      end: boxConstraints.maxWidth * (0.5),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLessonDetailsContainer({
    required Lesson lesson,
    required BuildContext context,
  }) {
    return BlocProvider<LessonDeleteCubit>(
      create: (context) => LessonDeleteCubit(LessonRepository()),
      child: Builder(
        builder: (context) {
          return BlocConsumer<LessonDeleteCubit, LessonDeleteState>(
            listener: (context, state) {
              if (state is LessonDeleteSuccess) {
                context.read<LessonsCubit>().deleteLesson(lesson.id);
              } else if (state is LessonDeleteFailure) {
                UiUtils.showBottomToastOverlay(
                  context: context,
                  errorMessage:
                      "${UiUtils.getTranslatedLabel(context, unableToDeleteLessonKey)} ${lesson.name}",
                  backgroundColor: Theme.of(context).colorScheme.error,
                );
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Opacity(
                  opacity: state is LessonDeleteInProgress ? 0.5 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    width: MediaQuery.of(context).size.width * (0.85),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              UiUtils.getTranslatedLabel(
                                context,
                                chapterNameKey,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.newChatMessages,
                                  arguments: {
                                    "lessonId": lesson.id,
                                    "group": lesson.group.first,
                                  },
                                );
                              },
                              child: Icon(
                                Icons.chat,
                                size: 22.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            EditButton(
                              onTap: () {
                                if (state is LessonDeleteInProgress) {
                                  return;
                                }
                                Navigator.of(context).pushNamed<bool?>(
                                  Routes.addOrEditLesson,
                                  arguments: {
                                    "lesson": lesson,
                                    "subject": subject,
                                    "classSectionDetails": classSectionDetails
                                  },
                                ).then((value) {
                                  if (value != null && value) {
                                    context.read<LessonsCubit>().fetchLessons(
                                          classSectionId:
                                              classSectionDetails.id,
                                          subjectId: subject.id,
                                        );
                                  }
                                });
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            DeleteButton(
                              onTap: () {
                                if (state is LessonDeleteInProgress) {
                                  return;
                                }
                                showDialog<bool>(
                                  context: context,
                                  builder: (_) => const ConfirmDeleteDialog(),
                                ).then((value) {
                                  if (value != null && value) {
                                    context
                                        .read<LessonDeleteCubit>()
                                        .deleteLesson(lesson.id);
                                  }
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 2.5,
                        ),
                        Text(
                          lesson.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          UiUtils.getTranslatedLabel(
                            context,
                            chapterDescriptionKey,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(
                          height: 2.5,
                        ),
                        Text(
                          lesson.description,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        lesson.studyMaterials.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    UiUtils.showBottomSheet(
                                      child: AttachmentBottomsheetContainer(
                                        fromAnnouncementsContainer: false,
                                        studyMaterials: lesson.studyMaterials,
                                      ),
                                      context: context,
                                    );
                                  },
                                  child: Text(
                                    "${lesson.studyMaterials.length} ${UiUtils.getTranslatedLabel(context, attachmentsKey)}",
                                    style: const TextStyle(
                                      color: assignmentViewButtonColor,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        lesson.topicsCount != 0
                            ? Padding(
                                padding: const EdgeInsets.only(top: 2.50),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed<bool?>(
                                      Routes.topicsByLesson,
                                      arguments: {
                                        "classSectionDetails":
                                            classSectionDetails,
                                        "subject": subject,
                                        "lesson": lesson
                                      },
                                    ).then((value) {
                                      if (value != null && value) {
                                        context
                                            .read<LessonsCubit>()
                                            .fetchLessons(
                                              classSectionId:
                                                  classSectionDetails.id,
                                              subjectId: subject.id,
                                            );
                                      }
                                    });
                                  },
                                  child: Text(
                                    "${lesson.topicsCount} ${UiUtils.getTranslatedLabel(context, lesson.topicsCount == 1 ? topicKey : topicsKey)}",
                                    style: const TextStyle(
                                      color: assignmentViewButtonColor,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonsCubit, LessonsState>(
      builder: (context, state) {
        if (state is LessonsFetchSuccess) {
          return state.lessons.isEmpty
              ? const NoDataContainer(titleKey: noLessonsKey)
              : Column(
                  children: state.lessons
                      .map(
                        (lesson) => Animate(
                          effects: customItemFadeAppearanceEffects(),
                          child: _buildLessonDetailsContainer(
                            lesson: lesson,
                            context: context,
                          ),
                        ),
                      )
                      .toList(),
                );
        }
        if (state is LessonsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () {
                context.read<LessonsCubit>().fetchLessons(
                      classSectionId: classSectionDetails.id,
                      subjectId: subject.id,
                    );
              },
            ),
          );
        }
        return Column(
          children: List.generate(
            UiUtils.defaultShimmerLoadingContentCount,
            (index) => index,
          ).map((e) => _buildLessonDetailsShimmerContainer(context)).toList(),
        );
      },
    );
  }
}
