import 'package:eschool_teacher/app/routes.dart';
import 'package:eschool_teacher/cubits/createLiveCubit.dart';
import 'package:eschool_teacher/cubits/myClassesCubit.dart';
import 'package:eschool_teacher/cubits/subjectsOfClassSectionCubit.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/live.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/repositories/live_repository.dart';
import 'package:eschool_teacher/data/repositories/teacherRepository.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/bottomSheetTextFiledContainer.dart';
import 'package:eschool_teacher/ui/widgets/classSubjectsDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/customAppbar.dart';
import 'package:eschool_teacher/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_teacher/ui/widgets/customDropDownMenu.dart';
import 'package:eschool_teacher/ui/widgets/customRoundedButton.dart';
import 'package:eschool_teacher/ui/widgets/defaultDropDownLabelContainer.dart';
import 'package:eschool_teacher/ui/widgets/myClassesDropDownMenu.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class AddLiveScreen extends StatefulWidget {
  const AddLiveScreen({
    super.key,
    this.classSectionDetails,
    this.subject,
    required this.live,
  });

  final ClassSectionDetails? classSectionDetails;
  final Subject? subject;
  final Live? live;

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
            create: (context) => CreateLiveCubit(LiveRepository()),
          ),
        ],
        child: AddLiveScreen(
          subject: arguments['subject'],
          classSectionDetails: arguments['classSectionDetails'],
          live: arguments['live'],
        ),
      ),
    );
  }

  @override
  State<AddLiveScreen> createState() => _AddLiveScreenState();
}

class _AddLiveScreenState extends State<AddLiveScreen> {
  late CustomDropDownItem currentSelectedClassSection = CustomDropDownItem(
    index: 0,
    title: widget.classSectionDetails != null
        ? widget.classSectionDetails!.getFullClassSectionName()
        : context.read<MyClassesCubit>().getClassSectionName().first,
  );

  late CustomDropDownItem currentSelectedSubject = widget.subject == null
      ? CustomDropDownItem(
          index: 0,
          title: UiUtils.getTranslatedLabel(context, fetchingSubjectsKey))
      : CustomDropDownItem(
          index: 0, title: widget.subject!.subjectNameWithType);

  late final TextEditingController _liveDescriptionTextEditingController =
      TextEditingController(text: widget.live?.description);

  late bool refreshLivesInPreviousPage = false;

  @override
  void initState() {
    if (widget.classSectionDetails == null) {
      context.read<SubjectsOfClassSectionCubit>().fetchSubjects(
            context.read<MyClassesCubit>().getAllClasses().first.id,
          );
    }

    // put dueDate and dueFromTime and dueToTime if live != null
    if (widget.live != null) {
      dueDate = DateTime.parse(widget.live!.date!);
      dueFromTime = TimeOfDay(
        hour: int.parse(widget.live!.from!.split(":")[0]),
        minute: int.parse(widget.live!.from!.split(":")[1]),
      );
      dueToTime = TimeOfDay(
        hour: int.parse(widget.live!.to!.split(":")[0]),
        minute: int.parse(widget.live!.to!.split(":")[1]),
      );
    }
    super.initState();
  }

