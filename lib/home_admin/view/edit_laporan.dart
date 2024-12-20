import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:laporan/apk/controller/apk_categories_controller.dart';
import 'package:laporan/laporan_pekerjaan/controller/laporan_pekerjaan_controller.dart';
import 'package:laporan/models/apk_categories_model.dart';
import 'package:laporan/models/laporan_pekerjaan_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/loadings/loading_img.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/dropdown_widget.dart';

class EditLaporanPekerjaan extends StatefulWidget {
  const EditLaporanPekerjaan({super.key, required this.model});

  final LaporanPekerjaanModel model;

  @override
  State<EditLaporanPekerjaan> createState() => _EditLaporanPekerjaanState();
}

class _EditLaporanPekerjaanState extends State<EditLaporanPekerjaan> {
  late String id;
  late TextEditingController problem;
  late TextEditingController pekerjaan;
  late String status;
  late String apk;

  final storage = GetStorage();

  final Map<String, String> statusMap = {
    'Selesai': "1",
    'Belum selesai': "2",
  };

  late ApkCategoriesController apkCategoryController;
  late LaporanPekerjaanController laporanPekerjaanController;

  @override
  void initState() {
    super.initState();
    id = widget.model.id;
    problem = TextEditingController(text: widget.model.problem);
    pekerjaan = TextEditingController(text: widget.model.pekerjaan);
    status = widget.model.status == '1' ? 'Selesai' : 'Belum selesai';
    apk = widget.model.apk;

    apkCategoryController = Get.put(ApkCategoriesController());
    laporanPekerjaanController = Get.put(LaporanPekerjaanController());

    apkCategoryController.selectedApk.value = apk;
  }

  @override
  void dispose() {
    super.dispose();
    problem.dispose();
    pekerjaan.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String statusValue = statusMap[status] ?? '-';

    final username = storage.read('username');
    final fotoProfile = storage.read('foto_user');
    final divisi = storage.read('divisi');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
        title: Text(
          'Edit laporan',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              final now = DateTime.now();
              final String formattedDate =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

              laporanPekerjaanController.updatePekerjaan(
                hashId: laporanPekerjaanController.generateHash(id),
                apk: apkCategoryController.selectedApk.value,
                pekerjaan: pekerjaan.text,
                problem: problem.text,
                tgl: formattedDate,
                status: statusValue,
              );

              print(
                  'ini hashId : ${laporanPekerjaanController.generateHash(id)}');
              print(
                  'ini apk yg akan di kirim : ${apkCategoryController.selectedApk.value}');
              print('ini pekerjaan : ${pekerjaan.text}');
              print('ini problem : ${problem.text}');
              print('ini tgl : $formattedDate');
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
      body: Container(
        width: Get.width,
        margin: const EdgeInsets.only(top: 10.0),
        color: Colors.white,
        child: ListView(
          children: [
            const SizedBox(height: CustomSize.xs),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 4.0, bottom: 18.0),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: CachedNetworkImage(
                        imageUrl: fotoProfile,
                        progressIndicatorBuilder: (_, __, downloadProgress) =>
                            LoadingImg(
                                valueProggress: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$username - $divisi',
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: problem,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 10,
                minLines: 1,
                decoration: const InputDecoration(
                  label: Text('Apa ada problem?'),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    problem.text = value;
                  });
                },
              ),
            ),
            const SizedBox(height: CustomSize.spaceBtwItems),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: pekerjaan,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 10,
                minLines: 1,
                decoration: const InputDecoration(
                  label: Text('Apa ada pekerjaan?'),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    pekerjaan.text = value;
                  });
                },
              ),
            ),
            const SizedBox(height: CustomSize.spaceBtwItems),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() {
                return DropdownSearch<ApkCategoriesModel>(
                  items: apkCategoryController.filteredKendaraanModel,
                  itemAsString: (ApkCategoriesModel apk) => apk.title,
                  selectedItem: apkCategoryController.filteredKendaraanModel
                      .firstWhereOrNull((apk) =>
                          apk.title == apkCategoryController.selectedApk.value),
                  dropdownBuilder: (context, ApkCategoriesModel? selectedItem) {
                    return Text(
                      selectedItem != null
                          ? selectedItem.title
                          : 'Pilih No Polisi',
                      style: TextStyle(
                        color:
                            selectedItem == null ? Colors.grey : Colors.black,
                      ),
                    );
                  },
                  onChanged: (ApkCategoriesModel? kendaraan) {
                    if (kendaraan != null) {
                      apkCategoryController.selectedApk.value = kendaraan.title;
                      apkCategoryController.selectedKendaraanId.value =
                          kendaraan.title;
                    } else {
                      apkCategoryController.resetSelectedKendaraan();
                    }
                  },
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search Kendaraan...',
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: CustomSize.spaceBtwItems),
            // Add more widgets here based on your form structure
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropDownWidget(
                value: status,
                items: statusMap.keys.toList(),
                onChanged: (String? value) {
                  setState(() {
                    status = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
