import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan/apk/controller/apk_categories_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';

class AppsCategory extends GetView<ApkCategoriesController> {
  const AppsCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final RxnString selectedCategory =
        RxnString(Get.arguments as String?); // Menggunakan title sebagai nilai
    final RxString customCategoryTitle = ''.obs; // Untuk title "Lainnya"
    final RxString customCategorySubtitle = ''.obs; // Untuk subtitle "Lainnya"

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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: CustomSize.sm, vertical: CustomSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                return const Center(child: CircularProgressIndicator());
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
                      value: category.title, // Menggunakan title
                      title: category.title,
                      subtitle: category.subtitle,
                      selectedCategory: selectedCategory,
                      customCategoryTitle: customCategoryTitle,
                      customCategorySubtitle: customCategorySubtitle,
                    );
                  } else {
                    // Opsi "Lainnya"
                    return buildCustomCategoryTile(selectedCategory,
                        customCategoryTitle, customCategorySubtitle);
                  }
                },
              );
            }),
            const Spacer(),
            SizedBox(
              width: Get.width,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: CustomSize.sm),
                    ),
                    onPressed: selectedCategory.value != null
                        ? () {
                            // Jika "Lainnya" dipilih, gunakan nilai dari customCategoryTitle dan customCategorySubtitle
                            if (selectedCategory.value == 'Lainnya' &&
                                customCategoryTitle.value.isNotEmpty) {
                              Get.back(
                                result: ApkCategoriesModel(
                                  title: customCategoryTitle.value,
                                  subtitle: customCategorySubtitle.value,
                                ),
                              );
                            } else {
                              final selected = controller.apkCategories
                                  .firstWhere((category) =>
                                      category.title ==
                                      selectedCategory
                                          .value); // Menyesuaikan dengan title
                              Get.back(result: selected);
                            }
                          }
                        : null, // Nonaktifkan jika tidak ada yang dipilih
                    child: const Text('Selesai'),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPriorityTile({
    required String value,
    required String title,
    required String subtitle,
    required RxnString selectedCategory,
    required RxString customCategoryTitle,
    required RxString customCategorySubtitle,
  }) {
    return GestureDetector(
      onTap: () {
        selectedCategory.value = value;
        customCategoryTitle.value =
            ''; // Reset kategori custom jika lainnya tidak dipilih
        customCategorySubtitle.value = '';
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
              // Menggunakan String sebagai groupValue
              value: value,
              groupValue: selectedCategory.value,
              onChanged: (newValue) {
                selectedCategory.value = newValue!;
                customCategoryTitle.value = '';
                customCategorySubtitle.value = '';
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

  Widget buildCustomCategoryTile(RxnString selectedCategory,
      RxString customCategoryTitle, RxString customCategorySubtitle) {
    return GestureDetector(
      onTap: () {
        selectedCategory.value =
            'Lainnya'; // 'Lainnya' untuk menandai custom category
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
          final isSelected = selectedCategory.value == 'Lainnya';
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
                  },
                ),
                title: const Text(
                  'Lainnya',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(CustomSize.md,
                      CustomSize.xs, CustomSize.md, CustomSize.md),
                  child: TextFormField(
                    onChanged: (value) => customCategoryTitle.value = value,
                    decoration: const InputDecoration(
                      labelText: 'Masukkan kategori Anda',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
