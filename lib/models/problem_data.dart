class ProblemData {
  String usernameHash;
  String divisi;
  String apk;
  String lampiran;
  String fotoUser;
  String tglDiproses;
  String statusKerja;
  String priority;

  ProblemData({
    required this.usernameHash,
    required this.divisi,
    required this.apk,
    required this.lampiran,
    required this.fotoUser,
    required this.tglDiproses,
    required this.statusKerja,
    required this.priority,
  });

  factory ProblemData.fromJson(Map<String, dynamic> json) {
    return ProblemData(
        usernameHash: json['username_hash'] ?? '',
        divisi: json['divisi'] ?? '',
        apk: json['apk'] ?? '',
        lampiran: json['lampiran'] ?? '',
        fotoUser: json['foto_user'] ?? '',
        tglDiproses: json['tgl_diproses'] ?? '',
        statusKerja: json['status_kerja'] ?? '',
        priority: json['priority'] ?? '');
  }
}
