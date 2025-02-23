import 'package:dotted_border/dotted_border.dart';
import 'package:eschool_teacher/cubits/createAssignmentCubit.dart';
import 'package:eschool_teacher/cubits/editassignment.dart';
import 'package:eschool_teacher/cubits/myClassesCubit.dart';
import 'package:eschool_teacher/cubits/subjectsOfClassSectionCubit.dart';
import 'package:eschool_teacher/data/models/assignment.dart';
import 'package:eschool_teacher/data/models/studyMaterial.dart';
import 'package:eschool_teacher/data/repositories/assignmentRepository.dart';
import 'package:eschool_teacher/data/repositories/teacherRepository.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/assignmentAttachmentContainer.dart';
import 'package:eschool_teacher/ui/widgets/bottomSheetTextFiledContainer.dart';
import 'package:eschool_teacher/ui/widgets/bottomsheetAddFilesDottedBorderContainer.dart';
import 'package:eschool_teacher/ui/widgets/classSubjectsDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/customAppbar.dart';
import 'package:eschool_teacher/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_teacher/ui/widgets/customCupertinoSwitch.dart';
import 'package:eschool_teacher/ui/widgets/customDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/customRoundedButton.dart';
import 'package:eschool_teacher/ui/widgets/defaultDropDownLabelContainer.dart';
import 'package:eschool_teacher/ui/widgets/myClassesDropDownMenu.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

class AddAssignmentScreen extends StatefulWidget {
  final bool editassignment;
  final Assignment? assignment;

  const AddAssignmentScreen({
    Key? key,
    required this.editassignment,
    this.assignment,
  }) : super(key: key);

