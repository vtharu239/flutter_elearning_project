class DocumentCategoryModel {
  final int id;
  final String name;

  DocumentCategoryModel({required this.id, required this.name});

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