  void showErrorMessage(String errorMessage) {
    UiUtils.showBottomToastOverlay(
      context: context,
      errorMessage: errorMessage,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(refreshLivesInPreviousPage);
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildAddLiveForm(),
            _buildAppbar(),
          ],
        ),
      ),
    );
  }

  DateTime? dueDate;

  TimeOfDay? dueFromTime;
  TimeOfDay? dueToTime;

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

  Future<void> openTimePicker({required bool isFromTime}) async {
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
      if (isFromTime) {
        dueFromTime = temp;
      } else {
        dueToTime = temp;
      }
      setState(() {});
    }
  }

  void createLive() {
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

    if (_liveDescriptionTextEditingController.text.trim().isEmpty) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterAllFieldKey),
      );
      return;
    }

    if (dueDate == null || dueFromTime == null || dueToTime == null) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, pleaseEnterAllFieldKey),
      );
      return;
    }

    if (dueFromTime!.hour > dueToTime!.hour ||
        (dueFromTime!.hour == dueToTime!.hour &&
            dueFromTime!.minute > dueToTime!.minute)) {
      showErrorMessage(
        UiUtils.getTranslatedLabel(context, liveToDateBeforeFromDateKey),
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
    print("here322222222222222222222222222222222");

    context.read<CreateLiveCubit>().createLive(
        subjectId: selectedSubjectId,
        liveDescription: _liveDescriptionTextEditingController.text.trim(),
        files: [],
        date: DateFormat('yyyy-MM-dd').format(dueDate!).toString(),
        fromTime: convertTime(dueFromTime!),
        toTime: convertTime(dueToTime!),
        hour: dueFromTime!.hour.toString(),
        minute: dueFromTime!.minute.toString(),
        endHour: dueToTime!.hour.toString(),
        endMinute: dueToTime!.minute.toString(),
        );
  }

  // method take TimeOfDay and return hh:mm format
  String convertTime(TimeOfDay time) {
    String minute = time.minute.toString();
    if (minute.length == 1) {
      minute = "0$minute";
    }
    String hour = time.hour.toString();
    if (hour.length == 1) {
      hour = "0$hour";
    }
    return "$hour:$minute";
  }

  // enhance convertTime method to return 2 digit time

  Widget _buildAppbar() {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomAppBar(
        onPressBackButton: () {
          Navigator.of(context).pop(refreshLivesInPreviousPage);
        },
        title: UiUtils.getTranslatedLabel(
          context,
          widget.live == null ? addLiveKey : liveDescriptionKey,
        ),
      ),
    );
  }

  Widget _buildAddLiveForm() {
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
                          // _addedStudyMaterials = [];
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
                          // _addedStudyMaterials = [];
                        });
                      },
                      currentSelectedItem: currentSelectedSubject,
                      width: boxConstraints.maxWidth,
                    ),

              BottomSheetTextFieldContainer(
                margin: const EdgeInsets.only(bottom: 20),
                hintText:
                    UiUtils.getTranslatedLabel(context, liveDescriptionKey),
                maxLines: 3,
                contentPadding: const EdgeInsetsDirectional.only(start: 15),
                textEditingController: _liveDescriptionTextEditingController,
                disabled: widget.live != null,
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (widget.live == null) openDatePicker();
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
                      height: 50,
                      child: Text(
                        dueDate == null
                            ? UiUtils.getTranslatedLabel(context, liveDateKey)
                            : DateFormat('dd-MM-yyyy')
                                .format(dueDate!)
                                .toString(),
                        style: TextStyle(
                          color: dueDate == null ? hintTextColor : null,
                          fontSize: UiUtils.textFieldFontSize,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.live == null) {
                            openTimePicker(isFromTime: true);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          alignment: AlignmentDirectional.centerStart,
                          padding:
                              const EdgeInsetsDirectional.only(start: 20.0),
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
                            dueFromTime == null
                                ? UiUtils.getTranslatedLabel(
                                    context, liveTimeFromKey)
                                : convertTime(dueFromTime!),
                            style: TextStyle(
                              color: dueFromTime == null ? hintTextColor : null,
                              fontSize: UiUtils.textFieldFontSize,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          if (widget.live == null) {
                            openTimePicker(isFromTime: false);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          alignment: AlignmentDirectional.centerStart,
                          padding:
                              const EdgeInsetsDirectional.only(start: 20.0),
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
                            dueToTime == null
                                ? UiUtils.getTranslatedLabel(
                                    context, liveTimeToKey)
                                : convertTime(dueToTime!),
                            style: TextStyle(
                              color: dueToTime == null ? hintTextColor : null,
                              fontSize: UiUtils.textFieldFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              widget.live == null
                  ? BlocConsumer<CreateLiveCubit, CreateLiveState>(
                      listener: (context, state) {
                        if (state is CreateLiveSuccess) {
                          Navigator.of(context).pop(true);
                          _liveDescriptionTextEditingController.text = "";
                          refreshLivesInPreviousPage = true;
                          dueDate = null;
                          dueFromTime = null;
                          dueToTime = null;
                          // _addedStudyMaterials = [];
                          setState(() {});
                          UiUtils.showBottomToastOverlay(
                            context: context,
                            errorMessage: UiUtils.getTranslatedLabel(
                                context, liveAddedKey),
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          );
                        } else if (state is CreateLiveFailure) {
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
                        return CustomRoundedButton(
                          onTap: () {
                            print("here we create a meeting");
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (state is CreateLiveInProgress) {
                              return;
                            }
                            print(formatDateTimeToUTC(
                                DateFormat('yyyy-MM-dd')
                                    .format(dueDate!)
                                    .toString(),
                                dueFromTime!.hour.toString(),
                                dueFromTime!.minute.toString()));

                            print(calculateDurationInMinutes(
                                dueFromTime!.hour.toString(),
                                dueFromTime!.minute.toString(),
                                dueToTime!.hour.toString(),
                                dueToTime!.minute.toString()));
                            createLive();
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          buttonTitle:
                              UiUtils.getTranslatedLabel(context, addLiveKey),
                          showBorder: false,
                          child: state is CreateLiveInProgress
                              ? const CustomCircularProgressIndicator(
                                  strokeWidth: 2,
                                  widthAndHeight: 20,
                                )
                              : null,
                        );
                      },
                    )
                  : CustomRoundedButton(
                      backgroundColor: UiUtils.getColorScheme(context).primary,
                      buttonTitle: checkTimeRange(
                          widget.live!.date!,
                          widget.live!.from!,
                          widget.live!.to!,
                          extractDateAndTime(DateTime.now().toString())),
                      showBorder: false,
                      onTap: () {
                        var algiers = tz.getLocation('Africa/Algiers');
                        var now = tz.TZDateTime.now(
                            algiers); // TODO: get the current time
                        if (widget.live?.isNow == true &&
                            enterLive(
                                widget.live!.date!,
                                widget.live!.from!,
                                widget.live!.to!,
                                extractDateAndTime(
                                    DateTime.now().toString()))) {
                          Navigator.of(context).pushNamed(
                            Routes.videoCall,
                            arguments: {"callID": widget.live?.id.toString()},
                          );
                        }
                      },
                    )
            ],
          );
        },
      ),
    );
  }

  String extractDateAndTime(String timestamp) {
    // Parse the timestamp
    DateTime dateTime = DateTime.parse(timestamp);

    String dateOnly =
        "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

    String timeOnly =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";

    return '$dateOnly $timeOnly';
  }

  String checkTimeRange(String date, String from, String to, String current) {
    // Combine the date with the time strings
    String fromDateTimeString = "$date $from";
    String toDateTimeString = "$date $to";
    String currentDateTimeString = current;

    // Parse the combined date-time strings
    DateTime fromDateTime = DateTime.parse(fromDateTimeString);
    DateTime toDateTime = DateTime.parse(toDateTimeString);
    DateTime currentDateTime = DateTime.parse(currentDateTimeString);

    // Compare the times
    if (currentDateTime.isBefore(fromDateTime)) {
      return UiUtils.getTranslatedLabel(context, notStartedYetKey);
    } else if (currentDateTime.isAfter(toDateTime)) {
      return UiUtils.getTranslatedLabel(context, liveEndedKey);
    } else {
      return UiUtils.getTranslatedLabel(context, joinNowKey);
    }
  }

  bool enterLive(String date, String from, String to, String current) {
    // Combine the date with the time strings
    String fromDateTimeString = "$date $from";
    String toDateTimeString = "$date $to";
    String currentDateTimeString = current;

    // Parse the combined date-time strings
    DateTime fromDateTime = DateTime.parse(fromDateTimeString);
    DateTime toDateTime = DateTime.parse(toDateTimeString);
    DateTime currentDateTime = DateTime.parse(currentDateTimeString);

    // Compare the times
    if (currentDateTime.isBefore(fromDateTime)) {
      return false;
    } else if (currentDateTime.isAfter(toDateTime)) {
      return false;
    } else {
      return true;
    }
  }
}
