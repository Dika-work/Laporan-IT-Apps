import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laporan/utils/widgets/image%20widget/full_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ImageGridFileWidget extends StatelessWidget {
  final List<File>
      imageFiles; // Menggunakan List<File> untuk mendukung gambar lokal (dari kamera)

  const ImageGridFileWidget({
    super.key,
    required this.imageFiles,
  });

  @override
  Widget build(BuildContext context) {
    return imageFiles.isEmpty
        ? const SizedBox.shrink()
        : GridView.custom(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 4, // Total kolom
              mainAxisSpacing: 4, // Spasi antar baris
              crossAxisSpacing: 4, // Spasi antar kolom
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: _buildPattern(imageFiles.length),
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 3 && imageFiles.length > 4) {
                  // Tombol "+sisanya" untuk gambar lebih dari 4
                  return GestureDetector(
                    onTap: () {
                      // Navigasi ke galeri penuh
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageFileGallery(
                            imageUrls: imageFiles,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Image.file(imageFiles[index],
                            fit: BoxFit.cover), // Menampilkan gambar lokal
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Text(
                                "+${imageFiles.length - 4}",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Tampilan gambar biasa
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullImageFileGallery(
                          imageUrls: imageFiles,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Image.file(imageFiles[index],
                      fit: BoxFit.cover), // Menampilkan gambar lokal
                );
              },
              childCount: imageFiles.length > 4 ? 4 : imageFiles.length,
            ),
          );
  }

  // Membuat pola grid dinamis berdasarkan jumlah gambar
  List<QuiltedGridTile> _buildPattern(int imageCount) {
    if (imageCount == 1) {
      return const [
        QuiltedGridTile(4, 4), // Satu gambar memenuhi seluruh grid
      ];
    } else if (imageCount == 2) {
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
    } else {
      return const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 2),
      ];
    }
  }
}
