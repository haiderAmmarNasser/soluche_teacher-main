import 'package:eschool_teacher/data/models/group_model.dart';
import 'package:eschool_teacher/data/models/studyMaterial.dart';

class Lesson {
  Lesson({
    required this.id,
    required this.name,
    required this.description,
    required this.classSectionId,
    required this.subjectId,
    required this.studyMaterials,
    required this.topicsCount,
    required this.price,
    required this.group,
  });
  late final int id;
  late final List<StudyMaterial> studyMaterials;

  late final String name;
  late final String description;
  late final int classSectionId;
  late final int subjectId;
  late final int topicsCount;
  late final String price;
  late final List<GroupModel> group;

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    topicsCount = json['topic_count'] ?? 0;
    description = json['description'] ?? "";
    classSectionId = json['class_section_id'] ?? 0;
    subjectId = json['subject_id'] ?? 0;
    studyMaterials = ((json['file'] ?? []) as List)
        .map((file) => StudyMaterial.fromJson(Map.from(file)))
        .toList();
    price = json['price'] ?? '0';
    group = ((json['group'] ?? []) as List)
        .map((group) => GroupModel.fromJson(Map.from(group)))
        .toList();
  }
}
