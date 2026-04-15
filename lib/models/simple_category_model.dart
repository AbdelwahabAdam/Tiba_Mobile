class SimpleCategory {
  final int id;
  final String name;

  SimpleCategory({required this.id, required this.name});

  factory SimpleCategory.fromJson(Map<String, dynamic> json) {
    return SimpleCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
