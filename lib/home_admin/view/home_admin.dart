import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/home_admin/controller/home_admin_controller.dart';
import 'package:laporan/home_admin/view/edit_laporan.dart';
import 'package:laporan/laporan_pekerjaan/source/laporan_pekerjaan_source.dart';
import 'package:laporan/models/laporan_pekerjaan_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/dialogs.dart';
import 'package:laporan/utils/widgets/presence_card.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HomeAdmin extends GetView<HomeAdminController> {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    late Map<String, double> columnWidths = {
      'No': 50,
      'Tanggal': 100,
      'Apk': 80,
      'Status': 55,
      if (controller.laporanPekerjaan.isNotEmpty) 'Edit': 120,
      if (controller.laporanPekerjaan.isNotEmpty) 'Hapus': 120,
    };
    return Scaffold(
      backgroundColor: AppColors.primaryExtraSoft,
      body: Column(
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
              final result = await Get.toNamed(Routes.LAPORAN_PEKERJAAN);

              if (result == true) {
                controller.getLaporanPekerjaan(controller.usernameHash.value);
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
                          'Tulis pekerjaan hari ini..',
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
          const SizedBox(height: CustomSize.sm),
          Obx(() {
            if (controller.isLoading.value &&
                controller.laporanPekerjaan.isEmpty) {
              return Center(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(CustomSize.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              );
            } else {
              final dataSource = LaporanPekerjaanSource(
                  model: controller.displayedData,
                  onEdited: (LaporanPekerjaanModel model) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: EditLaporanPekerjaan(model: model),
                        );
                      },
                    );
                  },
                  onDelete: (LaporanPekerjaanModel model) {
                    print('ini id yg di klik ${model.id}');
                    CustomDialogs.deleteDialog(
                      context: context,
                      content:
                          'ini id yang di klik ${controller.generateHash(model.id)}',
                      onConfirm: () =>
                          controller.deleteLaporanPekerjaan(model.id),
                    );
                  });
              return Expanded(
                child: SfDataGrid(
                    source: dataSource,
                    frozenColumnsCount: 2,
                    rowHeight: 65,
                    verticalScrollController: controller.scrollController,
                    columnWidthMode: controller.laporanPekerjaan.isNotEmpty
                        ? ColumnWidthMode.fitByCellValue
                        : ColumnWidthMode.auto,
                    gridLinesVisibility: GridLinesVisibility.both,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    columns: [
                      GridColumn(
                          width: columnWidths['No']!,
                          columnName: 'No',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'No',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      GridColumn(
                          width: columnWidths['Tanggal']!,
                          columnName: 'Tanggal',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'Tanggal',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      GridColumn(
                          width: columnWidths['Apk']!,
                          columnName: 'Apk',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'Apk',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      GridColumn(
                          columnName: 'Pekerjaan',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'Pekerjaan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      GridColumn(
                          columnName: 'Problem',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'Problem',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      GridColumn(
                          width: columnWidths['Status']!,
                          columnName: 'Status',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'Status',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      if (controller.laporanPekerjaan.isNotEmpty)
                        GridColumn(
                            width: columnWidths['Edit']!,
                            columnName: 'Edit',
                            label: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  color: Colors.lightBlue.shade100,
                                ),
                                child: Text(
                                  'Edit',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ))),
                      if (controller.laporanPekerjaan.isNotEmpty)
                        GridColumn(
                            width: columnWidths['Hapus']!,
                            columnName: 'Hapus',
                            label: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  color: Colors.lightBlue.shade100,
                                ),
                                child: Text(
                                  'Hapus',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ))),
                    ]),
              );
            }
          })

          // Obx(() {
          //   if (controller.isLoading.value) {
          //     return const Center(child: CircularProgressIndicator());
          //   }

          //   if (controller.problemList.isEmpty) {
          //     return const Center(child: Text('Tidak ada laporan.'));
          //   }

          //   return Column(
          //     children: [
          //       Container(
          //         padding: const EdgeInsets.fromLTRB(
          //             CustomSize.sm, 0, CustomSize.sm, 0),
          //         margin: const EdgeInsets.only(top: CustomSize.sm),
          //         color: AppColors.white,
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text("Presence History",
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .titleSmall
          //                     ?.copyWith(fontWeight: FontWeight.w500)),
          //             GestureDetector(
          //               onTap: () {
          //                 // Navigasi ke AllProblem dengan default kategori Problem Baru
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) =>
          //                         const AllProblem(initialCategory: '0'),
          //                   ),
          //                 );
          //               },
          //               child: Text("show all",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyMedium
          //                       ?.copyWith(
          //                           fontWeight: FontWeight.w400,
          //                           color: AppColors.primary)),
          //             ),
          //           ],
          //         ),
          //       ),
          //       ListView.builder(
          //         shrinkWrap: true,
          //         physics: const NeverScrollableScrollPhysics(),
          //         padding: const EdgeInsets.only(top: CustomSize.sm),
          //         itemCount: controller.problemList.length,
          //         itemBuilder: (context, index) {
          //           final problem = controller.problemList[index];

          //           return Padding(
          //             padding: const EdgeInsets.only(bottom: CustomSize.sm),
          //             child: ExpandableContainer(
          //               nama: problem.username,
          //               fotoProfile: problem.fotoProfile,
          //               divisi: problem.divisi,
          //               apk: problem.apk,
          //               deskripsi: problem.lampiran,
          //               tglDiproses: problem.tglDiproses,
          //               priority: problem.priority,
          //               statusKerja: problem.statusKerja,
          //               fotoUser: problem.fotoUser,
          //               bgTransitionColor: AppColors.white,
          //             ),
          //           );
          //         },
          //       ),
          //     ],
          //   );
          // }),
        ],
      ),
    );
  }
}
