import 'package:eschool_teacher/cubits/createTopicCubit.dart';
import 'package:eschool_teacher/cubits/editTopicCubit.dart';
import 'package:eschool_teacher/cubits/lessonsCubit.dart';
import 'package:eschool_teacher/cubits/myClassesCubit.dart';
import 'package:eschool_teacher/cubits/subjectsOfClassSectionCubit.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/lesson.dart';
import 'package:eschool_teacher/data/models/pickedStudyMaterial.dart';
import 'package:eschool_teacher/data/models/studyMaterial.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/models/topic.dart';
import 'package:eschool_teacher/data/repositories/lessonRepository.dart';
import 'package:eschool_teacher/data/repositories/teacherRepository.dart';
import 'package:eschool_teacher/data/repositories/topicRepository.dart';
import 'package:eschool_teacher/ui/widgets/addStudyMaterialBottomSheet.dart';
import 'package:eschool_teacher/ui/widgets/addedStudyMaterialFileContainer.dart';
import 'package:eschool_teacher/ui/widgets/bottomSheetTextFiledContainer.dart';
import 'package:eschool_teacher/ui/widgets/bottomsheetAddFilesDottedBorderContainer.dart';
import 'package:eschool_teacher/ui/widgets/classSubjectsDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/customAppbar.dart';
import 'package:eschool_teacher/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_teacher/ui/widgets/customDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/customRoundedButton.dart';
import 'package:eschool_teacher/ui/widgets/defaultDropDownLabelContainer.dart';
import 'package:eschool_teacher/ui/widgets/myClassesDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/studyMaterialContainer.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddOrEditTopicScreen extends StatefulWidget {
  final Lesson? lesson;
  final Subject? subject;
  final Topic? topic;
  final ClassSectionDetails? classSectionDetails;

  const AddOrEditTopicScreen({
    Key? key,
    this.lesson,
    required this.subject,
    this.topic,
    this.classSectionDetails,
  }) : super(key: key);

  static Route<bool?> route(RouteSettings routeSettings) {
    final arguments = (routeSettings.arguments ?? Map<String, dynamic>.from({}))
        as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LessonsCubit(LessonRepository()),
          ),
          BlocProvider(
            create: (context) =>
                SubjectsOfClassSectionCubit(TeacherRepository()),
          ),
          BlocProvider(
            create: (context) => CreateTopicCubit(TopicRepository()),
          ),
          BlocProvider(
            create: (context) => EditTopicCubit(TopicRepository()),
          ),
        ],
        child: AddOrEditTopicScreen(
          classSectionDetails: arguments['classSectionDetails'],
          subject: arguments['subject'],
          lesson: arguments['lesson'],
          topic: arguments['topic'],
        ),
      ),
    );
  }

  @override
  State<AddOrEditTopicScreen> createState() => _AddOrEditTopicScreenState();
}

class _AddOrEditTopicScreenState extends State<AddOrEditTopicScreen> {
  late CustomDropDownItem currentSelectedClassSection = CustomDropDownItem(
      index: 0,
      title: widget.classSectionDetails != null
          ? widget.classSectionDetails!.getFullClassSectionName()
          : context.read<MyClassesCubit>().getClassSectionName().first);

  late CustomDropDownItem currentSelectedSubject = widget.subject != null
      ? CustomDropDownItem(index: 0, title: widget.subject!.subjectNameWithType)
      : CustomDropDownItem(
          index: 0,
          title: UiUtils.getTranslatedLabel(context, fetchingSubjectsKey));

  late CustomDropDownItem currentSelectedLesson = widget.lesson != null
      ? CustomDropDownItem(index: 0, title: widget.lesson!.name)
      : CustomDropDownItem(
          index: 0,
          title: UiUtils.getTranslatedLabel(context, fetchingLessonsKey));

  late final TextEditingController _topicNameTextEditingController =
      TextEditingController(
    text: widget.topic != null ? widget.topic!.name : null,
  );
  late final TextEditingController _topicDescriptionTextEditingController =
      TextEditingController(
    text: widget.topic != null ? widget.topic!.description : null,
  );

  List<PickedStudyMaterial> _addedStudyMaterials = [];

  late List<StudyMaterial> studyMaterials =
      widget.topic != null ? widget.topic!.studyMaterials : [];

  //This will determine if need to refresh the previous page
  //topics data. If teacher remove the the any study material
  //so we need to fetch the list again
  late bool refreshTopicsInPreviousPage = false;

