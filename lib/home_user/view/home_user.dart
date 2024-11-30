import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        body: RefreshIndicator(
            onRefresh: () async {},
            child: SafeArea(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    CustomSize.md, CustomSize.sm, CustomSize.md, 0),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: CustomSize.md),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(CustomSize.sm,
                        CustomSize.sm, CustomSize.md, CustomSize.sm),
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: AppColors.secondarySoft),
                      borderRadius:
                          BorderRadius.circular(CustomSize.borderRadiusLg),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Image.asset(
                              'assets/images/lps.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: CustomSize.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.username.value,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              controller.divisi.value,
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        GestureDetector(
                          onTap: () => controller.logout(),
                          child: const Icon(Icons.logout,
                              color: Colors.black, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const PresenceCard(),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.POSTING),
                    child: Container(
                      margin: const EdgeInsets.only(top: CustomSize.sm),
                      padding: const EdgeInsets.fromLTRB(CustomSize.sm,
                          CustomSize.sm, CustomSize.md, CustomSize.sm),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(CustomSize.borderRadiusLg),
                          border: Border.all(
                              color: AppColors.secondarySoft, width: .8)),
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
                          const SizedBox(width: CustomSize.sm),
                          Text('Apa ada laporan bug?',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Expanded(child: Container()),
                          const Icon(Icons.create)
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: CustomSize.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("History Problem",
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
                                    const AllProblem(initialCategory: 1),
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
                    itemCount: 4,
                    itemBuilder: (context, index) => const Padding(
                      padding:
                          EdgeInsets.only(bottom: CustomSize.spaceBtwItems),
                      child: PresenceTile(
                        title: 'title test',
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
