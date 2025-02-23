import 'package:eschool_teacher/data/models/shift.dart';
import 'package:eschool_teacher/data/models/stream.dart';

import 'medium.dart';

class ClassDetails {
  ClassDetails({
    required this.id,
    required this.name,
    required this.mediumId,
    required this.medium,
    required this.stream,
    required this.shift,
  });
  late final int id;
  late final String name;
  late final int mediumId;
  late final Medium medium;
  late final Stream? stream;
  late final Shift? shift;

  ClassDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    name = json['name'] ?? "";
    mediumId = json['medium_id'] ?? -1;
    medium = Medium.fromJson(json['medium'] ?? {});
    stream = json['streams'] == null || json['streams'] == ""
        ? null
        : Stream.fromJson(Map.from(json['streams']));
    shift = json['shifts'] == null || json['shifts'] == ""
        ? null
        : Shift.fromJson(Map.from(json['shifts']));
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['medium_id'] = mediumId;
    data['medium'] = medium.toJson();
    if (stream != null) {
      data['streams'] = stream!.toJson();
    }
    if (shift != null) {
      data['shift'] = shift!.toJson();
    }
    return data;
  }
}
