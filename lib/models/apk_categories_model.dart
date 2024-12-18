class ApkCategoriesModel {
  String title;
  String subtitle;

  ApkCategoriesModel({
    required this.title,
    required this.subtitle,
  });

  factory ApkCategoriesModel.fromJson(Map<String, dynamic> json) {
    return ApkCategoriesModel(
        title: json['title'] ?? '', subtitle: json['subtitle'] ?? '');
  }
  factory ApkCategoriesModel.fromString(String apkName) {
    return ApkCategoriesModel(
      title: apkName,
      subtitle: 'No subtitle available',
    );
  }
}
