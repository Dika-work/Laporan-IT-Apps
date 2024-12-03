import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';

class PriorityLevel extends StatelessWidget {
  const PriorityLevel({super.key});

  @override
  Widget build(BuildContext context) {
    RxInt priorityLevel = RxInt(1);
    final int? argumentPriority = Get.arguments as int?;
    if (argumentPriority != null) {
      priorityLevel.value = argumentPriority;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
        title: Text(
          'Priority postingan',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: CustomSize.sm, vertical: CustomSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apa maksud dari priority postingan Anda?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: CustomSize.sm),
            const Text(
                'Postingan Anda kemungkinan akan dikerjakan terlebih dahulu. Jenis-jenis postingan yang diprioritaskan adalah Urgent, Berat, Sedang, dan Ringan.'),
            const SizedBox(height: CustomSize.sm),
            RichText(
                text: TextSpan(
                    text: 'Postingan default Anda diatur sebagai ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.apply(color: AppColors.textPrimary),
                    children: [
                  TextSpan(
                      text: 'Ringan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ', tetapi Anda dapat mengubah prioritas untuk postingan spesifik ini.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.apply(color: AppColors.textPrimary))
                ])),
            const SizedBox(height: CustomSize.sm),
            Text(
              'Pilih priority',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            buildPriorityTile(
              value: 4,
              icon: Ionicons.warning,
              title: 'Urgent',
              subtitle: 'Sangat dibutuhkan secepatnya',
              priorityLevel: priorityLevel,
            ),
            buildPriorityTile(
              value: 3,
              icon: Iconsax.emoji_sad,
              title: 'Berat',
              subtitle: 'Memerlukan perhatian lebih',
              priorityLevel: priorityLevel,
            ),
            buildPriorityTile(
              value: 2,
              icon: Iconsax.like_shapes,
              title: 'Sedang',
              subtitle: 'Tidak terburu-buru dibutuhkan',
              priorityLevel: priorityLevel,
            ),
            buildPriorityTile(
              value: 1,
              icon: Iconsax.emoji_happy,
              title: 'Ringan',
              subtitle: 'Dapat dikerjakan kapanpun',
              priorityLevel: priorityLevel,
            ),
            const Spacer(),
            SizedBox(
              width: Get.width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: CustomSize.sm),
                  ),
                  onPressed: () {
                    print('Priority Selected: ${priorityLevel.value}');
                    Get.back(result: priorityLevel.value);
                  },
                  child: const Text('Selesai')),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPriorityTile({
    required int value,
    required IconData icon,
    required String title,
    required String subtitle,
    required RxInt priorityLevel,
  }) {
    return GestureDetector(
      onTap: () {
        priorityLevel.value = value;
        print('Priority level changed to: $value');
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.secondarySoft,
              width: 1.0,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => Radio(
                  value: value,
                  groupValue: priorityLevel.value,
                  onChanged: (newValue) {
                    priorityLevel.value = newValue!;
                  },
                ),
              ),
              Icon(icon, size: 24),
            ],
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}
