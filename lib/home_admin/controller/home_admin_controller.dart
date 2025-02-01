import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:laporan/models/all_problem_admin.dart';
import 'package:laporan/models/laporan_pekerjaan_model.dart';
import 'package:laporan/utils/loadings/snackbar.dart';
import 'package:dio/dio.dart' as diomultipart;
import 'package:laporan/utils/widgets/dialogs.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:laporan/utils/routes/app_pages.dart';

class HomeAdminController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxString username = ''.obs;
  RxString usernameHash = ''.obs;
  RxString typeUser = ''.obs;
  RxString fotoUser = ''.obs;
  RxString divisi = ''.obs;

  RxList<ProblemDataForAdmin> problemList = <ProblemDataForAdmin>[].obs;
  RxList<LaporanPekerjaanModel> laporanPekerjaan =
      <LaporanPekerjaanModel>[].obs;
  RxList<LaporanPekerjaanModel> displayedData = <LaporanPekerjaanModel>[].obs;

  // lazy loading
  final ScrollController scrollController = ScrollController();
  int initialDataCount = 10;
  int loadMoreCount = 5;

  final localStorage = GetStorage();

  final diomultipart.Dio _dio = diomultipart.Dio(
    diomultipart.BaseOptions(
      baseUrl: 'http://192.168.1.8:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    // getLaporanPekerjaan(usernameHash.value);
    getLaporanAdmin();
    scrollController.addListener(scrollListener);
  }

  // lazy loading func
  void scrollListener() {
    print(
        "Scroll Position: ${scrollController.position.pixels}, Max Scroll: ${scrollController.position.maxScrollExtent}");
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading.value &&
        !isLoadingMore.value) {
      // Load more data when reaching the bottom
      loadMoreData();
    }
  }

  void loadMoreData() {
    // Load additional data if available
    if (displayedData.length < laporanPekerjaan.length &&
        !isLoadingMore.value) {
      print("Loading more data...");
      isLoadingMore.value = true;
      final nextData = laporanPekerjaan
          .skip(displayedData.length)
          .take(loadMoreCount)
          .toList();
      displayedData.addAll(nextData);

      print(
          'Additional data loaded: ${displayedData.length} items'); // Cetak jumlah data setelah load more
      isLoadingMore.value = false;
    }
  }

  fetchUserData() {
    isLoading.value = true;
    try {
      username.value = localStorage.read('username') ?? '';
      usernameHash.value = localStorage.read('username_hash') ?? '';
      typeUser.value = localStorage.read('type_user') ?? '';
      fotoUser.value = localStorage.read('foto_user') ?? '';
      divisi.value = localStorage.read('divisi') ?? '';
    } catch (e) {
      SnackbarLoader.warningSnackBar(
          title: 'Oops',
          message: 'Gagal mengambil data pengguna: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  getLaporanAdmin() async {
    isLoading.value = true;

    try {
      final response = await _dio.get('/get-laporan-admin');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print('..INI RESPONSE DARI GET ALL PROBLEM.. ${data.toList()}');

        // Simpan data ke RxList<ProblemDataForAdmin>
        problemList.value =
            data.map((e) => ProblemDataForAdmin.fromJson(e)).toList();
        print('Problem List: ${problemList.length} items loaded');
      }
    } on diomultipart.DioException catch (e) {
      if (e.response?.statusCode == 429) {
        SnackbarLoader.warningSnackBar(
            title: 'Limit Exceeded',
            message: 'Terlalu banyak permintaan. Coba lagi nanti');
      } else {
        SnackbarLoader.warningSnackBar(
            title: 'Error',
            message: e.response?.data['message'] ?? 'Terjadi kesalahan');
      }
    } finally {
      isLoading.value = false;
    }
  }

  getLaporanPekerjaan(String usernameHash) async {
    isLoading.value = true;

    try {
      final response = await _dio.get(
        '/getLaporanPekerjaan',
        queryParameters: {'username_hash': usernameHash},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data;
        final List<dynamic>? data = jsonResponse['data'];

        if (data != null) {
          laporanPekerjaan.value =
              data.map((e) => LaporanPekerjaanModel.fromJson(e)).toList();
          displayedData.assignAll(laporanPekerjaan.take(initialDataCount));
          print('Laporan Pekerjaan: ${laporanPekerjaan.length} items loaded');
        } else {
          print('Response data is null');
        }
      }
    } on diomultipart.DioException catch (e) {
      if (e.response?.statusCode == 429) {
        SnackbarLoader.warningSnackBar(
          title: 'Limit Exceeded',
          message: 'Terlalu banyak permintaan. Coba lagi nanti.',
        );
      } else {
        print('Error fetching data: $e');
        SnackbarLoader.warningSnackBar(
          title: 'Error',
          message: e.response?.data['message'] ?? 'Terjadi kesalahan.',
        );
      }
    } catch (e) {
      print('Unexpected error: $e');
      SnackbarLoader.warningSnackBar(
        title: 'Error',
        message: 'Kesalahan tak terduga. Silakan coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  deleteLaporanPekerjaan(String id) async {
    isLoading.value = true;
    try {
      String hashId = generateHash(id);

      final response = await _dio.delete(
        '/delete-pekerjaan',
        data: {'hash_id': hashId},
      );

      if (response.statusCode == 200) {
        // Hapus item dari problemList berdasarkan ID asli
        print('ini id yg di pilih $id');
        // laporanPekerjaan.removeWhere((element) => element.id == id);
        await getLaporanPekerjaan(usernameHash.value);
        SnackbarLoader.successSnackBar(
          title: 'Berhasil',
          message: response.data['message'] ?? 'Laporan berhasil dihapus',
        );
        Navigator.of(Get.overlayContext!).pop();
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Gagal',
          message: response.data['message'] ?? 'Gagal menghapus laporan',
        );
      }
    } on diomultipart.DioException catch (e) {
      if (e.response?.statusCode == 404) {
        SnackbarLoader.warningSnackBar(
          title: 'Tidak Ditemukan',
          message: 'Laporan pekerjaan tidak ditemukan',
        );
      } else if (e.response?.statusCode == 500) {
        SnackbarLoader.errorSnackBar(
          title: 'Kesalahan Server',
          message: 'Terjadi kesalahan pada server. Silakan coba lagi.',
        );
      } else {
        SnackbarLoader.errorSnackBar(
          title: 'Kesalahan',
          message: e.response?.data['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      SnackbarLoader.errorSnackBar(
        title: 'Kesalahan',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  changeStatusBug({
    required String hashId,
    required String tglAcc,
    required String statusKerja,
  }) async {
    isLoading.value = true;

    try {
      final data = {
        'hash_id': hashId,
        'tgl_acc': tglAcc,
        'status_kerja': statusKerja,
      };

      final response = await _dio.put(
        '/status-kerja',
        data: data,
      );

      if (response.statusCode == 200) {
        await getLaporanAdmin();
        print('ini datanya : $data');
        SnackbarLoader.successSnackBar(
          title: 'Sukses',
          message: 'Status laporan berhasil diubah',
        );
      } else {
        // Tampilkan snackbar error jika gagal
        SnackbarLoader.errorSnackBar(
          title: 'Gagal',
          message: response.data['message'] ?? 'Terjadi kesalahan.',
        );
      }
    } catch (e) {
      // Tampilkan snackbar error jika ada exception
      SnackbarLoader.errorSnackBar(
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
      );
      print('TERJADI ERROR SAAT CHANGE STATUS KERJA : $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProblemDataForAdmin>> getEventsByStatus(String status) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      return problemList
          .where((event) => event.statusKerja == status.toString())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  String generateHash(String id) {
    var bytes = utf8.encode(id); // Konversi ID ke bytes
    var digest = sha256.convert(bytes); // Hash dengan SHA-256
    return digest.toString(); // Ubah ke string
  }

  logout() {
    localStorage.remove('username');
    localStorage.remove('username_hash');
    localStorage.remove('type_user');
    localStorage.remove('foto_user');
    localStorage.remove('divisi');
    localStorage.write('isLoggedIn', false);
    Get.offAllNamed(Routes.LOGIN);
  }

  // generate PDF
  Future<Uint8List> generatePDF(LaporanPekerjaanModel selectedData,
      {bool withHeader = true}) async {
    print('Starting PDF generation...');
    CustomDialogs.loadingIndicator();

    final pdf = pw.Document();

    // Load fonts
    final regularFont =
        await rootBundle.load("assets/fonts/Urbanist-Regular.ttf");
    final ttfRegular = pw.Font.ttf(regularFont);
    final boldFont = await rootBundle.load("assets/fonts/Urbanist-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFont);

    // Load image from assets
    final ByteData imageData = await rootBundle.load('assets/images/lps.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final image = pw.MemoryImage(imageBytes);

    // Column headers

    if (withHeader) {
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(image, width: 60, height: 60),
                      pw.SizedBox(width: 10),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Langgeng Pranamas Sentosa',
                                style:
                                    pw.TextStyle(fontSize: 24, font: ttfBold)),
                            pw.SizedBox(width: 16),
                            pw.Text(
                                'Jl. Komp. Babek TN Jl. Rorotan No.3 Blok C, RT.1/RW.10, Rorotan,\nKec. Cakung, Jkt Utara, Daerah Khusus Ibukota Jakarta 14140',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontSize: 14, font: ttfRegular))
                          ])
                    ]),
                pw.Divider(),
                pw.SizedBox(height: 15),
                pw.Text('Laporan Pekerjaan',
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 18, font: ttfBold)),
                pw.SizedBox(height: 10),
                pw.Text('${username.value} - ${divisi.value}',
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 16, font: ttfRegular)),
                pw.SizedBox(height: 10),
                pw.Text(
                    DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(selectedData.tgl)),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
                pw.SizedBox(height: 20),
                pw.Text('Kegiatan hari ini :',
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 16, font: ttfRegular)),
                pw.SizedBox(height: 10),
                // Table body
                pw.Text(selectedData.pekerjaan,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
                pw.SizedBox(height: 15),
                pw.Text('Problem yang sedang dihadapkan :',
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(fontSize: 16, font: ttfRegular)),
                pw.SizedBox(height: 10),
                // Table body
                pw.Text(selectedData.problem,
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
                pw.SizedBox(height: 25),
                pw.Text(
                    '   Laporan ini diharapkan bukti dasar yang telah saya kerjakan pada ${selectedData.apk} yang dilakukan pada tanggal ${DateFormat('dd MMM yyyy').format(DateTime.parse(selectedData.tgl))}.',
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('Sekian,',
                      style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
                ),
                pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text('Terimakasih',
                        style: pw.TextStyle(fontSize: 14, font: ttfRegular)))
              ],
            ),
          );
        },
      ));
    } else {
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Pekerjaan',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(fontSize: 18, font: ttfBold)),
              pw.SizedBox(height: 10),
              pw.Text('${username.value} - ${divisi.value}',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(fontSize: 16, font: ttfRegular)),
              pw.SizedBox(height: 10),
              pw.Text(
                  DateFormat('dd MMM yyyy')
                      .format(DateTime.parse(selectedData.tgl)),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
              pw.SizedBox(height: 20),
              pw.Text('Kegiatan hari ini :',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(fontSize: 16, font: ttfRegular)),
              pw.SizedBox(height: 10),
              // Table body
              pw.Text(selectedData.pekerjaan,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
              pw.SizedBox(height: 15),
              pw.Text('Problem yang sedang dihadapkan :',
                  textAlign: pw.TextAlign.justify,
                  style: pw.TextStyle(fontSize: 16, font: ttfRegular)),
              pw.SizedBox(height: 10),
              // Table body
              pw.Text(selectedData.problem,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
              pw.SizedBox(height: 25),
              pw.Text(
                  '   Laporan ini diharapkan bukti dasar yang telah saya kerjakan pada ${selectedData.apk} yang dilakukan pada tanggal ${DateFormat('dd MMM yyyy').format(DateTime.parse(selectedData.tgl))}.',
                  textAlign: pw.TextAlign.justify,
                  style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('Sekian,',
                    style: pw.TextStyle(fontSize: 14, font: ttfRegular)),
              ),
              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('Terimakasih',
                      style: pw.TextStyle(fontSize: 14, font: ttfRegular)))
            ],
          );
        },
      ));
    }

    Navigator.of(Get.overlayContext!).pop();

    return pdf.save(); // Return PDF as bytes for preview
  }
}
