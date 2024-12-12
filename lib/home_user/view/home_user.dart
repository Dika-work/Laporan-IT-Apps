import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/laporan_bug/controller/posting_bug_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/problem/all_problem.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/presence_card.dart';
import 'package:laporan/utils/widgets/presence_tile.dart';

import '../controller/home_user_controller.dart';

class HomeUser extends GetView<HomeUserController> {
  const HomeUser({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Username Hash: ${controller.usernameHash.value}');
      await controller.getAllLaporan(controller.usernameHash.value);
    });
    final postinganController = Get.put(PostingBugController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryExtraSoft,
      body: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // Bagian atas (Langgeng Pranamas Sentosa)
          Container(
            margin: const EdgeInsets.only(bottom: CustomSize.sm),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(
                CustomSize.sm, 0, CustomSize.md, CustomSize.sm),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(
                  width: 1,
                  color: AppColors.secondarySoft,
                ),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(CustomSize.borderRadiusLg),
                bottomRight: Radius.circular(CustomSize.borderRadiusLg),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.7),
                  Colors.white.withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: CustomSize.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Langgeng Pranamas Sentosa',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          controller.username.value.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/lps.png',
                    width: 40,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Get.toNamed(Routes.POSTING);

              if (result == true) {
                controller.getAllLaporan(controller.usernameHash.value);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: CustomSize.sm),
              padding: const EdgeInsets.all(CustomSize.sm),
              decoration: const BoxDecoration(color: AppColors.white),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: CachedNetworkImage(
                        imageUrl: controller.fotoUser.value,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: CustomSize.xs),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(CustomSize.sm),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(CustomSize.borderRadiusLg),
                        border: Border.all(
                          width: 1,
                          color: AppColors.secondarySoft,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: CustomSize.sm),
                        child: Text(
                          'Apa ada laporan bug?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: CustomSize.sm),
                  const Icon(
                    Ionicons.image,
                    color: Color(0xff45bd63),
                  ),
                ],
              ),
            ),
          ),
          // Konten tambahan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CustomSize.sm),
            child: Obx(() {
              // Pastikan controller masalah sudah ter-observable
              final newProblemCount = controller.problemList
                  .where((e) => e.statusKerja == '0')
                  .length
                  .toString();

              final prosessProblem = controller.problemList
                  .where((e) => e.statusKerja == '1')
                  .length
                  .toString();

              final doneProblem = controller.problemList
                  .where((e) => e.statusKerja == '2')
                  .length
                  .toString();

              return PresenceCard(
                divisi: controller.divisi.value,
                newProblemCount: newProblemCount,
                prosessProblem: prosessProblem,
                doneProblem: doneProblem,
                onTapLogout: () => controller.logout(),
              );
            }),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.problemList.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: CustomSize.sm),
              itemCount: controller.problemList.length,
              itemBuilder: (context, index) {
                final problem = controller.problemList[index];
                return PresenceTile(
                  nama: problem.username,
                  fotoProfile: problem.fotoProfile,
                  divisi: problem.divisi,
                  apk: problem.apk,
                  deskripsi: problem.lampiran,
                  tglDiproses: problem.tglDiproses,
                  priority: problem.priority,
                  statusKerja: problem.statusKerja,
                  laporanFoto: problem.images,
                  eventEdit: () async {
                    // controller.isLoading.value =
                    //     true; // Mulai indikator loading

                    try {
                      // Panggil fungsi untuk mengambil data sebelum edit
                      final result =
                          await postinganController.getDataBeforeEdit(
                        hashId: controller.generateHash(problem.id),
                        usernameHash: controller.usernameHash.value,
                        lampiran: problem.lampiran,
                        imageUrls: problem.images,
                        apk: problem.apk,
                        priority: int.parse(problem.priority),
                      );

                      if (result == true) {
                        // Navigasi ke halaman edit jika berhasil
                        await Get.toNamed(
                          Routes.EDIT_POSTING,
                          arguments: {
                            'hash_id': controller.generateHash(problem.id),
                            'lampiran': problem.lampiran,
                            'images': problem.images,
                            'apk': problem.apk,
                            'priority': int.parse(problem.priority),
                          },
                        );

                        // Perbarui daftar laporan setelah navigasi berhasil
                        controller.getAllLaporan(controller.usernameHash.value);
                      } else {
                        Get.snackbar(
                          'Error',
                          'Gagal memuat data untuk diedit',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } catch (e) {
                      print('Error saat eventEdit: $e');
                      Get.snackbar(
                        'Error',
                        'Terjadi kesalahan saat memuat data',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  deleteEvent: () => controller.deleteLaporan(problem.id),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
