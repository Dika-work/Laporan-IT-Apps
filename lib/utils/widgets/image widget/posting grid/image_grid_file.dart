import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../constant/custom_size.dart';
import 'full_image_posting.dart';

class ImageGridFileWidget extends StatefulWidget {
  final List<File> imageFiles;

  const ImageGridFileWidget({
    super.key,
    required this.imageFiles,
  });

  @override
  State<ImageGridFileWidget> createState() => _ImageGridFileWidgetState();
}

class _ImageGridFileWidgetState extends State<ImageGridFileWidget> {
  @override
  Widget build(BuildContext context) {
    final hasMoreImages = widget.imageFiles.length > 6;
    final remainingCount = widget.imageFiles.length - 6;
    final displayedImages = hasMoreImages
        ? widget.imageFiles.sublist(0, 6)
        : widget.imageFiles; // Maksimal 6 gambar yang ditampilkan

    return widget.imageFiles.isEmpty
        ? const SizedBox.shrink()
        : Stack(
            children: [
              // Jika hanya ada satu gambar
              if (widget.imageFiles.length == 1)
                Stack(
                  children: [
                    Image.file(widget.imageFiles[0], fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => _deleteImage(0), // Hapus gambar
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                // Jika ada lebih dari satu gambar
                GridView.custom(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4, // Total kolom
                    mainAxisSpacing: 4, // Spasi antar baris
                    crossAxisSpacing: 4, // Spasi antar kolom
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: _buildPattern(widget.imageFiles.length),
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Jika lebih dari 6 gambar, tambahkan overlay "+sisa"
                      if (hasMoreImages && index == 5) {
                        return Stack(
                          children: [
                            Positioned.fill(
                                child: Image.file(widget.imageFiles[index],
                                    fit: BoxFit.cover)),
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => FullImagePosting(
                                        images: widget.imageFiles,
                                        onDeleteImage: (delIndex) {
                                          _deleteImage(delIndex);
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
                                              color: Colors.white,
                                              fontSize: 24),
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
                          Get.to(() => FullImagePosting(
                                images: widget.imageFiles,
                                onDeleteImage: (delIndex) {
                                  _deleteImage(delIndex);
                                },
                              ));
                        },
                        child: Image.file(widget.imageFiles[index],
                            fit: BoxFit.cover),
                      );
                    },
                    childCount:
                        displayedImages.length, // Tampilkan maksimal 6 gambar
                  ),
                ),

              if (widget.imageFiles.length > 1)
                Positioned(
                  top: 10,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => FullImagePosting(
                                images: widget.imageFiles,
                                onDeleteImage: (index) {
                                  _deleteImage(index);
                                },
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  CustomSize.borderRadiusMd)),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 18,
                              ),
                              Text(
                                'Edit (${widget.imageFiles.length})',
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
                          Get.to(() => FullImagePosting(
                                images: widget.imageFiles,
                                onDeleteImage: (index) {
                                  _deleteImage(index);
                                },
                              ));
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(.8),
                            child: const Icon(Iconsax.maximize,
                                color: Colors.black)),
                      )
                    ],
                  ),
                ),
            ],
          );
  }

  List<QuiltedGridTile> _buildPattern(int imageCount) {
    // Pola grid dinamis berdasarkan jumlah gambar
    if (imageCount == 2) {
      return const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(2, 2),
      ];
    } else if (imageCount == 3) {
      return const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(2, 2),
        QuiltedGridTile(4, 4),
      ];
    } else if (imageCount == 4) {
      return const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(2, 2),
        QuiltedGridTile(2, 2),
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

  _deleteImage(int index) {
    setState(() {
      if (index >= 0 && index < widget.imageFiles.length) {
        widget.imageFiles.removeAt(index); // Hapus hanya jika indeks valid
      }
    });
  }
}
