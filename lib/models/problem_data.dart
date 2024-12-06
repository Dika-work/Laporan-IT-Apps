class ProblemData {
  String id;
  String fotoProfile;
  String username;
  String divisi;
  String apk;
  String lampiran;
  List<String> images;
  String tglDiproses;
  String statusKerja;
  String priority;

  ProblemData({
    required this.id,
    required this.fotoProfile,
    required this.username,
    required this.divisi,
    required this.apk,
    required this.lampiran,
    required this.images,
    required this.tglDiproses,
    required this.statusKerja,
    required this.priority,
  });

  factory ProblemData.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'http://10.3.80.4:8080';
    return ProblemData(
      id: json['id'] ?? '',
      fotoProfile: json['user_foto_user'] != null
          ? '$baseUrl/${json['user_foto_user']}'
          : '',
      username: json['username'] ?? '',
      divisi: json['divisi'] ?? '',
      apk: json['apk'] ?? '',
      lampiran: json['lampiran'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => '$baseUrl/${e['path']}')
              .toList() ??
          [],
      tglDiproses: json['tgl_diproses'] ?? '',
      statusKerja: json['status_kerja'] ?? '',
      priority: json['priority'] ?? '',
    );
  }
}
