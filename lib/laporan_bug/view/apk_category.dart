import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan/apk/controller/apk_categories_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class AppsCategory extends GetView<ApkCategoriesController> {
  const AppsCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final RxnString selectedCategory = RxnString(Get.arguments as String?);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
        title: Text(
          'Pilih Kategori Aplikasi',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
        ),
        actions: [
          Obx(() => GestureDetector(
                onTap: selectedCategory.value != null
                    ? () {
                        if (selectedCategory.value == 'Lainnya') {
                          // Tambahkan kategori custom ke model
                          final customCategory = ApkCategoriesModel(
                            title: selectedCategory.value!,
                            subtitle: '',
                          );

                          // Tambahkan kategori ke daftar (jika diperlukan)
                          if (!controller.apkCategories.any((category) =>
                              category.title == customCategory.title)) {
                            controller.apkCategories.add(customCategory);
                          }

                          // Kembali dengan kategori custom
                          Get.back(result: customCategory);
                        } else {
                          // Ambil data kategori reguler
                          final selected = controller.apkCategories.firstWhere(
                            (category) =>
                                category.title == selectedCategory.value,
                            orElse: () => ApkCategoriesModel(
                              title: 'Unknown',
                              subtitle: 'Tidak ada kategori ditemukan',
                            ),
                          );
                          Get.back(result: selected);
                        }
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(CustomSize.xs),
                  margin: const EdgeInsets.fromLTRB(
                      0, CustomSize.sm, CustomSize.sm, CustomSize.sm),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(CustomSize.borderRadiusSm),
                    color: selectedCategory.value != null
                        ? AppColors.buttonPrimary
                        : AppColors.buttonDisabled,
                  ),
                  child: Text(
                    'SELESAI',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            CustomSize.sm, CustomSize.md, CustomSize.sm, 0),
        children: [
          Text(
            'Apa yang dimaksud dengan kategori aplikasi dalam postingan Anda?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: CustomSize.sm),
          const Text(
              'Postingan Anda memerlukan kategori aplikasi sebagai dasar untuk laporan bug yang diajukan.'),
          const SizedBox(height: CustomSize.sm),
          RichText(
              text: TextSpan(
                  text: 'Postingan Anda ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: AppColors.textPrimary),
                  children: [
                TextSpan(
                    text: 'tidak dapat dikirim',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: ', jika bagian ini belum diisi.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.apply(color: AppColors.textPrimary))
              ])),
          const SizedBox(height: CustomSize.sm),
          Text(
            'Pilih kategori aplikasi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return ListView.builder(
                padding: const EdgeInsets.only(top: CustomSize.sm),
                itemCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: CustomSize.xs),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: Get.width,
                        height: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              );
            }
            if (controller.apkCategories.isEmpty) {
              return const Center(child: Text('Tidak ada kategori tersedia'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.apkCategories.length +
                  1, // Tambah 1 untuk "Lainnya"
              itemBuilder: (context, index) {
                if (index < controller.apkCategories.length) {
                  final category = controller.apkCategories[index];
                  return buildPriorityTile(
                    value: category.title,
                    title: category.title,
                    subtitle: category.subtitle,
                    selectedCategory: selectedCategory,
                  );
                } else {
                  // Opsi "Lainnya"
                  return buildCustomCategoryTile(
                    selectedCategory,
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget buildPriorityTile({
    required String value,
    required String title,
    required String subtitle,
    required RxnString selectedCategory,
  }) {
    return GestureDetector(
      onTap: () {
        selectedCategory.value =
            value; // Perbarui selectedCategory dengan title kategori yang dipilih
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.secondarySoft,
              width: 1.0,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Obx(
            () => Radio<String>(
              value: value,
              groupValue: selectedCategory.value,
              onChanged: (newValue) {
                selectedCategory.value = newValue!;
              },
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }

  Widget buildCustomCategoryTile(
    RxnString selectedCategory,
  ) {
    return GestureDetector(
      onTap: () {
        selectedCategory.value =
            'Lainnya'; // 'Lainnya' untuk menandai custom category
        print('ini saat memilih Lainnya : ${selectedCategory.value}');
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.secondarySoft,
              width: 1.0,
            ),
          ),
        ),
        child: Obx(() {
          // final isSelected = selectedCategory.value == 'Lainnya';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Radio<String>(
                  value: 'Lainnya',
                  groupValue: selectedCategory.value,
                  onChanged: (newValue) {
                    selectedCategory.value = newValue!;
                    print('RadioButton changed to: $newValue');
                  },
                ),
                title: const Text(
                  'Lainnya',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
