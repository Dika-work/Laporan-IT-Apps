import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan/home_admin/controller/home_admin_controller.dart';
import 'package:laporan/problem/all_problem.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/presence_card.dart';
import 'package:laporan/utils/widgets/presence_tile.dart';

import '../../utils/widgets/tool_tip.dart';

class HomeAdmin extends GetView<HomeAdminController> {
  const HomeAdmin({super.key});

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
                      borderRadius: BorderRadius.circular(15.0),
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
                            child: Image.network(
                              'https://static.vecteezy.com/system/resources/thumbnails/019/900/322/small/happy-young-cute-illustration-face-profile-png.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.username.value,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              controller.typeUser.value,
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        Tooltip(
                          // Provide a global key with the "TooltipState" type to show
                          // the tooltip manually when trigger mode is set to manual.
                          key: controller.tooltipkey,
                          triggerMode: TooltipTriggerMode.manual,
                          showDuration: const Duration(seconds: 1),
                          message: 'I am a Tooltip',
                          child: const Text('Tap on the FAB'),
                        ),

                        NativeInfoPopup(
                          popupContent: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1, color: Colors.white),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print('Navigate ke profile');
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.settings,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Profile',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(color: Colors.white),
                                GestureDetector(
                                  onTap: () {
                                    // Logout Action
                                    Get.back();
                                    print('Logout');
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.logout,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Logout',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          contentOffset:
                              const Offset(0, 10), // Jarak popup dari ikon
                          arrowColor: Colors.black,
                          arrowSize: 10,
                          child: const Icon(
                            Icons.settings,
                            size: 27,
                          ), // Ukuran panah
                        ),
                        // InfoPopupWidget(
                        //   customContent: () => IntrinsicWidth(
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //           color: AppColors.primarySoft.withOpacity(.3),
                        //           borderRadius: BorderRadius.circular(10),
                        //           border: Border.all(
                        //               width: 1, color: AppColors.white)),
                        //       margin:
                        //           const EdgeInsets.only(right: CustomSize.md),
                        //       padding: const EdgeInsets.all(10),
                        //       child: Column(
                        //         mainAxisSize: MainAxisSize
                        //             .min, // Pastikan Column hanya sesuai konten
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           // Opsi Settings
                        //           GestureDetector(
                        //             onTap: () {
                        //               print('Navigate ke profile');
                        //             },
                        //             child: const Row(
                        //               children: [
                        //                 Icon(Icons.settings,
                        //                     color: Colors.white, size: 18),
                        //                 SizedBox(width: 8),
                        //                 Text(
                        //                   'Profile',
                        //                   style: TextStyle(color: Colors.white),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //           const Divider(
                        //               color: Colors.white), // Garis pemisah
                        //           // Opsi Logout
                        //           GestureDetector(
                        //             onTap: () {
                        //               Get.back();
                        //               controller.logout();
                        //             },
                        //             child: const Row(
                        //               children: [
                        //                 Icon(Icons.logout,
                        //                     color: Colors.white, size: 18),
                        //                 SizedBox(width: 8),
                        //                 Text(
                        //                   'Logout',
                        //                   style: TextStyle(color: Colors.white),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),

                        //   arrowTheme: const InfoPopupArrowTheme(
                        //     color: AppColors.black,
                        //     arrowDirection: ArrowDirection.up, // Arah panah
                        //   ),
                        //   dismissTriggerBehavior:
                        //       PopupDismissTriggerBehavior.onTapArea,
                        //   areaBackgroundColor: Colors.transparent,
                        //   indicatorOffset: Offset.zero,
                        //   contentOffset:
                        //       const Offset(0, 10), // Jarak konten dari trigger
                        //   onControllerCreated: (controller) {
                        //     print('Info Popup Controller Created');
                        //   },
                        //   child: const Icon(
                        //     Icons.settings,
                        //     size: 27,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const PresenceCard(),
                  const Text('admin'),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: CustomSize.sm),
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
                        nama: 'title test',
                        divisi: 'IT',
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
