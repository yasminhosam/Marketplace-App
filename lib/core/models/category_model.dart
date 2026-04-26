class CategoryModel {
  final String id;
  final String name;
  final int priority;
  final String? imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.priority,
    this.imageUrl,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: documentId,
      name: map['name'] ?? '',
      priority: map['priority'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'priority': priority,
      'imageUrl': imageUrl,
    };
  }
}