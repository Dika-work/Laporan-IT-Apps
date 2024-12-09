import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/laporan_bug/controller/posting_bug_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/dialogs.dart';

class EditPostingan extends GetView<PostingBugController> {
  const EditPostingan({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final username = storage.read('username');
    final fotoProfile = storage.read('foto_user');
    final divisi = storage.read('divisi');

    final arguments = Get.arguments as Map<String, dynamic>;
    final List<String> images = List<String>.from(arguments['images']);
    controller.lampiranC.text = arguments['lampiran'] ?? '';
    controller.selectedCategory.value =
        ApkCategoriesModel.fromString(arguments['apk'] ?? '');
    controller.priorityLevel.value =
        int.tryParse(arguments['priority'].toString()) ?? 1;

    String priorityNameFromValue(int value) {
      Map<int, String> priorityName = {
        1: 'Ringan',
        2: 'Sedang',
        3: 'Berat',
        4: 'Urgent',
      };
      return priorityName[value] ?? 'Unknown';
    }

    Color priorityColorFromValue(int value) {
      Map<int, Color> priorityColors = {
        1: Colors.yellow,
        2: Colors.blue,
        3: Colors.orange,
        4: Colors.red,
      };
      return priorityColors[value] ?? Colors.grey;
    }

    Icon priorityIconFromValue(int value) {
      Map<int, IconData> priorityIcon = {
        1: Iconsax.emoji_happy,
        2: Iconsax.like_shapes,
        3: Iconsax.emoji_sad,
        4: Ionicons.warning,
      };
      return Icon(
        priorityIcon[value] ?? Iconsax.activity,
        color: AppColors.primary,
        size: CustomSize.iconSm,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final isConfirmed = await CustomDialogs.defaultDialog(
              context: Get.overlayContext!,
              contentWidget: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Perubahan belum disimpan. Apakah Anda ingin melanjutkan?'),
                ],
              ),
              onConfirm: () {
                controller.resetEditState();
                Navigator.of(Get.overlayContext!).pop(true);
                Navigator.of(Get.overlayContext!).pop(true);
              },
              onCancel: () {
                Navigator.of(Get.overlayContext!).pop(false);
              },
              confirmText: 'Kembali',
            );

            if (isConfirmed == true) {
              Get.back();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Edit Postingan',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              if (controller.selectedCategory.value == null) {
                Get.snackbar(
                  'Error',
                  'Silakan pilih kategori aplikasi terlebih dahulu.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              // Ambil hash_id dari arguments
              final hashId = Get.arguments['hash_id'];
              if (hashId == null) {
                Get.snackbar(
                  'Error',
                  'Hash ID tidak ditemukan.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              // Panggil controller untuk update laporan
              await controller.updateLaporan(
                hashId: hashId,
                lampiran: controller.lampiranC.text,
                apk: controller.selectedCategory.value!,
                priority: controller.priorityLevel.value,
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
                'SIMPAN',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          physics: controller.selectedImages.isEmpty
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final isConfirmed = await CustomDialogs.defaultDialog(
                context: Get.overlayContext!,
                contentWidget: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Perubahan belum disimpan. Apakah Anda ingin melanjutkan?'),
                  ],
                ),
                onConfirm: () {
                  controller.resetEditState();

                  Navigator.of(Get.overlayContext!).pop(true);
                  Navigator.of(Get.overlayContext!).pop(true);
                },
                onCancel: () {
                  Navigator.of(Get.overlayContext!).pop(false); // Batal keluar
                },
                confirmText: 'Kembali',
              );

              if (isConfirmed == true) {
                Navigator.of(Get.overlayContext!).pop(true);
              }
            },
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
                        context,
                        username,
                        fotoProfile,
                        divisi,
                        priorityColorFromValue(controller.priorityLevel.value),
                        priorityIconFromValue(controller.priorityLevel.value),
                        priorityNameFromValue(controller.priorityLevel.value),
                        () async {
                      final result = await Get.toNamed(
                        Routes.PRIORITY,
                        arguments: controller.priorityLevel.value,
                      );
                      if (result != null) {
                        controller.priorityLevel.value = result as int;
                      }
                    }, () async {
                      final result = await Get.toNamed(Routes.APK_CATEGORY,
                          arguments: controller.selectedCategory.value?.idApk);
                      if (result != null && result is ApkCategoriesModel) {
                        controller.selectedCategory.value = result;
                      }
                    },
                        controller.selectedCategory.value != null
                            ? AppColors.accent.withOpacity(.6)
                            : AppColors.accent.withOpacity(.4),
                        controller.selectedCategory.value?.title ??
                            'Pilih Kategori'),
                    controller.selectedImages.isEmpty
                        ? _buildTextFormField(
                            context, 'Apa yang mau di laporkan?')
                        : _buildImageAndTextField(context, images)
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildUserAndCategorySection(
    BuildContext context,
    String username,
    String fotoProfile,
    String divisi,
    Color? priorityColor,
    Icon iconPriority,
    String priorityText,
    void Function()? onTapPriority,
    void Function()? onTapAppCategory,
    Color? colorAppCategory,
    String textAppCategory,
  ) {
    return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                    onTap: onTapPriority,
                    child: Container(
                      padding: const EdgeInsets.only(left: CustomSize.sm),
                      decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(.4),
                          borderRadius:
                              BorderRadius.circular(CustomSize.borderRadiusSm)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Ionicons.earth,
                            color: AppColors.primary,
                            size: CustomSize.iconSm,
                          ),
                          const SizedBox(width: CustomSize.xs),
                          Text(
                            'Priority',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
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
                        color: priorityColor,
                        borderRadius:
                            BorderRadius.circular(CustomSize.borderRadiusSm)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconPriority,
                        const SizedBox(width: CustomSize.xs),
                        Text(
                          priorityText,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildTextFormField(BuildContext context, String hintText) {
    return Container(
      width: Get.width,
      height: Get.height,
      padding: const EdgeInsets.only(left: 16.0),
      child: TextFormField(
        controller: controller.lampiranC,
        keyboardType: TextInputType.text,
        maxLines: 10,
        minLines: 1,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (value) {
          controller.textVisible.value = value.isEmpty;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Kalimat lampiran tidak boleh kosong';
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildImageAndTextField(BuildContext context, List<String> imageUrls) {
    return Column(
      children: [
        Container(
          width: Get.width,
          padding: const EdgeInsets.only(left: 16.0),
          child: TextFormField(
            controller: controller.lampiranC,
            keyboardType: TextInputType.text,
            maxLines: 10,
            minLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
            onChanged: (value) {
              controller.textVisible.value = value.isEmpty;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kalimat lampiran tidak boleh kosong';
              }
              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Tuliskan sesuatu tentang foto ini...',
              hintStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Menampilkan 3 gambar per baris
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = imageUrls[index];
            return Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 0,
                  top: 10,
                  child: IconButton(
                    onPressed: () {
                      Get.snackbar(
                        'Info',
                        'Anda tidak dapat menghapus gambar yang sudah ada di laporan ini.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(
                      Ionicons.lock_closed_outline,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          strokeAlign: BorderSide.strokeAlignOutside,
          style: BorderStyle.solid,
          color: AppColors.secondarySoft,
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => controller.pickImages(ImageSource.gallery),
              child: const Icon(
                Ionicons.image,
                size: 25,
                color: Color(0xff45bd63),
              ),
            ),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => controller.pickImages(ImageSource.camera),
              child: const Icon(
                Ionicons.camera,
                size: 25,
                color: Color(0xff4699ff),
              ),
            ),
            label: 'Kamera',
          ),
        ],
      ),
    );
  }
}
