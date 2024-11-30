import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/laporan_bug/controller/posting_bug_controller.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/dialogs.dart';

class PostingBug extends GetView<PostingBugController> {
  const PostingBug({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final fotoUser = storage.read('foto_user');
    final username = storage.read('username');
    final divisi = storage.read('divisi');
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
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(CustomSize.xs),
              margin: const EdgeInsets.fromLTRB(
                  0, CustomSize.sm, CustomSize.sm, CustomSize.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(CustomSize.borderRadiusSm),
                  color: AppColors.buttonPrimary),
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
      body: SingleChildScrollView(
          physics: controller.lampiranC.text.isEmpty
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                return;
              }

              CustomDialogs.defaultDialog(
                  context: Get.overlayContext!,
                  contentWidget: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Perubahan belum disimpan. Apakah Anda ingin melanjutkan?'),
                    ],
                  ),
                  onConfirm: () {
                    Navigator.of(Get.overlayContext!).pop();
                    Navigator.of(Get.overlayContext!).pop();
                  },
                  confirmText: 'Kembali');
            },
            child: SizedBox(
              width: Get.width,
              height: Get.height,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 10.0),
                    margin: const EdgeInsets.only(top: 10.0),
                    color: Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          // backgroundImage: NetworkImage(fotoUser),
                          backgroundColor: Colors.blue,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                ),
                                Text(
                                  divisi ?? '',
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border.all(
                strokeAlign: BorderSide.strokeAlignOutside,
                style: BorderStyle.solid,
                color: AppColors.secondarySoft)),
        child: BottomNavigationBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Ionicons.image,
                    color: Color(0xff45bd63),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Ionicons.camera,
                    color: Color(0xff4699ff),
                  ),
                ),
                label: '',
              ),
            ]),
      ),
    );
  }
}
