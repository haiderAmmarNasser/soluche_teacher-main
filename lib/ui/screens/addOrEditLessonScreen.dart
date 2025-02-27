import 'package:eschool_teacher/cubits/createLessonCubit.dart';
import 'package:eschool_teacher/cubits/editLessonCubit.dart';
import 'package:eschool_teacher/cubits/myClassesCubit.dart';
import 'package:eschool_teacher/cubits/subjectsOfClassSectionCubit.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/lesson.dart';
import 'package:eschool_teacher/data/models/pickedStudyMaterial.dart';
import 'package:eschool_teacher/data/models/studyMaterial.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/repositories/lessonRepository.dart';
import 'package:eschool_teacher/data/repositories/teacherRepository.dart';
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

class AddOrEditLessonScreen extends StatefulWidget {
  final ClassSectionDetails? classSectionDetails;
  final Lesson? lesson;
  final Subject? subject;

  const AddOrEditLessonScreen({
    Key? key,
    this.classSectionDetails,
    this.lesson,
    this.subject,
  }) : super(key: key);

  static Route<bool?> route(RouteSettings routeSettings) {
    final arguments = (routeSettings.arguments ?? Map<String, dynamic>.from({}))
        as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                SubjectsOfClassSectionCubit(TeacherRepository()),
          ),
          BlocProvider(
            create: (context) => CreateLessonCubit(LessonRepository()),
          ),
          BlocProvider(
            create: (context) => EditLessonCubit(LessonRepository()),
          ),
        ],
        child: AddOrEditLessonScreen(
          classSectionDetails: arguments['classSectionDetails'],
          lesson: arguments['lesson'],
          subject: arguments['subject'],
        ),
      ),
    );
  }

  @override
  State<AddOrEditLessonScreen> createState() => _AddOrEditLessonScreenState();
}

class _AddOrEditLessonScreenState extends State<AddOrEditLessonScreen> {
  late CustomDropDownItem currentSelectedClassSection = CustomDropDownItem(
      index: 0,
      title: widget.classSectionDetails != null
          ? widget.classSectionDetails!.getFullClassSectionName()
          : context.read<MyClassesCubit>().getClassSectionName().first);

  late CustomDropDownItem currentSelectedSubject = widget.subject == null
      ? CustomDropDownItem(
          index: 0,
          title: UiUtils.getTranslatedLabel(context, fetchingSubjectsKey))
      : CustomDropDownItem(
          index: 0, title: widget.subject!.subjectNameWithType);

  late final TextEditingController _lessonNameTextEditingController =
      TextEditingController(
    text: widget.lesson != null ? widget.lesson!.name : null,
  );
  late final TextEditingController _lessonDescriptionTextEditingController =
      TextEditingController(
    text: widget.lesson != null ? widget.lesson!.description : null,
  );

  late final TextEditingController _lessonPriceTextEditingController =
      TextEditingController(
    text: widget.lesson != null ? widget.lesson!.price.toString() : null,
  );

  List<PickedStudyMaterial> _addedStudyMaterials = [];

  late List<StudyMaterial> studyMaterials =
      widget.lesson != null ? widget.lesson!.studyMaterials : [];

