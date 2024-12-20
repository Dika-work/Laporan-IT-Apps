import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan/apk/source/apk_categories_source.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/dialogs.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../controller/apk_categories_controller.dart';

class ApkView extends GetView<ApkCategoriesController> {
  const ApkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
        title: Text(
          'Apk category',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              CustomDialogs.defaultDialog(
                  context: context,
                  onCancel: () {
                    controller.apkC.clear();
                    controller.subtitleApkC.clear();
                    Navigator.of(Get.overlayContext!).pop();
                  },
                  onConfirm: () => controller.createApkCategory(),
                  contentWidget: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text('Tambah aplikasi baru',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        const SizedBox(height: CustomSize.spaceBtwItems),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: controller.apkC,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '* Nama aplikasi tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: Text(
                              'Nama aplikasi',
                              style: Theme.of(context).textTheme.labelMedium,
                            )),
                          ),
                        ),
                        const SizedBox(
                          height: CustomSize.sm,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: controller.subtitleApkC,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '* Keterangan aplikasi tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: Text(
                              'Keterangan aplikasi',
                              style: Theme.of(context).textTheme.labelMedium,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ));
            },
            child: Container(
              padding: const EdgeInsets.all(CustomSize.xs),
              margin: const EdgeInsets.fromLTRB(
                  0, CustomSize.sm, CustomSize.sm, CustomSize.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CustomSize.borderRadiusSm),
                color: AppColors.buttonPrimary,
              ),
              child: Text(
                'TAMBAH',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Container(
          width: Get.width,
          margin: const EdgeInsets.only(top: 10.0),
          color: Colors.white,
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.apkCategories.isEmpty) {
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
              final dataSource = ApkCategoriesSource(
                model: controller.apkCategories,
                onDelete: (ApkCategoriesModel model) {
                  CustomDialogs.deleteDialog(
                    context: context,
                    onConfirm: () => controller.deleteApkCategory(model.title),
                  );
                },
              );

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.getApkCategories();
                },
                child: SfDataGrid(
                    source: dataSource,
                    frozenColumnsCount: 2,
                    rowHeight: 65,
                    columnWidthMode: controller.apkCategories.isEmpty
                        ? ColumnWidthMode.fill
                        : ColumnWidthMode.auto,
                    gridLinesVisibility: GridLinesVisibility.both,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    columns: [
                      GridColumn(
                          width: 50,
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
                          columnName: 'Nama',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'Nama',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      GridColumn(
                          columnName: 'Keterangan',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.lightBlue.shade100,
                              ),
                              child: Text(
                                'Keterangan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ))),
                      if (controller.apkCategories.isNotEmpty)
                        GridColumn(
                            width: 120,
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
          })),
    );
  }
}
