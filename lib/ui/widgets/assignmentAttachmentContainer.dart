import 'package:eschool_teacher/cubits/deleteStudyMaterialCubit.dart';
import 'package:eschool_teacher/data/models/studyMaterial.dart';
import 'package:eschool_teacher/data/repositories/studyMaterialRepositoy.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/ui/widgets/confirmDeleteDialog.dart';
import 'package:eschool_teacher/ui/widgets/deleteButton.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignmentAttachmentContainer extends StatelessWidget {
  final bool showDeleteButton;
  final StudyMaterial studyMaterial;
  final Function(int)? onDeleteCallback;
  const AssignmentAttachmentContainer({
    Key? key,
    required this.showDeleteButton,
    required this.studyMaterial,
    this.onDeleteCallback,
  }) : super(key: key);

  Widget _buildFileName(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.viewOrDownloadStudyMaterial(
            context: context,
            storeInExternalStorage: true,
            studyMaterial: studyMaterial);
      },
      child: Text(
        studyMaterial.fileName,
        style: const TextStyle(
          color: assignmentViewButtonColor,
          fontWeight: FontWeight.w500,
          height: 1.25,
          fontSize: 13.5,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeleteStudyMaterialCubit(StudyMaterialRepository()),
      child: Builder(
        builder: (context) {
          return BlocConsumer<DeleteStudyMaterialCubit,
              DeleteStudyMaterialState>(
            listener: (context, state) {
              //
              if (state is DeleteStudyMaterialSuccess) {
                onDeleteCallback?.call(studyMaterial.id);
              } else if (state is DeleteStudyMaterialFailure) {
                UiUtils.showBottomToastOverlay(
                  context: context,
                  //
                  errorMessage:
                      UiUtils.getTranslatedLabel(context, unableToDeleteKey),
                  backgroundColor: Theme.of(context).colorScheme.error,
                );
              }
            },
            builder: (context, state) {
              return Opacity(
                opacity: state is DeleteStudyMaterialInProgress ? 0.5 : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * (0.85),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      return showDeleteButton
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildFileName(context)),
                                DeleteButton(
                                  onTap: () {
                                    if (state
                                        is DeleteStudyMaterialInProgress) {
                                      return;
                                    }
                                    showDialog<bool>(
                                      context: context,
                                      builder: (_) =>
                                          const ConfirmDeleteDialog(),
                                    ).then((value) {
                                      if (value != null && value) {
                                        context
                                            .read<DeleteStudyMaterialCubit>()
                                            .deleteStudyMaterial(
                                              fileId: studyMaterial.id,
                                            );
                                      }
                                    });
                                  },
                                )
                              ],
                            )
                          : _buildFileName(context);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
