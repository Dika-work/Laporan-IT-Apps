class LaporanPekerjaanModel {
  String id;
  String apk;
  String problem;
  String pekerjaan;
  String tgl;
  String status;

  LaporanPekerjaanModel({
    required this.id,
    required this.apk,
    required this.problem,
    required this.pekerjaan,
    required this.tgl,
    required this.status,
  });

  factory LaporanPekerjaanModel.fromJson(Map<String, dynamic> json) {
    return LaporanPekerjaanModel(
        id: json['id'],
        apk: json['apk'],
        problem: json['problem'],
        pekerjaan: json['pekerjaan'],
        tgl: json['tgl'],
        status: json['status']);
  }
}
