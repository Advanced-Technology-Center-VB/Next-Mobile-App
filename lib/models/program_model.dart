class ProgramModel {
  int id;
  String name;
  String description;
  String about;
  String prerequisites;
  String category;

  ProgramModel({required this.id, required this.name, this.description = "", this.about = "", this.prerequisites = "", this.category = ""});

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'description': String description,
        'about': String about,
        'prerequisites': String prerequisites,
        'category' : Map category
      } => ProgramModel(id: id, name: name, description: description, about: about, prerequisites: prerequisites, category: category["name"]),
      _ => throw const FormatException("Failed to load Class")
    };
  }

  factory ProgramModel.fromJsonSimple(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name
      } => ProgramModel(id: id, name: name),
      _ => throw const FormatException("Failed to load Class")
    };
  }
}