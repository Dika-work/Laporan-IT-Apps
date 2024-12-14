import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';

class FullImageEdit extends StatefulWidget {
  final List<Map<String, dynamic>> images; // Semua gambar
  final void Function(int index, bool isOldImage) onDeleteImage;

  const FullImageEdit({
    super.key,
    required this.images,
    required this.onDeleteImage,
  });

  @override
  _FullImageEditState createState() => _FullImageEditState();
}

class _FullImageEditState extends State<FullImageEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Edit',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
            },
            child: Container(
              padding: const EdgeInsets.all(CustomSize.xs),
              margin: const EdgeInsets.fromLTRB(
                  0, CustomSize.sm, CustomSize.sm, CustomSize.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CustomSize.borderRadiusSm),
                color: AppColors.buttonPrimary,
              ),
              child: Text(
                'SIMPAN',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          final isOldImage = image['isOld'] as bool;
          final imagePath = image['path'] as String;

          return Column(
            children: [
              // Gambar ditampilkan penuh
              Stack(
                children: [
                  isOldImage
                      ? CachedNetworkImage(
                          imageUrl: imagePath,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, color: Colors.red),
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        ),
                  // Tombol X untuk menghapus gambar
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          // Hapus gambar dari daftar
                          widget.images.removeAt(index);
                        });
                        widget.onDeleteImage(index,
                            isOldImage); // Panggil callback untuk menghapus gambar
                      },
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 30),
                    ),
                  ),
                ],
              ),
              // Jarak antar gambar
              if (index != widget.images.length - 1)
                const SizedBox(height: 10), // Jarak antar gambar
            ],
          );
        },
      ),
    );
  }
}
