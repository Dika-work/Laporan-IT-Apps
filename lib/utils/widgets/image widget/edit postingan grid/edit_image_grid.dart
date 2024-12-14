import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/widgets/image%20widget/edit%20postingan%20grid/full_image_edit.dart';

import '../../../../laporan_bug/controller/posting_bug_controller.dart';

class EditImageGridWidget extends StatelessWidget {
  final void Function(int index, bool isOldImage) onDeleteImage;

  const EditImageGridWidget({
    super.key,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<PostingBugController>();

      // Gabungkan gambar lama dan baru
      final combinedImages = [
        ...controller.oldImageUrls.map((url) => {'path': url, 'isOld': true}),
        ...controller.newImages
            .map((file) => {'path': file.path, 'isOld': false}),
      ];

      return _buildImageGrid(
        context,
        combinedImages,
        onDeleteImage: onDeleteImage,
      );
    });
  }

  Widget _buildImageGrid(
    BuildContext context,
    List<Map<String, dynamic>> combinedImages, {
    required void Function(int index, bool isOldImage) onDeleteImage,
  }) {
    final hasMoreImages = combinedImages.length > 6; // Jika gambar lebih dari 6
    final displayedImages = hasMoreImages
        ? combinedImages.sublist(0, 6)
        : combinedImages; // Maksimal 6 gambar yang ditampilkan
    final remainingCount = combinedImages.length - 6; // Sisa gambar

    return Stack(
      children: [
        // Jika hanya satu gambar
        if (combinedImages.length == 1)
          Stack(
            children: [
              // Pastikan Stack memiliki ukuran penuh
              combinedImages[0]['isOld']
                  ? CachedNetworkImage(
                      imageUrl: combinedImages[0]['path'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : Image.file(
                      File(combinedImages[0]['path']),
                      fit: BoxFit.cover,
                    ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => onDeleteImage(0, combinedImages[0]['isOld']),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ),
            ],
          )
        else
          // Jika lebih dari satu gambar
          GridView.custom(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: _buildPattern(combinedImages.length),
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                final image = displayedImages[index];
                final isOldImage = image['isOld'] as bool;
                final imagePath = image['path'] as String;

                // Jika index adalah gambar ke-6 dan ada lebih dari 6 gambar, tambahkan overlay "+sisa"
                if (hasMoreImages && index == 5) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: isOldImage
                            ? CachedNetworkImage(
                                imageUrl: imagePath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => FullImageEdit(
                                  images: combinedImages, // Semua gambar
                                  onDeleteImage: (index, isOldImage) {
                                    onDeleteImage(index, isOldImage);
                                  },
                                ));
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: Text(
                                '+$remainingCount',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Get.to(() => FullImageEdit(
                          images: combinedImages, // Semua gambar
                          onDeleteImage: (index, isOldImage) {
                            onDeleteImage(index, isOldImage);
                          },
                        ));

                    print(
                        'INI AKAN NAVIGATE KE PAGE BARU UNTUK MENAMPILKAN SELURUH GAMBAR2');
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: isOldImage
                            ? CachedNetworkImage(
                                imageUrl: imagePath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ],
                  ),
                );
              },
              childCount: displayedImages.length, // Tampilkan maksimal 6 elemen
            ),
          ),
        // Tombol Edit dan ikon lainnya jika gambar lebih dari satu
        if (combinedImages.length > 1)
          Positioned(
            top: 10,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => FullImageEdit(
                          images: combinedImages, // Semua gambar
                          onDeleteImage: (index, isOldImage) {
                            onDeleteImage(index, isOldImage);
                          },
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(CustomSize.borderRadiusMd)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit,
                          size: 18,
                        ),
                        Text(
                          'Edit (${combinedImages.length})',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Get.to(() => FullImageEdit(
                          images: combinedImages, // Semua gambar
                          onDeleteImage: (index, isOldImage) {
                            onDeleteImage(index, isOldImage);
                          },
                        ));
                  },
                  child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(.8),
                      child: const Icon(Iconsax.maximize, color: Colors.black)),
                )
              ],
            ),
          ),
      ],
    );
  }

// Pola untuk 6 elemen
  List<QuiltedGridTile> _buildPattern(int imageCount) {
    if (imageCount == 2) {
      return const [
        QuiltedGridTile(2, 2), // Dua gambar dibagi dua
        QuiltedGridTile(2, 2),
      ];
    } else if (imageCount == 3) {
      return const [
        QuiltedGridTile(2, 2), // Dua gambar di atas
        QuiltedGridTile(2, 2),
        QuiltedGridTile(4, 4), // Satu gambar besar di bawah
      ];
    } else if (imageCount == 4) {
      return const [
        QuiltedGridTile(2, 2), // Dua gambar di atas
        QuiltedGridTile(2, 2),
        QuiltedGridTile(2, 2), // Dua gambar di bawah
        QuiltedGridTile(2, 2),
      ];
    } else if (imageCount == 5) {
      return const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(2, 2),
        QuiltedGridTile(2, 2),
      ];
    } else {
      return const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(2, 2),
        QuiltedGridTile(2, 2),
        QuiltedGridTile(1, 2),
      ];
    }
  }
}
