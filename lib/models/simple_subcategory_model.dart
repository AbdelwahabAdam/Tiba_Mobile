class SimpleSubCategory {
  final int id;
  final String name;

  SimpleSubCategory({required this.id, required this.name});

  factory SimpleSubCategory.fromJson(Map<String, dynamic> json) {
    return SimpleSubCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
