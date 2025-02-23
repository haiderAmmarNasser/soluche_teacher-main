class Medium {
  Medium({
    required this.name,
    required this.id,
  });
  late final String name;
  late final int id;

  Medium.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    id = json['id'] ?? -1;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
