import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';

class FullImagePosting extends StatefulWidget {
  final List<File> images;
  final void Function(int index) onDeleteImage;

  const FullImagePosting(
      {super.key, required this.images, required this.onDeleteImage});

  @override
  State<FullImagePosting> createState() => _FullImagePostingState();
}

class _FullImagePostingState extends State<FullImagePosting> {
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

          return Column(
            children: [
              Stack(
                children: [
                  // Gambar ditampilkan dengan penuh
                  Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                  // Tombol X untuk menghapus gambar
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.images.removeAt(index);
                        });
                        widget.onDeleteImage(index);
                      }, // Menghapus gambar
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
              // Jarak antar gambar, kecuali gambar terakhir
              if (index != widget.images.length - 1) const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