  //This will determine if need to refresh the previous page
  //lessons data. If teacher remove the the any study material
  //so we need to fetch the list again
  late bool refreshLessonsInPreviousPage = false;

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
    refreshLessonsInPreviousPage = true;
    setState(() {});
  }

  void updateStudyMaterials(StudyMaterial studyMaterial) {
    final studyMaterialIndex =
        studyMaterials.indexWhere((element) => element.id == studyMaterial.id);
    studyMaterials[studyMaterialIndex] = studyMaterial;
    refreshLessonsInPreviousPage = true;
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

  void editLesson() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_lessonNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterLessonNameKey),
      );
      return;
    }

    if (_lessonDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterLessonDescriptionKey),
      );
      return;
    }

    if (_lessonPriceTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterPriceKey),
      );
      return;
    }

    context.read<EditLessonCubit>().editLesson(
          lessonDescription:
              _lessonDescriptionTextEditingController.text.trim(),
          lessonName: _lessonNameTextEditingController.text.trim(),
          lessonId: widget.lesson!.id,
          classSectionId: widget.lesson!.classSectionId,
          subjectId: widget.subject!.id,
          files: _addedStudyMaterials,
          price: _lessonPriceTextEditingController.text.trim(),
        );
  }

  void createLesson() {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isAnySubjectAvailable = false;
    if (context.read<SubjectsOfClassSectionCubit>().state
            is SubjectsOfClassSectionFetchSuccess &&
        (context.read<SubjectsOfClassSectionCubit>().state
                as SubjectsOfClassSectionFetchSuccess)
            .subjects
            .isNotEmpty) {
      isAnySubjectAvailable = true;
    }
    if (!isAnySubjectAvailable && widget.subject == null) {
      showErrorMessage(
          UiUtils.getTranslatedLabel(context, noSubjectSelectedKey));
      return;
    }
    if (_lessonNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterLessonNameKey),
      );
      return;
    }

    if (_lessonDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterLessonDescriptionKey),
      );
      return;
    }

    if (_lessonPriceTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterPriceKey),
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

    context.read<CreateLessonCubit>().createLesson(
          classSectionId: widget.classSectionDetails != null
              ? widget.classSectionDetails!.id
              : context
                  .read<MyClassesCubit>()
                  .getClassSectionDetails(
                    index: currentSelectedClassSection.index,
                  )
                  .id,
          files: _addedStudyMaterials,
          subjectId: selectedSubjectId,
          lessonDescription:
              _lessonDescriptionTextEditingController.text.trim(),
          lessonName: _lessonNameTextEditingController.text.trim(),
          price: _lessonPriceTextEditingController.text.trim(),
        );
  }

  Widget _buildAppbar() {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomAppBar(
        onPressBackButton: () {
          if (context.read<CreateLessonCubit>().state
              is CreateLessonInProgress) {
            return;
          }
          if (context.read<EditLessonCubit>().state is EditLessonInProgress) {
            return;
          }
          Navigator.of(context).pop(refreshLessonsInPreviousPage);
        },
        title: UiUtils.getTranslatedLabel(
          context,
          widget.lesson != null ? editLessonKey : addLessonKey,
        ),
      ),
    );
  }

  Widget _buildAddOrEditLessonForm() {
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
              widget.classSectionDetails != null
                  ? DefaultDropDownLabelContainer(
                      titleLabelKey: currentSelectedClassSection.title,
                      width: boxConstraints.maxWidth,
                    )
                  : MyClassesDropDownMenu(
                      currentSelectedItem: currentSelectedClassSection,
                      width: boxConstraints.maxWidth,
                      changeSelectedItem: (result) {
                        setState(() {
                          currentSelectedClassSection = result;
                          _addedStudyMaterials = [];
                        });
                      },
                    ),

              //
              widget.subject != null
                  ? DefaultDropDownLabelContainer(
                      titleLabelKey: widget.subject!.subjectNameWithType,
                      width: boxConstraints.maxWidth,
                    )
                  : ClassSubjectsDropDownMenu(
                      changeSelectedItem: (result) {
                        setState(() {
                          currentSelectedSubject = result;
                          _addedStudyMaterials = [];
                        });
                      },
                      currentSelectedItem: currentSelectedSubject,
                      width: boxConstraints.maxWidth,
                    ),

              BottomSheetTextFieldContainer(
                hintText: UiUtils.getTranslatedLabel(context, chapterNameKey),
                margin: const EdgeInsets.only(bottom: 20),
                maxLines: 1,
                contentPadding: const EdgeInsetsDirectional.only(start: 15),
                textEditingController: _lessonNameTextEditingController,
              ),
              BottomSheetTextFieldContainer(
                margin: const EdgeInsets.only(bottom: 20),
                hintText:
                    UiUtils.getTranslatedLabel(context, chapterDescriptionKey),
                maxLines: 3,
                contentPadding: const EdgeInsetsDirectional.only(start: 15),
                textEditingController: _lessonDescriptionTextEditingController,
              ),
              BottomSheetTextFieldContainer(
                margin: const EdgeInsets.only(bottom: 20),
                hintText:
                    UiUtils.getTranslatedLabel(context, priceKey),
                maxLines: 1,
                contentPadding: const EdgeInsetsDirectional.only(start: 15),
                textEditingController: _lessonPriceTextEditingController,
              ),

              //
              widget.lesson != null
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

              widget.lesson != null
                  ? BlocConsumer<EditLessonCubit, EditLessonState>(
                      listener: (context, state) {
                        if (state is EditLessonSuccess) {
                          Navigator.of(context).pop(true);
                        } else if (state is EditLessonFailure) {
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
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (state is EditLessonInProgress) {
                                return;
                              }
                              editLesson();
                            },
                            height: 45,
                            widthPercentage: boxConstraints.maxWidth * (0.45),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            buttonTitle: UiUtils.getTranslatedLabel(
                              context,
                              editLessonKey,
                            ),
                            showBorder: false,
                            child: state is EditLessonInProgress
                                ? const CustomCircularProgressIndicator(
                                    strokeWidth: 2,
                                    widthAndHeight: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    )
                  : BlocConsumer<CreateLessonCubit, CreateLessonState>(
                      listener: (context, state) {
                        if (state is CreateLessonSuccess) {
                          _lessonDescriptionTextEditingController.text = "";
                          _lessonNameTextEditingController.text = "";
                          _addedStudyMaterials = [];
                          refreshLessonsInPreviousPage = true;
                          setState(() {});
                          UiUtils.showBottomToastOverlay(
                            context: context,
                            errorMessage: UiUtils.getTranslatedLabel(
                              context,
                              lessonAddedKey,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          );
                        } else if (state is CreateLessonFailure) {
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
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (state is CreateLessonInProgress) {
                                return;
                              }
                              createLesson();
                            },
                            height: 45,
                            widthPercentage: boxConstraints.maxWidth * (0.45),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            buttonTitle: UiUtils.getTranslatedLabel(
                              context,
                              addLessonKey,
                            ),
                            showBorder: false,
                            child: state is CreateLessonInProgress
                                ? const CustomCircularProgressIndicator(
                                    strokeWidth: 2,
                                    widthAndHeight: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
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
        Navigator.of(context).pop(refreshLessonsInPreviousPage);
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildAddOrEditLessonForm(),
            _buildAppbar(),
          ],
        ),
      ),
    );
  }
}
