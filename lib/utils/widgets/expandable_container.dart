import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/expandable_text.dart';

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({
    super.key,
    this.onTap,
    required this.nama,
    required this.fotoProfile,
    required this.divisi,
    required this.apk,
    required this.deskripsi,
    required this.tglDiproses,
    required this.priority,
    required this.statusKerja,
    required this.fotoUser,
    this.bgTransitionColor,
  });

  final void Function()? onTap;
  final String nama;
  final String fotoProfile;
  final String divisi;
  final String apk;
  final String tglDiproses;
  final String deskripsi;
  final String priority;
  final String statusKerja;
  final String fotoUser;
  final Color? bgTransitionColor;

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> animation;
  bool _isExpanded = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

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

    return Column(
      children: [
        GestureDetector(
          onTap: toggleExpansion,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(color: AppColors.white),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(CustomSize.md,
                      CustomSize.sm, CustomSize.md, CustomSize.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Image.network(
                            widget
                                .fotoProfile, //https://static.vecteezy.com/system/resources/thumbnails/019/900/322/small/happy-young-cute-illustration-face-profile-png.png
                            fit: BoxFit.cover,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: CustomSize.xs, horizontal: CustomSize.sm),
                        decoration: BoxDecoration(
                          color: priorityColorFromValue(widget.priority),
                          borderRadius:
                              BorderRadius.circular(CustomSize.borderRadiusMd),
                        ),
                        child: Text(
                          priorityNameFromValue(widget
                              .priority), // Ubah nilai prioritas menjadi nama
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
                      const SizedBox(width: CustomSize.sm),
                      InfoPopupWidget(
                        customContent: () => Container(
                          margin: const EdgeInsets.only(right: CustomSize.sm),
                          decoration: BoxDecoration(
                              color: AppColors.primaryExtraSoft,
                              borderRadius: BorderRadius.circular(
                                  CustomSize.borderRadiusMd),
                              border: Border.all(
                                  color: AppColors.secondarySoft, width: 1)),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(
                            maxWidth: 200, // Batasi lebar maksimum popup
                          ),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min, // Ukuran menyesuaikan konten
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Rata kiri
                            children: <Widget>[
                              Row(
                                children: [
                                  const Icon(Icons.edit,
                                      color: AppColors.black),
                                  const SizedBox(
                                      width: 8), // Jarak antar ikon dan teks
                                  Expanded(
                                    child: Text(
                                      'Edit postingan',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow
                                          .ellipsis, // Potong teks jika terlalu panjang
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: CustomSize.sm), // Jarak antar item
                              Row(
                                children: [
                                  const Icon(Icons.delete_forever,
                                      color: AppColors.black),
                                  const SizedBox(
                                      width: 8), // Jarak antar ikon dan teks
                                  Expanded(
                                    child: Text(
                                      'Hapus postingan',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow
                                          .ellipsis, // Potong teks jika terlalu panjang
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        arrowTheme: const InfoPopupArrowTheme(
                          color: AppColors.secondarySoft,
                          arrowDirection: ArrowDirection.up,
                        ),
                        dismissTriggerBehavior:
                            PopupDismissTriggerBehavior.onTapArea,
                        areaBackgroundColor:
                            AppColors.secondarySoft.withOpacity(.1),
                        indicatorOffset: Offset.zero,
                        contentOffset: Offset.zero,
                        child: const Icon(
                          Icons.more_horiz,
                          color: AppColors.secondarySoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // child: ListTile(
            //   onTap: widget.onTap ?? toggleExpansion,
            //   title: widget.headContent,
            //   trailing: widget.content == null
            //       ? null
            //       : Icon(
            //           _isExpanded ? Icons.expand_less : Icons.expand_more,
            //           color: AppColors.black,
            //         ),
            // ),
          ),
        ),
        SizeTransition(
          sizeFactor: animation,
          child: Container(
            color: widget.bgTransitionColor,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(
                        CustomSize.md, 0, CustomSize.md, 0),
                    child: ExpandableTextWidget(
                      text: widget.deskripsi,
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: CustomSize.xs),
                  child: Image.network(widget
                      .fotoUser), //'https://i.pinimg.com/736x/c2/d0/61/c2d0613295adec2fe01b1a29ee4930df.jpg'
                ),
                Padding(
                  padding: const EdgeInsets.all(CustomSize.xs),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              onPressed: () => print(
                                  'INI BTN BATAL ADMIN KETIKA NOLAK POSTINGAN USER'),
                              child: Text(
                                'Denied',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                              ))),
                      const SizedBox(width: CustomSize.sm),
                      Expanded(
                          flex: 1,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              onPressed: () => print(
                                  'INI BTN TERIMA ADMIN KETIKA TERIMA POSTINGAN USER'),
                              child: Text(
                                'Accept',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                              ))),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
