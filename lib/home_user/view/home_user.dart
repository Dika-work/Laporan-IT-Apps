import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
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
    return Scaffold(
        backgroundColor: AppColors.primaryExtraSoft,
        body: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          // padding: const EdgeInsets.fromLTRB(
          //     CustomSize.md, CustomSize.sm, CustomSize.md, 0),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: CustomSize.sm),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(
                  CustomSize.sm, 0, CustomSize.md, CustomSize.sm),
              decoration: BoxDecoration(
                border: const Border(
                    bottom:
                        BorderSide(width: 1, color: AppColors.secondarySoft)),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(CustomSize.borderRadiusLg),
                    bottomRight: Radius.circular(CustomSize.borderRadiusLg)),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Langgeng Pranamas Sentosa',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(controller.username.value.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                      ],
                    ),
                    Image.asset(
                      'assets/images/lps.png',
                      width: 40,
                    )
                  ],
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: () async {},
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.POSTING),
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
                            'https://static.vecteezy.com/system/resources/thumbnails/019/900/322/small/happy-young-cute-illustration-face-profile-png.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: CustomSize.xs),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(CustomSize.sm),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  CustomSize.borderRadiusLg),
                              border: Border.all(
                                  width: 1, color: AppColors.secondarySoft)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: CustomSize.sm),
                            child: Text('Apa ada laporan bug?',
                                style: Theme.of(context).textTheme.bodyMedium),
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
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CustomSize.sm),
              child: PresenceCard(),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(CustomSize.sm),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text("History Problem",
            //           style: Theme.of(context)
            //               .textTheme
            //               .titleSmall
            //               ?.copyWith(fontWeight: FontWeight.w500)),
            //       GestureDetector(
            //         onTap: () {
            //           // Navigasi ke AllProblem dengan default kategori Problem Baru
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) =>
            //                   const AllProblem(initialCategory: 1),
            //             ),
            //           );
            //         },
            //         child: Text("show all",
            //             style: Theme.of(context)
            //                 .textTheme
            //                 .bodyMedium
            //                 ?.copyWith(
            //                     fontWeight: FontWeight.w400,
            //                     color: AppColors.primary)),
            //       ),
            //     ],
            //   ),
            // ),

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
                    nama: problem.usernameHash,
                    divisi: problem.divisi,
                  );
                },
              );
            })
          ],
        ));
  }
}
