class ApkCategoriesModel {
  String idApk;
  String title;
  String subtitle;

  ApkCategoriesModel({
    required this.idApk,
    required this.title,
    required this.subtitle,
  });

  factory ApkCategoriesModel.fromJson(Map<String, dynamic> json) {
    return ApkCategoriesModel(
        idApk: json['id_apk'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '');
  }
}
