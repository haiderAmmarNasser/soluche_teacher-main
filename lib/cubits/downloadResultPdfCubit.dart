import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:eschool_teacher/data/repositories/studentRepository.dart';

abstract class DownloadResultPdfState {}

class DownloadResultPdfInitial extends DownloadResultPdfState {}

class DownloadResultPdfDownloadSuccess extends DownloadResultPdfState {
  String filePath;
  DownloadResultPdfDownloadSuccess(
    this.filePath,
  );
}

class DownloadResultPdfDownloadFailure extends DownloadResultPdfState {
  final String errorMessage;

  DownloadResultPdfDownloadFailure(this.errorMessage);
}

class DownloadResultPdfDownloadInProgress extends DownloadResultPdfState {
  DownloadResultPdfDownloadInProgress();
}

class DownloadResultPdfCubit extends Cubit<DownloadResultPdfState> {
  final StudentRepository _studentRepository;

  DownloadResultPdfCubit(this._studentRepository)
      : super(DownloadResultPdfInitial());

  void downloadDownloadResultPdf({
    required int studentId,
    required String fileNamePrefix,
  }) {
    emit(DownloadResultPdfDownloadInProgress());
    _studentRepository
        .downloadExamResultPdf(
      studentId: studentId,
    )
        .then((value) async {
      String filePath = "";
      final path = (await getApplicationDocumentsDirectory()).path;
      filePath =
          "$path/Exam Results/${fileNamePrefix}_on_${DateTime.now()}.pdf";

      final File file = File(filePath);
      if (!file.existsSync()) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(value);
      emit(DownloadResultPdfDownloadSuccess(filePath));
    }).catchError((e) {
      emit(DownloadResultPdfDownloadFailure(e.toString()));
    }).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        emit(DownloadResultPdfDownloadFailure(""));
      },
    );
  }
}
