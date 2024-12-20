import 'package:flutter/material.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';

class LoadingImg extends StatelessWidget {
  const LoadingImg({super.key, this.valueProggress});

  final double? valueProggress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(CustomSize.sm),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CircularProgressIndicator(
            value: valueProggress,
            color: AppColors.white,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
