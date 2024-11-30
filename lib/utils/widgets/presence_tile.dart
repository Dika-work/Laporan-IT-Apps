import 'package:flutter/material.dart';
import 'package:laporan/utils/theme/app_colors.dart';

class PresenceTile extends StatelessWidget {
  final String title;
  const PresenceTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1,
            color: AppColors.secondarySoft,
          ),
        ),
        padding:
            const EdgeInsets.only(left: 24, top: 20, right: 29, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "1",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1.5,
                  height: 24,
                  color: AppColors.secondarySoft,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Aplikasi",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "SPK",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Text(
              "Tgl",
              style: TextStyle(
                fontSize: 10,
                color: AppColors.secondarySoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
