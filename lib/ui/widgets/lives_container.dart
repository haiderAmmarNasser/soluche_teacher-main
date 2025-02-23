import 'package:eschool_teacher/app/routes.dart';
import 'package:eschool_teacher/cubits/lessonDeleteCubit.dart';
import 'package:eschool_teacher/cubits/liveDeleteCubit.dart';
import 'package:eschool_teacher/cubits/liveToggleCubit.dart';
import 'package:eschool_teacher/cubits/livesCubit.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/live.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:eschool_teacher/ui/widgets/confirmDeleteDialog.dart';
import 'package:eschool_teacher/ui/widgets/customShimmerContainer.dart';
import 'package:eschool_teacher/ui/widgets/deleteButton.dart';
import 'package:eschool_teacher/ui/widgets/errorContainer.dart';
import 'package:eschool_teacher/ui/widgets/noDataContainer.dart';
import 'package:eschool_teacher/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool_teacher/utils/animationConfiguration.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LivesContainer extends StatelessWidget {
  final ClassSectionDetails classSectionDetails;
  final Subject subject;
  const LivesContainer({
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

  Widget _buildLiveDetailsContainer({
    required Live live,
    required BuildContext context,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LiveDeleteCubit>(
          create: (context) => LiveDeleteCubit(LiveRepository()),
        ),
        BlocProvider<LiveToggleCubit>(
          create: (context) => LiveToggleCubit(LiveRepository()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocConsumer<LiveToggleCubit, LiveToggleState>(
            listener: (toggleLiveContext, toggleLiveState) {
              if (toggleLiveState is LiveToggleSuccess) {
                context.read<LivesCubit>().fetchLives(
                      subjectId: subject.id,
                    );
              } else if (toggleLiveState is LiveToggleFailure) {
                UiUtils.showBottomToastOverlay(
                  context: context,
                  errorMessage: UiUtils.getTranslatedLabel(
                      context, unableToChangeLessonStatusKey),
                  backgroundColor: Theme.of(context).colorScheme.error,
                );
              }
            },
            builder: (toggleLiveContext, toggleLiveState) {
              return BlocConsumer<LiveDeleteCubit, LiveDeleteState>(
                listener: (context, state) {
                  if (state is LiveDeleteSuccess) {
                    context.read<LivesCubit>().deleteLive(live.id!);
                  } else if (state is LiveDeleteFailure) {
                    UiUtils.showBottomToastOverlay(
                      context: context,
                      errorMessage: UiUtils.getTranslatedLabel(
                          context, unableToDeleteLessonKey),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    );
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.addLive,
                          arguments: {
                            "subject": subject,
                            "classSectionDetails": classSectionDetails,
                            'live': live,
                          },
                        );
                      },
                      child: Opacity(
                        opacity: state is LiveDeleteInProgress ||
                                toggleLiveState is LiveToggleInProgress
                            ? 0.3
                            : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * (0.85),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    UiUtils.getTranslatedLabel(
                                        context, liveDescriptionKey),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  DeleteButton(
                                    onTap: () {
                                      if (state is LessonDeleteInProgress) {
                                        return;
                                      }
                                      showDialog<bool>(
                                        context: context,
                                        builder: (_) =>
                                            const ConfirmDeleteDialog(),
                                      ).then((value) {
                                        if (context.mounted &&
                                            value != null &&
                                            value) {
                                          context
                                              .read<LiveDeleteCubit>()
                                              .deleteLive(live.id!);
                                        }
                                      });
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 2.5),
                              Text(
                                live.description ?? '',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    UiUtils.getTranslatedLabel(
                                        context, liveStatusKey),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  Switch.adaptive(
                                    value: live.isActive ?? false,
                                    onChanged: (value) {
                                      showDialog<bool>(
                                        context: context,
                                        builder: (_) {
                                          return const ConfirmToggleLiveDialog();
                                        },
                                      ).then((value) {
                                        if (context.mounted &&
                                            value != null &&
                                            value) {
                                          context
                                              .read<LiveToggleCubit>()
                                              .toggleLive(live.id!);
                                        }
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor: Colors.grey[400],
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              Divider(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    UiUtils.getTranslatedLabel(
                                      context,
                                      dateKey,
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    live.date ?? '',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2.5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    UiUtils.getTranslatedLabel(
                                        context, timeKey),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    '//${convertTime(live.from ?? '')} - ${convertTime(live.to ?? '')}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // method to convert 21:25:00 to 21:25
  String convertTime(String time) {
    return time.substring(0, time.length - 3);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivesCubit, LivesState>(
      builder: (context, state) {
        if (state is LivesFetchSuccess) {
          return state.lives.isEmpty
              ? const NoDataContainer(titleKey: noLivesKey)
              : Column(
                  children: state.lives
                      .map(
                        (live) => Animate(
                          effects: customItemFadeAppearanceEffects(),
                          child: _buildLiveDetailsContainer(
                            live: live,
                            context: context,
                          ),
                        ),
                      )
                      .toList(),
                );
        }
        if (state is LivesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () {
                context.read<LivesCubit>().fetchLives(
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

class ConfirmToggleLiveDialog extends StatelessWidget {
  const ConfirmToggleLiveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        CupertinoButton(
          child: Text(
            UiUtils.getTranslatedLabel(context, yesKey),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        CupertinoButton(
          child: Text(
            UiUtils.getTranslatedLabel(context, noKey),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      backgroundColor: Colors.white,
      content: Text(
        UiUtils.getTranslatedLabel(context, areYouSureToChangeLiveStatusKey),
      ),
      title: Text(UiUtils.getTranslatedLabel(context, changeLiveStatusKey)),
    );
  }
}
