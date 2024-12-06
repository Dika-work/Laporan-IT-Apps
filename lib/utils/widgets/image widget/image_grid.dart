import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:laporan/utils/widgets/image%20widget/full_image.dart';

class ImageGridWidget extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGridWidget({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    int maxImages = 5; // Maksimal 5 gambar di grid

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Jumlah kolom
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length > maxImages ? maxImages : imageUrls.length,
      itemBuilder: (context, index) {
        if (index == maxImages - 1 && imageUrls.length > maxImages) {
          // Tampilkan tombol "+n"
          return GestureDetector(
            onTap: () {
              // Navigasi ke FullImageGallery
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        "+${imageUrls.length - maxImages}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Tampilkan gambar biasa
        return GestureDetector(
          onTap: () {
            // Navigasi ke FullImageGallery saat gambar ditekan
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
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
