import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:laporan/utils/loadings/loading_img.dart';
import 'package:laporan/utils/widgets/image%20widget/full_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ImageGridWidget extends StatelessWidget {
  final List<String> imageUrls;
  final String username;

  const ImageGridWidget({
    super.key,
    required this.imageUrls,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrls.isEmpty
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
              pattern: _buildPattern(imageUrls.length),
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                // Menampilkan tombol "+sisanya" hanya jika ada lebih dari 4 gambar
                if (index == 3 && imageUrls.length > 4) {
                  return GestureDetector(
                    onTap: () {
                      // Navigasi ke galeri penuh
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageGallery(
                            imageUrls: imageUrls,
                            initialIndex: index,
                            username: username,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            progressIndicatorBuilder:
                                (_, __, downloadProgress) => LoadingImg(
                                    valueProggress: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Text(
                                "+${imageUrls.length - 4}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: Colors.white, fontSize: 24),
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
                        builder: (context) => FullImageGallery(
                          imageUrls: imageUrls,
                          initialIndex: index,
                          username: username,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[index],
                    progressIndicatorBuilder: (_, __, downloadProgress) =>
                        LoadingImg(valueProggress: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                );
              },
              // Batasi hanya 4 gambar yang ditampilkan
              childCount: imageUrls.length > 4 ? 4 : imageUrls.length,
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
      // Untuk lebih dari 4 gambar, tampilkan 4 gambar dengan "+sisanya" pada gambar ke-4
      return const [
        QuiltedGridTile(2, 2), // Gambar pertama
        QuiltedGridTile(2, 2), // Gambar kedua
        QuiltedGridTile(2, 2), // Gambar ketiga
        QuiltedGridTile(2, 2), // Gambar keempat (tombol "+sisanya" ada di sini)
      ];
    }
  }
}
