import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/laporan_bug/controller/posting_bug_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/loadings/snackbar.dart';
import 'package:laporan/utils/routes/app_pages.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/dialogs.dart';

import '../../utils/widgets/image widget/posting grid/image_grid_file.dart';

class PostingBug extends GetView<PostingBugController> {
  const PostingBug({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final username = storage.read('username');
    final fotoProfile = storage.read('foto_user');

    final divisi = storage.read('divisi');
    var priorityLevel = 1.obs;
    final Rxn<ApkCategoriesModel> selectedCategory = Rxn<ApkCategoriesModel>();

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
            if (controller.lampiranC.text.isEmpty &&
                controller.newImages.isEmpty &&
                controller.selectedCategory.value == null) {
              Get.back();
            } else {
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
                // Kembali ke halaman sebelumnya setelah reset
                Get.back();
              }
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Buat postingan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (selectedCategory.value == null) {
                SnackbarLoader.errorSnackBar(
                    title: 'Oops',
                    message: 'Silakan pilih kategori aplikasi terlebih dahulu');
                return;
              }

              if (controller.lampiranC.text.isEmpty) {
                SnackbarLoader.errorSnackBar(
                    title: 'Oops',
                    message: 'Anda belum menulis text yang mau dilaporkan');
                return;
              }

              // if (controller.newImages.isEmpty) {
              //   Get.snackbar(
              //     'Error',
              //     'Silakan pilih gambar terlebih dahulu.',
              //     snackPosition: SnackPosition.BOTTOM,
              //     backgroundColor: Colors.red,
              //     colorText: Colors.white,
              //   );
              //   return;
              // }

              final now = DateTime.now();
              final String formattedDate =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

              controller.postingLampiranBug(
                apk: selectedCategory.value!.title,
                priority: priorityLevel.value.toString(),
                tglDiproses: formattedDate,
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
          physics: controller.newImages.isEmpty
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              if (controller.lampiranC.text.isEmpty &&
                  controller.newImages.isEmpty &&
                  controller.selectedCategory.value == null) {
                Get.back();
              } else {
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
              }
            },
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
                      priorityColorFromValue(priorityLevel.value),
                      priorityIconFromValue(priorityLevel.value),
                      priorityNameFromValue(priorityLevel.value), () async {
                    final result = await Get.toNamed(
                      Routes.PRIORITY,
                      arguments: priorityLevel.value,
                    );
                    if (result != null) {
                      priorityLevel.value = result as int;
                    }
                  }, () async {
                    final result = await Get.toNamed(Routes.APK_CATEGORY,
                        arguments: selectedCategory.value?.title);
                    if (result != null && result is ApkCategoriesModel) {
                      selectedCategory.value = result;
                    }
                  },
                      selectedCategory.value != null
                          ? AppColors.accent.withOpacity(.6)
                          : AppColors.accent.withOpacity(.4),
                      selectedCategory.value?.title ?? 'Pilih Kategori'),
                  controller.newImages.isEmpty
                      ? _buildTextFormField(
                          context, 'Apa yang mau di laporkan?')
                      : _buildImageAndTextField(context)
                ],
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
        // validator: (value) {
        //   if (value == null || value.isEmpty) {
        //     return 'Kalimat lampiran tidak boleh kosong';
        //   }
        //   return null;
        // },
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

  Widget _buildImageAndTextField(BuildContext context) {
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
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Tuliskan sesuatu tentang foto ini...',
              hintStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        ImageGridFileWidget(
          imageFiles: controller.newImages,
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
              color: AppColors.secondarySoft)),
      child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () async =>
                    await controller.pickImages(ImageSource.gallery),
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
                onTap: () async =>
                    await controller.pickImages(ImageSource.camera),
                child: const Icon(
                  Ionicons.camera,
                  size: 25,
                  color: Color(0xff4699ff),
                ),
              ),
              label: 'Kamera',
            ),
          ]),
    );
  }
}