  static Route<bool?> routes(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<SubjectsOfClassSectionCubit>(
              create: (_) => SubjectsOfClassSectionCubit(TeacherRepository()),
            ),
            BlocProvider<CreateAssignmentCubit>(
              create: (_) => CreateAssignmentCubit(AssignmentRepository()),
            ),
            BlocProvider<EditAssignmentCubit>(
              create: (context) => EditAssignmentCubit(AssignmentRepository()),
            )
          ],
          child: AddAssignmentScreen(
            editassignment: arguments["editAssignment"],
            assignment: arguments["assignment"],
          ),
        );
      },
    );
  }

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  late CustomDropDownItem currentSelectedClassSection = CustomDropDownItem(
      index: 0,
      title: widget.editassignment
          ? context
              .read<MyClassesCubit>()
              .getClassSectionDetailsById(widget.assignment!.classSectionId)
              .getFullClassSectionName()
          : context.read<MyClassesCubit>().getClassSectionName().first);

  late CustomDropDownItem currentSelectedSubject = CustomDropDownItem(
      index: 0,
      title: UiUtils.getTranslatedLabel(context, fetchingSubjectsKey));

  DateTime? dueDate;

  TimeOfDay? dueTime;

  late final TextEditingController _assignmentNameTextEditingController =
      TextEditingController(
    text: widget.editassignment ? widget.assignment!.name : null,
  );

  late final TextEditingController _assignmentInstructionTextEditingController =
      TextEditingController(
    text: widget.editassignment ? widget.assignment!.instructions : null,
  );

  late final TextEditingController _assignmentPointsTextEditingController =
      TextEditingController(
    text: widget.editassignment ? widget.assignment!.points.toString() : null,
  );

  late final TextEditingController _extraResubmissionDaysTextEditingController =
      TextEditingController(
    text: widget.editassignment
        ? widget.assignment!.extraDaysForResubmission.toString()
        : null,
  );

  final double _textFieldBottomPadding = 25;

  late bool _allowedReSubmissionOfRejectedAssignment = widget.editassignment
      ? widget.assignment!.resubmission == 0
          ? false
          : true
      : false;

  @override
  void initState() {
    if (!widget.editassignment) {
      context.read<SubjectsOfClassSectionCubit>().fetchSubjects(
            context
                .read<MyClassesCubit>()
                .getClassSectionDetails(
                  index: currentSelectedClassSection.index,
                )
                .id,
          );
    } else {
      dueDate = DateFormat('dd-MM-yyyy').parse(
        UiUtils.formatStringDate(widget.assignment!.dueDate.toString()),
      );

      dueTime = TimeOfDay.fromDateTime(widget.assignment!.dueDate);
    }
    super.initState();
  }

  void changeAllowedReSubmissionOfRejectedAssignment(bool value) {
    setState(() {
      _allowedReSubmissionOfRejectedAssignment = value;
    });
  }

  List<PlatformFile> uploadedFiles = [];

  late List<StudyMaterial> assignmentattatchments =
      widget.editassignment ? widget.assignment!.studyMaterial : [];

  Future<void> _pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      uploadedFiles.add(result.files.first);
      setState(() {});
    }
  }

  Future<void> _addFiles() async {
    //upload files
    final permission = await Permission.storage.request();
    if (permission.isGranted) {
      await _pickFiles();
    } else {
      try {
        await _pickFiles();
      } on Exception {
        if (context.mounted) {
          UiUtils.showBottomToastOverlay(
              context: context,
              errorMessage: UiUtils.getTranslatedLabel(
                  context, allowStoragePermissionToContinueKey),
              backgroundColor: Theme.of(context).colorScheme.error);
          await Future.delayed(const Duration(seconds: 2));
        }
        openAppSettings();
      }
    }
  }

  Widget _buildUploadedFileContainer(int fileIndex) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 15),
          child: DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: const [10, 10],
            radius: const Radius.circular(10.0),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: boxConstraints.maxWidth * (0.75),
                        child: Text(
                          uploadedFiles[fileIndex].name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (context.read<CreateAssignmentCubit>().state
                              is CreateAssignmentInProcess) {
                            return;
                          }
                          uploadedFiles.removeAt(fileIndex);
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget assignmentassignmentattatchments(int fileIndex) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 15),
          child: DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: const [10, 10],
            radius: const Radius.circular(10.0),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: boxConstraints.maxWidth * (0.75),
                        child: Text(
                          assignmentattatchments[fileIndex].fileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (context.read<CreateAssignmentCubit>().state
                              is CreateAssignmentInProcess) {
                            return;
                          }

                          assignmentattatchments.removeAt(fileIndex);
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> openDatePicker() async {
    final temp = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  onPrimary: Theme.of(context).scaffoldBackgroundColor,
                ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
    );
    if (temp != null) {
      dueDate = temp;
      setState(() {});
    }
  }

  Future<void> openTimePicker() async {
    final temp = await showTimePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  onPrimary: Theme.of(context).scaffoldBackgroundColor,
                ),
          ),
          child: child!,
        );
      },
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (temp != null) {
      dueTime = temp;
      setState(() {});
    }
  }

  void showErrorMessage(String errorMessage) {
    UiUtils.showBottomToastOverlay(
      context: context,
      errorMessage: errorMessage,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  void createAssignment() {
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
    if (!isAnySubjectAvailable && !widget.editassignment) {
      showErrorMessage(
          UiUtils.getTranslatedLabel(context, noSubjectSelectedKey));
      return;
    }
    if (_assignmentNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterAssignmentnameKey),
      );
      return;
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      showErrorMessage(UiUtils.getTranslatedLabel(context, pointsLengthKey));
      return;
    }
    if (dueDate == null) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseSelectDateKey),
      );
      return;
    }
    if (dueTime == null) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseSelectTimeKey),
      );
      return;
    }
    if (_extraResubmissionDaysTextEditingController.text.trim().isEmpty &&
        _allowedReSubmissionOfRejectedAssignment) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(
          context,
          pleaseEnterExtraDaysForResubmissionKey,
        ),
      );
      return;
    }
    if (kDebugMode) {
      print("uploadedFiles create $uploadedFiles");
    }
    context.read<CreateAssignmentCubit>().createAssignment(
          classsId: context
              .read<MyClassesCubit>()
              .getClassSectionDetails(
                index: currentSelectedClassSection.index,
              )
              .id,
          subjectId: context
              .read<SubjectsOfClassSectionCubit>()
              .getSubjectId(currentSelectedSubject.index),
          name: _assignmentNameTextEditingController.text.trim(),
          datetime:
              "${DateFormat('dd-MM-yyyy').format(dueDate!).toString()} ${dueTime!.hour}:${dueTime!.minute}",
          extraDayForResubmission:
              _extraResubmissionDaysTextEditingController.text.trim(),
          instruction: _assignmentInstructionTextEditingController.text.trim(),
          points: _assignmentPointsTextEditingController.text.trim(),
          resubmission: _allowedReSubmissionOfRejectedAssignment,
          file: uploadedFiles,
        );
  }

  void editAssignment() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_assignmentNameTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterAssignmentnameKey),
      );
    }
    if (dueDate == null) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseSelectDateKey),
      );
    }
    if (_assignmentPointsTextEditingController.text.length >= 10) {
      showErrorMessage(UiUtils.getTranslatedLabel(context, pointsLengthKey));
      return;
    }
    if (dueTime == null) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseSelectDateKey),
      );
    }
    if (_extraResubmissionDaysTextEditingController.text.trim().isEmpty &&
        _allowedReSubmissionOfRejectedAssignment) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(
          context,
          pleaseEnterExtraDaysForResubmissionKey,
        ),
      );
      return;
    }
    if (kDebugMode) {
      print("uploadedFiles upload $uploadedFiles");
    }
    context.read<EditAssignmentCubit>().editAssignment(
          classSelectionId: widget.assignment!.classSectionId,
          subjectId: widget.assignment!.subjectId,
          name: _assignmentNameTextEditingController.text.trim(),
          dateTime:
              "${DateFormat('dd-MM-yyyy').format(dueDate!).toString()} ${dueTime!.hour}:${dueTime!.minute}",
          extraDayForResubmission:
              _extraResubmissionDaysTextEditingController.text.trim(),
          instruction: _assignmentInstructionTextEditingController.text.trim(),
          points: _assignmentPointsTextEditingController.text.trim(),
          resubmission: _allowedReSubmissionOfRejectedAssignment ? 1 : 0,
          filePaths: uploadedFiles,
          assignmentId: widget.assignment!.id,
        );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomAppBar(
        title: UiUtils.getTranslatedLabel(
          context,
          widget.editassignment ? editAssignmentKey : createAssignmentKey,
        ),
        onPressBackButton: () {
          if (context.read<CreateAssignmentCubit>().state
              is CreateAssignmentInProcess) {
            return;
          }
          if (context.read<EditAssignmentCubit>().state
              is EditAssignmentInProgress) {
            return;
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildAssignmentClassDropdownButtons() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Column(
          children: [
            widget.editassignment
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
                      });
                    },
                  ),
            widget.editassignment
                ? DefaultDropDownLabelContainer(
                    titleLabelKey:
                        widget.assignment!.subject.subjectNameWithType,
                    width: boxConstraints.maxWidth,
                  )
                : ClassSubjectsDropDownMenu(
                    changeSelectedItem: (result) {
                      setState(() {
                        currentSelectedSubject = result;
                      });
                    },
                    currentSelectedItem: currentSelectedSubject,
                    width: boxConstraints.maxWidth,
                  ),
          ],
        );
      },
    );
  }

  Widget _buildAddDueDateAndTimeContainer() {
    return Padding(
      padding: EdgeInsets.only(bottom: _textFieldBottomPadding),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  openDatePicker();
                },
                child: Container(
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                  width: boxConstraints.maxWidth * (0.475),
                  height: 50,
                  child: Text(
                    dueDate == null
                        ? UiUtils.getTranslatedLabel(context, dueDateKey)
                        : DateFormat('dd-MM-yyyy').format(dueDate!).toString(),
                    style: TextStyle(
                      color: hintTextColor,
                      fontSize: UiUtils.textFieldFontSize,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  openTimePicker();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                  width: boxConstraints.maxWidth * (0.475),
                  height: 50,
                  child: Text(
                    dueTime == null
                        ? UiUtils.getTranslatedLabel(context, dueTimeKey)
                        : "${dueTime!.hour}:${dueTime!.minute}",
                    style: TextStyle(
                      color: hintTextColor,
                      fontSize: UiUtils.textFieldFontSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReSubmissionOfRejectedAssignmentToggleContainer() {
    return Padding(
      padding: EdgeInsets.only(bottom: _textFieldBottomPadding),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Flexible(
                  child: SizedBox(
                    width: boxConstraints.maxWidth * (0.85),
                    child: Text(
                      UiUtils.getTranslatedLabel(
                        context,
                        resubmissionOfRejectedAssignmentKey,
                      ),
                      style: TextStyle(
                        color: hintTextColor,
                        fontSize: UiUtils.textFieldFontSize,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: boxConstraints.maxWidth * (0.075),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: boxConstraints.maxWidth * (0.1),
                  child: CustomCupertinoSwitch(
                    onChanged: changeAllowedReSubmissionOfRejectedAssignment,
                    value: _allowedReSubmissionOfRejectedAssignment,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentDetailsFormContaienr() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * (0.075),
        right: MediaQuery.of(context).size.width * (0.075),
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarSmallerHeightPercentage,
        ),
      ),
      child: Column(
        children: [
          //
          _buildAssignmentClassDropdownButtons(),
          BottomSheetTextFieldContainer(
            margin: EdgeInsetsDirectional.only(bottom: _textFieldBottomPadding),
            hintText: UiUtils.getTranslatedLabel(context, assignmentNameKey),
            maxLines: 1,
            textEditingController: _assignmentNameTextEditingController,
          ),

          BottomSheetTextFieldContainer(
            margin: EdgeInsetsDirectional.only(bottom: _textFieldBottomPadding),
            hintText: UiUtils.getTranslatedLabel(context, instructionsKey),
            maxLines: 3,
            textEditingController: _assignmentInstructionTextEditingController,
          ),

          _buildAddDueDateAndTimeContainer(),

          BottomSheetTextFieldContainer(
            margin: EdgeInsetsDirectional.only(bottom: _textFieldBottomPadding),
            hintText: UiUtils.getTranslatedLabel(context, pointsKey),
            maxLines: 1,
            keyboardType: TextInputType.number,
            textEditingController: _assignmentPointsTextEditingController,
            textInputFormatter: [FilteringTextInputFormatter.digitsOnly],
          ),

          //_buildLateSubmissionToggleContainer(),

          _buildReSubmissionOfRejectedAssignmentToggleContainer(),

          _allowedReSubmissionOfRejectedAssignment
              ? BottomSheetTextFieldContainer(
                  margin: EdgeInsetsDirectional.only(
                    bottom: _textFieldBottomPadding,
                  ),
                  hintText: UiUtils.getTranslatedLabel(
                    context,
                    extraDaysForRejectedAssignmentKey,
                  ),
                  maxLines: 2,
                  textEditingController:
                      _extraResubmissionDaysTextEditingController,
                  keyboardType: TextInputType.number,
                  textInputFormatter: [FilteringTextInputFormatter.digitsOnly],
                )
              : const SizedBox(),
          assignmentattatchments.isNotEmpty
              ? Column(
                  children: assignmentattatchments
                      .map(
                        (studyMaterial) => AssignmentAttachmentContainer(
                          onDeleteCallback: (fileId) {
                            assignmentattatchments
                                .removeWhere((element) => element.id == fileId);
                            setState(() {});
                          },
                          showDeleteButton: true,
                          studyMaterial: studyMaterial,
                        ),
                      )
                      .toList(),
                )
              : const SizedBox(),

          Padding(
            padding: EdgeInsets.only(bottom: _textFieldBottomPadding),
            child: BottomsheetAddFilesDottedBorderContainer(
              onTap: () async {
                _addFiles();
              },
              title: UiUtils.getTranslatedLabel(context, referenceMaterialsKey),
            ),
          ),

          ...List.generate(uploadedFiles.length, (index) => index)
              .map((fileIndex) => _buildUploadedFileContainer(fileIndex))
              .toList(),

          widget.editassignment
              ? BlocConsumer<EditAssignmentCubit, EditAssignmentState>(
                  listener: (context, state) {
                    if (state is EditAssignmentSuccess) {
                      UiUtils.showBottomToastOverlay(
                        context: context,
                        errorMessage: UiUtils.getTranslatedLabel(
                          context,
                          editsucessfullyassignmentkey,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      );
                      Navigator.of(context).pop(true);
                    }
                    if (state is EditAssignmentFailure) {
                      UiUtils.showBottomToastOverlay(
                        context: context,
                        errorMessage: UiUtils.getErrorMessageFromErrorCode(
                          context,
                          state.errorMessage,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      );
                    }
                  },
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, boxConstraints) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: boxConstraints.maxWidth * (0.125),
                          ),
                          child: CustomRoundedButton(
                            height: 45,
                            radius: 10,
                            widthPercentage: boxConstraints.maxWidth * (0.45),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            buttonTitle: UiUtils.getTranslatedLabel(
                              context,
                              editassignmentkey,
                            ),
                            showBorder: false,
                            child: state is EditAssignmentInProgress
                                ? const CustomCircularProgressIndicator(
                                    strokeWidth: 2,
                                    widthAndHeight: 20,
                                  )
                                : null,
                            onTap: () {
                              if (state is EditAssignmentInProgress) {
                                return;
                              }
                              editAssignment();
                            },
                          ),
                        );
                      },
                    );
                  },
                )
              : BlocConsumer<CreateAssignmentCubit, CreateAssignmentState>(
                  listener: (context, state) {
                    if (state is CreateAssignmentSuccess) {
                      UiUtils.showBottomToastOverlay(
                        context: context,
                        errorMessage: UiUtils.getTranslatedLabel(
                          context,
                          sucessfullyCreateAssignmentKey,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      );
                      Navigator.of(context).pop(true);
                    }
                    if (state is CreateAssignmentFailure) {
                      UiUtils.showBottomToastOverlay(
                        context: context,
                        errorMessage: UiUtils.getErrorMessageFromErrorCode(
                          context,
                          state.errormessage,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      );
                    }
                  },
                  builder: (context, state) {
                    return CustomRoundedButton(
                      height: 45,
                      radius: 10,
                      widthPercentage: 0.65,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: UiUtils.getTranslatedLabel(
                        context,
                        createAssignmentKey,
                      ),
                      showBorder: false,
                      child: state is CreateAssignmentInProcess
                          ? const CustomCircularProgressIndicator(
                              strokeWidth: 2,
                              widthAndHeight: 20,
                            )
                          : null,
                      onTap: () {
                        if (state is CreateAssignmentInProcess) {
                          return;
                        }
                        createAssignment();
                      },
                    );
                  },
                ),
          SizedBox(
            height: _textFieldBottomPadding,
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
        if (context.read<CreateAssignmentCubit>().state
                is! CreateAssignmentInProcess &&
            context.read<EditAssignmentCubit>().state
                is! EditAssignmentInProgress) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildAssignmentDetailsFormContaienr(),
            _buildAppBar(),
          ],
        ),
      ),
    );
  }
}
