import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/expandable_text.dart';

class PresenceTile extends StatelessWidget {
  final String nama;
  final String fotoProfile;
  final String divisi;
  final String apk;
  final String tglDiproses;
  final String deskripsi;
  final String priority;
  final String statusKerja;
  final String laporanFoto;
  final void Function()? eventEdit;
  final void Function()? deleteEvent;
  const PresenceTile({
    super.key,
    required this.nama,
    required this.fotoProfile,
    required this.divisi,
    required this.apk,
    required this.deskripsi,
    required this.tglDiproses,
    required this.priority,
    required this.statusKerja,
    required this.laporanFoto,
    this.eventEdit,
    this.deleteEvent,
  });

  @override
  Widget build(BuildContext context) {
    String statusKerjaFromValue(String value) {
      Map<String, String> statusKerja = {
        'Baru': '0',
        'Proses': '1',
        'Selesai': '2'
      };

      return statusKerja.entries
          .firstWhere((e) => e.value == value,
              orElse: () => const MapEntry('Unknow', '-1'))
          .key;
    }

    Color statusKerjaColorFromValue(String value) {
      Map<String, Color> priorityColors = {
        '0': Colors.red,
        '1': Colors.yellow,
        '2': Colors.green,
      };

      return priorityColors[value] ?? Colors.grey;
    }

    String priorityNameFromValue(String value) {
      Map<String, String> priorityName = {
        'Ringan': '1',
        'Sedang': '2',
        'Berat': '3',
        'Urgent': '4',
      };

      // Cari key berdasarkan value
      return priorityName.entries
          .firstWhere((entry) => entry.value == value,
              orElse: () => const MapEntry('Unknown', '0'))
          .key;
    }

    Color priorityColorFromValue(String value) {
      Map<String, Color> priorityColors = {
        '1': Colors.yellow,
        '2': Colors.blue,
        '3': Colors.orange,
        '4': Colors.red,
      };

      return priorityColors[value] ?? Colors.grey;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: AppColors.white),
      margin: const EdgeInsets.only(bottom: CustomSize.sm),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                CustomSize.sm, CustomSize.sm, CustomSize.xs, CustomSize.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: CachedNetworkImage(
                      imageUrl: fotoProfile,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(width: CustomSize.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$nama - $divisi',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(DateTime.parse(tglDiproses))} - ${DateFormat('HH:mm').format(DateTime.parse(tglDiproses))}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      apk,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                Expanded(child: Container()),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: CustomSize.xs, horizontal: CustomSize.sm),
                  decoration: BoxDecoration(
                    color: priorityColorFromValue(priority),
                    borderRadius:
                        BorderRadius.circular(CustomSize.borderRadiusMd),
                  ),
                  child: Text(
                    priorityNameFromValue(
                        priority), // Ubah nilai prioritas menjadi nama
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.apply(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: CustomSize.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: CustomSize.xs, horizontal: CustomSize.sm),
                  decoration: BoxDecoration(
                    color: statusKerjaColorFromValue(statusKerja),
                    borderRadius:
                        BorderRadius.circular(CustomSize.borderRadiusMd),
                  ),
                  child: Text(
                    statusKerjaFromValue(statusKerja),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.apply(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: CustomSize.sm),
                InfoPopupWidget(
                  customContent: () => Container(
                    margin: const EdgeInsets.only(right: CustomSize.sm),
                    decoration: BoxDecoration(
                        color: AppColors.primaryExtraSoft,
                        borderRadius:
                            BorderRadius.circular(CustomSize.borderRadiusMd),
                        border: Border.all(
                            color: AppColors.secondarySoft, width: 1)),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(
                      maxWidth: 200, // Batasi lebar maksimum popup
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Ukuran menyesuaikan konten
                      crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            if (context.mounted) {
                              eventEdit?.call();
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: AppColors.black),
                              const SizedBox(
                                  width: 8), // Jarak antar ikon dan teks
                              Expanded(
                                child: Text(
                                  'Edit postingan',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow
                                      .ellipsis, // Potong teks jika terlalu panjang
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                            height: CustomSize.sm), // Jarak antar item
                        GestureDetector(
                          onTap: () {
                            if (context.mounted) {
                              deleteEvent?.call();
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.delete_forever,
                                  color: AppColors.black),
                              const SizedBox(
                                  width: 8), // Jarak antar ikon dan teks
                              Expanded(
                                child: Text(
                                  'Hapus postingan',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow
                                      .ellipsis, // Potong teks jika terlalu panjang
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  arrowTheme: const InfoPopupArrowTheme(
                    color: AppColors.secondarySoft,
                    arrowDirection: ArrowDirection.up,
                  ),
                  dismissTriggerBehavior: PopupDismissTriggerBehavior.onTapArea,
                  areaBackgroundColor: AppColors.secondarySoft.withOpacity(.1),
                  indicatorOffset: Offset.zero,
                  contentOffset: Offset.zero,
                  child: const Icon(
                    Icons.more_horiz,
                    color: AppColors.secondarySoft,
                  ),
                ),
                // GestureDetector(
                //   onTap: deleteEvent,
                //   child:
                //       const Icon(Icons.delete_forever, color: AppColors.black),
                // ),
              ],
            ),
          ),
          Padding(
              padding:
                  const EdgeInsets.fromLTRB(CustomSize.md, 0, CustomSize.md, 0),
              child: ExpandableTextWidget(
                text: deskripsi,
              )),
          Padding(
            padding: const EdgeInsets.only(top: CustomSize.xs),
            child: CachedNetworkImage(
              imageUrl: laporanFoto,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ), //https://i.pinimg.com/736x/c2/d0/61/c2d0613295adec2fe01b1a29ee4930df.jpg
          )
        ],
      ),
    );
  }
}
