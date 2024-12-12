import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/laporan_pekerjaan/controller/laporan_pekerjaan_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/dropdown_widget.dart';

class LaporanPekerjaanView extends GetView<LaporanPekerjaanController> {
  const LaporanPekerjaanView({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final username = storage.read('username');
    final fotoProfile = storage.read('foto_user');

    final divisi = storage.read('divisi');
    final Rxn<ApkCategoriesModel> selectedCategory = Rxn<ApkCategoriesModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
        title: Text(
          'Buat postingan',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (selectedCategory.value == null) {
                Get.snackbar(
                  'Error',
                  'Silakan pilih kategori aplikasi terlebih dahulu.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (controller.getStatusPekerjaan == 0) {
                Get.snackbar(
                  'Error',
                  'Silakan isi status pekerjaan terlebih dahulu',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final now = DateTime.now();
              final String formattedDate =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

              controller.postingLaporanPekerjaan(
                apk: selectedCategory.value!.title,
                tgl: formattedDate,
              );
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
                'BERIKUTNYA',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Form(
            key: controller.formKey,
            child: Container(
              width: Get.width,
              margin: const EdgeInsets.only(top: 10.0),
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: CustomSize.xs),
                  _buildUserAndCategorySection(
                      context, username, fotoProfile, divisi, () async {
                    final result = await Get.toNamed(Routes.APK_CATEGORY,
                        arguments: selectedCategory.value?.idApk);
                    if (result != null && result is ApkCategoriesModel) {
                      selectedCategory.value = result;
                    }
                  },
                      selectedCategory.value != null
                          ? AppColors.accent.withOpacity(.6)
                          : AppColors.accent.withOpacity(.4),
                      selectedCategory.value?.title ?? 'Pilih Kategori'),
                  _buildTextFormField(context, 'Problem', 'Pekerjaan')
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserAndCategorySection(
    BuildContext context,
    String username,
    String fotoProfile,
    String divisi,
    void Function()? onTapAppCategory,
    Color? colorAppCategory,
    String textAppCategory,
  ) {
    return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          ClipOval(
            child: SizedBox(
              width: 42,
              height: 42,
              child: CachedNetworkImage(
                imageUrl: fotoProfile,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$username - $divisi',
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: CustomSize.xs),
              Row(
                children: [
                  GestureDetector(
                    onTap: onTapAppCategory,
                    child: Container(
                      padding: const EdgeInsets.only(left: CustomSize.sm),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(.4),
                        borderRadius:
                            BorderRadius.circular(CustomSize.borderRadiusSm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Ionicons.apps,
                            color: AppColors.primary,
                            size: CustomSize.iconSm,
                          ),
                          const SizedBox(width: CustomSize.xs),
                          Text(
                            'App',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                          ),
                          const Icon(Icons.arrow_right_outlined,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: CustomSize.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: CustomSize.xs, horizontal: CustomSize.sm),
                    decoration: BoxDecoration(
                      color: colorAppCategory,
                      borderRadius:
                          BorderRadius.circular(CustomSize.borderRadiusSm),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textAppCategory,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]));
  }

  Widget _buildTextFormField(
      BuildContext context, String labelProblem, String labelPekerjaan) {
    return Container(
      width: Get.width,
      height: Get.height,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: CustomSize.md),
          TextFormField(
            controller: controller.problemC,
            keyboardType: TextInputType.text,
            maxLines: 10,
            minLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '* Jika tidak ada problem berikan -';
              }
              return null;
            },
            decoration: InputDecoration(
              label: Text(labelProblem),
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: CustomSize.spaceBtwInputFields),
          TextFormField(
            controller: controller.pekerjaanC,
            keyboardType: TextInputType.text,
            maxLines: 10,
            minLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '* Pekerjaan yang sudah dilakukan wajib di isi';
              }
              return null;
            },
            decoration: InputDecoration(
              label: Text(labelPekerjaan),
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: CustomSize.spaceBtwInputFields),
          Obx(
            () => DropDownWidget(
              value: controller.status.value,
              items: controller.listStatusPekerjaan.keys.toList(),
              onChanged: (String? value) {
                controller.status.value = value!;
                print(
                    'ini status pekerjaan yg di pilih : ${controller.getStatusPekerjaan}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
