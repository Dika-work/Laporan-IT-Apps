import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:laporan/utils/widgets/image%20widget/full_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ImageGridWidget extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGridWidget({
    super.key,
    required this.imageUrls,
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
                if (index == 3 && imageUrls.length > 4) {
                  // Tombol "+sisanya" untuk gambar lebih dari 4
                  return GestureDetector(
                    onTap: () {
                      // Navigasi ke galeri penuh
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageGallery(
                            imageUrls: imageUrls,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrls[index],
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Text(
                                "+${imageUrls.length - 4}",
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
                        builder: (context) => FullImageGallery(
                          imageUrls: imageUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[index],
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                );
              },
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
      return const [
        QuiltedGridTile(2, 2),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 1),
        QuiltedGridTile(1, 2),
      ];
    }
  }
}
