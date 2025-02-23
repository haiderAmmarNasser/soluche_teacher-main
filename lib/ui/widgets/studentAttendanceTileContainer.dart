import 'package:eschool_teacher/data/models/student.dart';
import 'package:eschool_teacher/ui/widgets/customUserProfileImageWidget.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/material.dart';

class StudentAttendanceTileContainer extends StatelessWidget {
  final Student student;
  final Function(int) updateAttendance;
  final bool isPresent;
  const StudentAttendanceTileContainer({
    Key? key,
    required this.isPresent,
    required this.student,
    required this.updateAttendance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          updateAttendance(student.id);
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.075),
                offset: const Offset(2.5, 2.5),
                blurRadius: 10,
                spreadRadius: 0.5,
              )
            ],
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width * (0.88),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.5),
                        ),
                        height: 50,
                        width: boxConstraints.maxWidth * (0.175),
                        child: CustomUserProfileImageWidget(
                          profileUrl: student.image,
                          radius: BorderRadius.circular(7.5),
                          color: Colors.black,
                        ),
                      ),
                      isPresent
                          ? const SizedBox()
                          : Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withOpacity(0.85),
                                borderRadius: BorderRadius.circular(7.5),
                              ),
                              height: 50,
                              width: boxConstraints.maxWidth * (0.175),
                              child: Icon(
                                Icons.close,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                    ],
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.045),
                  ),
                  SizedBox(
                    width: boxConstraints.maxWidth * (0.56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.getFullName(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                        Text(
                          "${UiUtils.getTranslatedLabel(context, rollNoKey)} - ${student.rollNumber}",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.75),
                            fontWeight: FontWeight.w400,
                            fontSize: 10.5,
                          ),
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.transparent),
                      color: isPresent
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    width: boxConstraints.maxWidth * (0.22),
                    child: Text(
                      UiUtils.getTranslatedLabel(
                        context,
                        isPresent ? presentKey : absentKey,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
