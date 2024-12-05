import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan/home_admin/controller/home_admin_controller.dart';
import 'package:laporan/problem/all_problem.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/expandable_container.dart';
import 'package:laporan/utils/widgets/presence_card.dart';
import 'package:laporan/utils/widgets/presence_tile.dart';

class HomeAdmin extends GetView<HomeAdminController> {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
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
                            '${controller.username.value.toUpperCase()} - ${controller.typeUser.value.toUpperCase()}',
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

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(
                      CustomSize.sm, 0, CustomSize.sm, 0),
                  margin: const EdgeInsets.only(top: CustomSize.sm),
                  color: AppColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Presence History",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke AllProblem dengan default kategori Problem Baru
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AllProblem(initialCategory: '0'),
                            ),
                          );
                        },
                        child: Text("show all",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: CustomSize.sm),
                  itemCount: controller.problemList.length,
                  itemBuilder: (context, index) {
                    final problem = controller.problemList[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: CustomSize.sm),
                      child: ExpandableContainer(
                        nama: problem.username,
                        fotoProfile: problem.fotoProfile,
                        divisi: problem.divisi,
                        apk: problem.apk,
                        deskripsi: problem.lampiran,
                        tglDiproses: problem.tglDiproses,
                        priority: problem.priority,
                        statusKerja: problem.statusKerja,
                        fotoUser: problem.fotoUser,
                        bgTransitionColor: AppColors.white,
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
