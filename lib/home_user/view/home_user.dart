import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/laporan_bug/controller/posting_bug_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
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
      backgroundColor: AppColors.primaryExtraSoft,
      body: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // Bagian atas (Langgeng Pranamas Sentosa)
          RefreshIndicator(
            onRefresh: () async {
              print('ini dah di refresh');
            },
            child: Container(
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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
                      child: Image.network(
                        controller.fotoUser
                            .value, //https://static.vecteezy.com/system/resources/thumbnails/019/900/322/small/happy-young-cute-illustration-face-profile-png.png
                        fit: BoxFit.cover,
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
            child: PresenceCard(
              divisi: controller.divisi.value,
              onTapLogout: () => controller.logout(),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.problemList.isEmpty) {
              return const Center(child: Text('Tidak ada laporan.'));
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
                  laporanFoto: problem.fotoUser,
                  eventEdit: () async {
                    final result = await postinganController.getDataBeforeEdit(
                        usernameHash: controller.usernameHash.value,
                        lampiran: problem.lampiran,
                        fotoUserPath: problem.fotoUser,
                        apk: problem.apk,
                        priority: int.parse(problem.priority));

                    if (result == true) {
                      controller.getAllLaporan(controller.usernameHash.value);
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
