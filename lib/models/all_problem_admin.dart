class ProblemDataForAdmin {
  String id;
  String fotoProfile;
  String username;
  String divisi;
  String apk;
  String lampiran;
  List<String> fotoUser;
  String tglDiproses;
  String statusKerja;
  String priority;

  ProblemDataForAdmin({
    required this.id,
    required this.fotoProfile,
    required this.username,
    required this.divisi,
    required this.apk,
    required this.lampiran,
    required this.fotoUser,
    required this.tglDiproses,
    required this.statusKerja,
    required this.priority,
  });

  factory ProblemDataForAdmin.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'http://192.168.1.9:8080';
    return ProblemDataForAdmin(
        id: json['id'] ?? '',
        fotoProfile: json['user_foto_user'] != null
            ? '$baseUrl/${json['user_foto_user']}'
            : '',
        username: json['username'] ?? '',
        divisi: json['divisi'] ?? '',
        apk: json['apk'] ?? '',
        lampiran: json['lampiran'] ?? '',
        fotoUser: (json['images'] as List<dynamic>?)
                ?.map((e) => '$baseUrl/${e['path']}')
                .toList() ??
            [],
        tglDiproses: json['tgl_diproses'] ?? '',
        statusKerja: json['status_kerja'] ?? '',
        priority: json['priority'] ?? '');
  }
}
