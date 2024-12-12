import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/expandable_text.dart';
import 'package:laporan/utils/widgets/image%20widget/image_grid.dart';

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({
    super.key,
    required this.onTapAccept,
    required this.onTapDenied,
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

  final void Function()? onTapAccept;
  final void Function()? onTapDenied;
  final String nama;
  final String fotoProfile;
  final String divisi;
  final String apk;
  final String tglDiproses;
  final String deskripsi;
  final String priority;
  final String statusKerja;
  final List<String> fotoUser;
  final Color? bgTransitionColor;

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer>
    with SingleTickerProviderStateMixin {
  final storage = GetStorage();
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
    final typeUser = storage.read('type_user');
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  CustomSize.md, CustomSize.sm, CustomSize.sm, CustomSize.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: CachedNetworkImage(
                        imageUrl: widget.fotoProfile,
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
                      priorityNameFromValue(
                          widget.priority), // Ubah nilai prioritas menjadi nama
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
                ],
              ),
            ),
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
                  child: ImageGridWidget(
                      imageUrls: widget
                          .fotoUser), //'https://i.pinimg.com/736x/c2/d0/61/c2d0613295adec2fe01b1a29ee4930df.jpg'
                ),
                if (typeUser == 'admin' && widget.statusKerja != '2')
                  Padding(
                    padding: const EdgeInsets.all(CustomSize.xs),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                onPressed: widget.onTapDenied,
                                // onPressed: () => print(
                                //     'INI BTN BATAL ADMIN KETIKA NOLAK POSTINGAN USER'),
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
                                onPressed: widget.onTapAccept,
                                // onPressed: () => _controller.changeStatusBug(
                                //     hashId: widget.id,
                                //     statusKerja:
                                //         _getNextStatus(widget.statusKerja)),
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
