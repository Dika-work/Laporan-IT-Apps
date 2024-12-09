import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan/models/laporan_pekerjaan_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/widgets/dropdown_widget.dart';

import '../controller/home_admin_controller.dart';

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

  final Map<String, String> statusPekerjaan = {
    'SELESAI': '1',
    'BELUM': '2',
  };

  @override
  void initState() {
    super.initState();
    id = widget.model.id;
    problem.text = widget.model.problem;
    pekerjaan.text = widget.model.pekerjaan;
    status = widget.model.status == '1' ? 'SELESAI' : 'BELUM';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeAdminController>();

    return AlertDialog(
      title: const Center(
        child: Text('Ubah laporan harian'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: problem,
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
                label: const Text('Problem'),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: CustomSize.spaceBtwInputFields),
            TextFormField(
              controller: pekerjaan,
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
                label: const Text('Pekerjaan'),
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: CustomSize.spaceBtwInputFields),
            DropDownWidget(
              value: status,
              items: statusPekerjaan.keys.toList(),
              onChanged: (String? value) {
                status = value!;
                print('ini status pekerjaan yg di pilih : $status');
              },
            ),
          ],
        ),
      ),
    );
  }
}
