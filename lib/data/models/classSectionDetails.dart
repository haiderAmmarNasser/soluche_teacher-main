import 'package:eschool_teacher/data/models/classDetails.dart';
import 'package:eschool_teacher/data/models/sectionDetails.dart';

class ClassSectionDetails {
  final int id;
  final ClassDetails classDetails;
  final SectionDetails sectionDetails;

  ClassSectionDetails({
    required this.id,
    required this.classDetails,
    required this.sectionDetails,
  });

  String getClassSectionName() {
    return "${classDetails.name} - ${sectionDetails.name}";
  }

  String getFullClassSectionName() {
    return "${classDetails.name} - ${sectionDetails.name} (${classDetails.medium.name})";
  }

  static ClassSectionDetails fromJson(Map<String, dynamic> json) {
    return ClassSectionDetails(
      sectionDetails: SectionDetails.fromJson(
          Map.from(json['section']),
          json['class']['streams'] == null || json['class']['streams'] == ""
              ? null
              : ' ${json['class']['streams']['name']}'),
      classDetails: ClassDetails.fromJson(Map.from(json['class'])),
      id: json['id'] ?? 0,
    );
  }
}
