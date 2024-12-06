import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullImageGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Gallery', style: TextStyle(color: Colors.white)),
      ),
      body: PageView.builder(
        itemCount: imageUrls.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error, color: Colors.white)),
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
