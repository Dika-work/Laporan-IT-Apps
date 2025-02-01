import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/loadings/loading_img.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/expandable_text.dart';
import 'package:laporan/utils/widgets/image%20widget/image_grid.dart';
import 'package:popover/popover.dart';

class PresenceTile extends StatefulWidget {
  final String nama;
  final String fotoProfile;
  final String divisi;
  final String apk;
  final String tglDiproses;
  final String deskripsi;
  final String priority;
  final String statusKerja;
  final List<String> laporanFoto;
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
  State<PresenceTile> createState() => _PresenceTileState();
}

class _PresenceTileState extends State<PresenceTile> {
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
                CustomSize.md, CustomSize.sm, CustomSize.sm, CustomSize.xs),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: CachedNetworkImage(
                      imageUrl: widget.fotoProfile,
                      progressIndicatorBuilder: (_, __, downloadProgress) =>
                          LoadingImg(valueProggress: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(width: CustomSize.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.nama} - ${widget.divisi}',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.tglDiproses))} - ${DateFormat('HH:mm').format(DateTime.parse(widget.tglDiproses))}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      widget.apk,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                Expanded(child: Container()),
                if (widget.statusKerja != '2')
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: CustomSize.xs, horizontal: CustomSize.sm),
                    decoration: BoxDecoration(
                      color: priorityColorFromValue(widget.priority),
                      borderRadius:
                          BorderRadius.circular(CustomSize.borderRadiusMd),
                    ),
                    child: Text(
                      priorityNameFromValue(
                          widget.priority), // Ubah nilai prioritas menjadi nama
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.apply(color: AppColors.textPrimary),
                    ),
                  ),
                if (widget.statusKerja != '2')
                  const SizedBox(width: CustomSize.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: CustomSize.xs, horizontal: CustomSize.sm),
                  decoration: BoxDecoration(
                    color: statusKerjaColorFromValue(widget.statusKerja),
                    borderRadius:
                        BorderRadius.circular(CustomSize.borderRadiusMd),
                  ),
                  child: Text(
                    statusKerjaFromValue(widget.statusKerja),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.apply(color: AppColors.textPrimary),
                  ),
                ),
                if (widget.statusKerja == '0')
                  const SizedBox(width: CustomSize.sm),
                if (widget.statusKerja == '0')
                  Button(
                    editEvent: widget.eventEdit!,
                    deleteEvent: widget.deleteEvent!,
                  ),
              ],
            ),
          ),
          Padding(
              padding:
                  const EdgeInsets.fromLTRB(CustomSize.md, 0, CustomSize.md, 0),
              child: ExpandableTextWidget(
                text: widget.deskripsi,
              )),
          Padding(
            padding: const EdgeInsets.only(top: CustomSize.sm),
            child: ImageGridWidget(
              imageUrls: widget.laporanFoto,
              username: widget.nama,
            ),
          ),
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({super.key, required this.editEvent, required this.deleteEvent});

  final Function editEvent;
  final Function deleteEvent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const Icon(
        Icons.more_horiz,
        color: AppColors.secondarySoft,
      ),
      onTap: () {
        showPopover(
          context: context,
          bodyBuilder: (context) => ListItems(
            editEvent: () {
              if (context.mounted) {
                Navigator.of(context).pop();
                editEvent();
              }
            },
            deleteEvent: () {
              if (context.mounted) {
                Navigator.of(context).pop();
                deleteEvent();
              }
            },
          ),
          direction: PopoverDirection.bottom,
          backgroundColor: AppColors.darkGrey,
          width: 200,
          height: 150,
          arrowHeight: 10,
          arrowWidth: 10,
        );
      },
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems(
      {super.key, required this.editEvent, required this.deleteEvent});

  final Function()? editEvent;
  final Function()? deleteEvent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          GestureDetector(
            onTap: editEvent,
            child: Container(
              height: 50,
              color: AppColors.white,
              child: const Center(child: Text('Edit postingan')),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: deleteEvent,
            child: Container(
              height: 50,
              color: AppColors.white,
              child: const Center(child: Text('Hapus postingan')),
            ),
          ),
        ],
      ),
    );
  }
}