  @override
  void initState() {
    if (widget.classSectionDetails == null) {
      context.read<SubjectsOfClassSectionCubit>().fetchSubjects(
            context.read<MyClassesCubit>().getAllClasses().first.id,
          );
    }

    super.initState();
  }

  void deleteStudyMaterial(int studyMaterialId) {
    studyMaterials.removeWhere((element) => element.id == studyMaterialId);
    refreshTopicsInPreviousPage = true;
    setState(() {});
  }

  void updateStudyMaterials(StudyMaterial studyMaterial) {
    final studyMaterialIndex =
        studyMaterials.indexWhere((element) => element.id == studyMaterial.id);
    studyMaterials[studyMaterialIndex] = studyMaterial;
    refreshTopicsInPreviousPage = true;
    setState(() {});
  }

  void _addStudyMaterial(PickedStudyMaterial pickedStudyMaterial) {
    setState(() {
      _addedStudyMaterials.add(pickedStudyMaterial);
    });
  }

  void showErrorMessage(String errorMessage) {
    UiUtils.showBottomToastOverlay(
      context: context,
      errorMessage: errorMessage,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  void editTopic() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_topicNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterTopicNameKey),
      );
      return;
    }

    if (_topicDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterTopicDescriptionKey),
      );
      return;
    }

    context.read<EditTopicCubit>().editTopic(
          topicDescription: _topicDescriptionTextEditingController.text.trim(),
          topicName: _topicNameTextEditingController.text.trim(),
          lessonId: widget.lesson!.id,
          classSectionId: widget.classSectionDetails!.id,
          subjectId: widget.subject!.id,
          topicId: widget.topic!.id,
          files: _addedStudyMaterials,
        );
  }

  void createTopic() {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isAnySubjectAvailable = false;
    bool isAnyLessonsAvailable = false;
    if (context.read<SubjectsOfClassSectionCubit>().state
            is SubjectsOfClassSectionFetchSuccess &&
        (context.read<SubjectsOfClassSectionCubit>().state
                as SubjectsOfClassSectionFetchSuccess)
            .subjects
            .isNotEmpty) {
      isAnySubjectAvailable = true;
    }
    if (context.read<LessonsCubit>().state is LessonsFetchSuccess &&
        (context.read<LessonsCubit>().state as LessonsFetchSuccess)
            .lessons
            .isNotEmpty) {
      isAnyLessonsAvailable = true;
    }
    if (!isAnySubjectAvailable && widget.subject == null) {
      showErrorMessage(
          UiUtils.getTranslatedLabel(context, noSubjectSelectedKey));
      return;
    }
    if (!isAnyLessonsAvailable && widget.lesson == null) {
      showErrorMessage(
          UiUtils.getTranslatedLabel(context, noLessonSelectedKey));
      return;
    }
    if (_topicNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterTopicNameKey),
      );
      return;
    }

    if (_topicDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterTopicDescriptionKey),
      );
      return;
    }
    final selectedSubjectId = widget.subject != null
        ? widget.subject!.id
        : context
            .read<SubjectsOfClassSectionCubit>()
            .getSubjectId(currentSelectedSubject.index);

    //
    if (selectedSubjectId == -1) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleasefetchingSubjectsKey),
      );
      return;
    }

    final lessonId = widget.lesson != null
        ? widget.lesson!.id
        : context
            .read<LessonsCubit>()
            .getLesson(currentSelectedLesson.index)
            .id;
    if (lessonId == 0) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseSelectLessonKey),
      );
      return;
    }

    //
    context.read<CreateTopicCubit>().createTopic(
          topicName: _topicNameTextEditingController.text.trim(),
          lessonId: lessonId,
          classSectionId: widget.classSectionDetails != null
              ? widget.classSectionDetails!.id
              : context
                  .read<MyClassesCubit>()
                  .getClassSectionDetails(
                    index: currentSelectedClassSection.index,
                  )
                  .id,
          subjectId: selectedSubjectId,
          topicDescription: _topicDescriptionTextEditingController.text.trim(),
          files: _addedStudyMaterials,
        );
  }

  Widget _buildClassSubjectAndLessonDropDowns() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Column(
          children: [
            widget.classSectionDetails != null
                ? DefaultDropDownLabelContainer(
                    titleLabelKey: currentSelectedClassSection.title,
                    width: boxConstraints.maxWidth,
                  )
                : MyClassesDropDownMenu(
                    currentSelectedItem: currentSelectedClassSection,
                    width: boxConstraints.maxWidth,
                    changeSelectedItem: (value) {
                      currentSelectedClassSection = value;
                      context
                          .read<LessonsCubit>()
                          .updateState(LessonsInitial());
                      setState(() {});
                    },
                  ),
            widget.subject != null
                ? DefaultDropDownLabelContainer(
                    titleLabelKey: widget.subject!.subjectNameWithType,
                    width: boxConstraints.maxWidth,
                  )
                : ClassSubjectsDropDownMenu(
                    changeSelectedItem: (result) {
                      setState(() {
                        currentSelectedSubject = result;
                      });
                      final subjectId = context
                          .read<SubjectsOfClassSectionCubit>()
                          .getSubjectId(currentSelectedSubject.index);
                      if (subjectId != -1) {
                        context.read<LessonsCubit>().fetchLessons(
                              classSectionId: context
                                  .read<MyClassesCubit>()
                                  .getClassSectionDetails(
                                    index: currentSelectedClassSection.index,
                                  )
                                  .id,
                              subjectId: subjectId,
                            );
                      }
                    },
                    currentSelectedItem: currentSelectedSubject,
                    width: boxConstraints.maxWidth,
                  ),
            //

            widget.lesson != null
                ? DefaultDropDownLabelContainer(
                    titleLabelKey: widget.lesson!.name,
                    width: boxConstraints.maxWidth,
                  )
                : BlocListener<SubjectsOfClassSectionCubit,
                    SubjectsOfClassSectionState>(
                    listener: (context, state) {
                      if (state is SubjectsOfClassSectionFetchSuccess) {
                        if (state.subjects.isEmpty) {
                          context
                              .read<LessonsCubit>()
                              .updateState(LessonsFetchSuccess([]));
                        }
                      }
                    },
                    child: BlocConsumer<LessonsCubit, LessonsState>(
                      builder: (context, state) {
                        return state is LessonsFetchSuccess
                            ? state.lessons.isEmpty
                                ? DefaultDropDownLabelContainer(
                                    titleLabelKey: noLessonsKey,
                                    width: boxConstraints.maxWidth,
                                  )
                                : CustomDropDownMenu(
                                    width: boxConstraints.maxWidth,
                                    onChanged: (value) {
                                      if (value != null &&
                                          value != currentSelectedLesson) {
                                        currentSelectedLesson = value;
                                        setState(() {});
                                      }
                                    },
                                    menu: state.lessons
                                        .map((e) => e.name)
                                        .toList(),
                                    currentSelectedItem: currentSelectedLesson,
                                  )
                            : DefaultDropDownLabelContainer(
                                titleLabelKey: fetchingLessonsKey,
                                width: boxConstraints.maxWidth,
                              );
                      },
                      listener: (context, state) {
                        if (state is LessonsFetchSuccess) {
                          if (state.lessons.isNotEmpty) {
                            setState(() {
                              currentSelectedLesson = CustomDropDownItem(
                                  index: 0, title: state.lessons.first.name);
                            });
                          }
                        }
                      },
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildAppbar() {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomAppBar(
        onPressBackButton: () {
          if (context.read<CreateTopicCubit>().state is CreateTopicInProgress) {
            return;
          }

          if (context.read<EditTopicCubit>().state is EditTopicInProgress) {
            return;
          }
          Navigator.of(context).pop(refreshTopicsInPreviousPage);
        },
        title: UiUtils.getTranslatedLabel(
          context,
          widget.topic != null ? editTopicKey : addTopicKey,
        ),
      ),
    );
  }

  Widget _buildAddOrEditTopicForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: 25,
        right: UiUtils.screenContentHorizontalPaddingPercentage *
            MediaQuery.of(context).size.width,
        left: UiUtils.screenContentHorizontalPaddingPercentage *
            MediaQuery.of(context).size.width,
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            children: [
              _buildClassSubjectAndLessonDropDowns(),
              BottomSheetTextFieldContainer(
                hintText: UiUtils.getTranslatedLabel(context, topicNameKey),
                margin: const EdgeInsets.only(bottom: 20),
                maxLines: 1,
                contentPadding: const EdgeInsetsDirectional.only(start: 15),
                textEditingController: _topicNameTextEditingController,
              ),
              BottomSheetTextFieldContainer(
                margin: const EdgeInsets.only(bottom: 20),
                hintText:
                    UiUtils.getTranslatedLabel(context, topicDescriptionKey),
                maxLines: 3,
                contentPadding: const EdgeInsetsDirectional.only(start: 15),
                textEditingController: _topicDescriptionTextEditingController,
              ),
              widget.topic != null
                  ? Column(
                      children: studyMaterials
                          .map(
                            (studyMaterial) => StudyMaterialContainer(
                              onDeleteStudyMaterial: deleteStudyMaterial,
                              onEditStudyMaterial: updateStudyMaterials,
                              showEditAndDeleteButton: true,
                              studyMaterial: studyMaterial,
                            ),
                          )
                          .toList(),
                    )
                  : const SizedBox(),
              BottomsheetAddFilesDottedBorderContainer(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  UiUtils.showBottomSheet(
                    child: AddStudyMaterialBottomsheet(
                      editFileDetails: false,
                      onTapSubmit: _addStudyMaterial,
                    ),
                    context: context,
                  );
                },
                title: UiUtils.getTranslatedLabel(context, studyMaterialsKey),
              ),
              const SizedBox(
                height: 20,
              ),
              ...List.generate(_addedStudyMaterials.length, (index) => index)
                  .map(
                    (index) => AddedStudyMaterialContainer(
                      onDelete: (index) {
                        _addedStudyMaterials.removeAt(index);
                        setState(() {});
                      },
                      onEdit: (index, file) {
                        _addedStudyMaterials[index] = file;
                        setState(() {});
                      },
                      file: _addedStudyMaterials[index],
                      fileIndex: index,
                    ),
                  )
                  .toList(),
              widget.topic != null
                  ? BlocConsumer<EditTopicCubit, EditTopicState>(
                      listener: (context, state) {
                        if (state is EditTopicSuccess) {
                          Navigator.of(context).pop(true);
                        } else if (state is EditTopicFailure) {
                          UiUtils.showBottomToastOverlay(
                            context: context,
                            errorMessage: UiUtils.getErrorMessageFromErrorCode(
                              context,
                              state.errorMessage,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: boxConstraints.maxWidth * (0.25),
                          ),
                          child: CustomRoundedButton(
                            onTap: () {
                              if (state is EditTopicInProgress) {
                                return;
                              }
                              //
                              editTopic();
                            },
                            height: 45,
                            widthPercentage: boxConstraints.maxWidth * (0.45),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            buttonTitle: UiUtils.getTranslatedLabel(
                              context,
                              editTopicKey,
                            ),
                            showBorder: false,
                            child: state is EditTopicInProgress
                                ? const CustomCircularProgressIndicator(
                                    strokeWidth: 2,
                                    widthAndHeight: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    )
                  : BlocConsumer<CreateTopicCubit, CreateTopicState>(
                      listener: (context, state) {
                        if (state is CreateTopicSuccess) {
                          _topicNameTextEditingController.text = "";
                          _topicDescriptionTextEditingController.text = "";
                          _addedStudyMaterials = [];
                          refreshTopicsInPreviousPage = true;
                          setState(() {});
                          UiUtils.showBottomToastOverlay(
                            context: context,
                            errorMessage: UiUtils.getTranslatedLabel(
                              context,
                              UiUtils.getTranslatedLabel(
                                context,
                                topicAddedSuccessfullyKey,
                              ),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          );
                        } else if (state is CreateTopicFailure) {
                          UiUtils.showBottomToastOverlay(
                            context: context,
                            errorMessage: UiUtils.getErrorMessageFromErrorCode(
                              context,
                              state.errorMessage,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: boxConstraints.maxWidth * (0.25),
                          ),
                          child: CustomRoundedButton(
                            onTap: () {
                              if (state is CreateTopicInProgress) {
                                return;
                              }
                              createTopic();
                            },
                            height: 45,
                            widthPercentage: boxConstraints.maxWidth * (0.45),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            buttonTitle: UiUtils.getTranslatedLabel(
                              context,
                              addTopicKey,
                            ),
                            showBorder: false,
                            child: state is CreateTopicInProgress
                                ? const CustomCircularProgressIndicator(
                                    strokeWidth: 2,
                                    widthAndHeight: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(refreshTopicsInPreviousPage);
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildAddOrEditTopicForm(),
            _buildAppbar(),
          ],
        ),
      ),
    );
  }
}
