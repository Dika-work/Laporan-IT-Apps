import 'package:flutter/material.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/expandable_text.dart';

class PresenceTile extends StatelessWidget {
  final String nama;
  final String divisi;
  const PresenceTile({super.key, required this.nama, required this.divisi});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: AppColors.white),
        padding: const EdgeInsets.fromLTRB(
            CustomSize.md, CustomSize.sm, CustomSize.md, CustomSize.sm),
        margin: const EdgeInsets.only(bottom: CustomSize.sm),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Image.network(
                      'https://static.vecteezy.com/system/resources/thumbnails/019/900/322/small/happy-young-cute-illustration-face-profile-png.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: CustomSize.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$nama - $divisi',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '12 Aug 2024',
                      style: Theme.of(context).textTheme.labelMedium,
                    )
                  ],
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () {},
                  child: const Icon(
                    Icons.more_horiz,
                    color: AppColors.secondarySoft,
                  ),
                )
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: CustomSize.xs),
                child: ExpandableTextWidget(
                  text:
                      'Lorem ipsum odor amet, consectetuer adipiscing elit. Ipsum primis varius hac erat ullamcorper; conubia nisl taciti dignissim. Tincidunt sapien ante ornare sit sodales vestibulum eget dolor. Praesent ornare laoreet sem pretium, augue nunc eget curae consequat. Massa placerat ornare felis sapien suspendisse justo nec semper. Tellus curae consequat elit vestibulum tincidunt; inceptos nec volutpat. Ante purus condimentum netus commodo est euismod! Porta egestas metus; phasellus leo congue tincidunt. Nam dignissim ipsum venenatis hac tempor velit libero. Pellentesque dui consectetur vehicula vestibulum facilisi litora felis.',
                )),
            Padding(
              padding: const EdgeInsets.only(top: CustomSize.xs),
              child: Image.network(
                  'https://i.pinimg.com/736x/c2/d0/61/c2d0613295adec2fe01b1a29ee4930df.jpg'),
            )
          ],
        ),
      ),
    );
  }
}
