import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eschool_teacher/data/models/studyMaterial.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';

class DownloadFileButton extends StatelessWidget {
  final StudyMaterial studyMaterial;
  const DownloadFileButton({Key? key, required this.studyMaterial})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () async {
        UiUtils.viewOrDownloadStudyMaterial(
          context: context,
          storeInExternalStorage: true,
          studyMaterial: studyMaterial,
        );
      },
      child: Container(
        width: 30,
        height: 30,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(UiUtils.getImagePath("download_icon.svg")),
      ),
    );
  }
}
