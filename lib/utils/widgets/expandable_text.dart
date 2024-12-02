import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan/utils/theme/app_colors.dart';

// ignore: must_be_immutable
class ExpandableTextWidget extends StatefulWidget {
  final String text;
  Color? color;

  ExpandableTextWidget({super.key, required this.text, this.color});

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  late String firstHalf;
  late String secondHalf;

  bool hiddenText = true;

  double textHeight = Get.height / 8.04;

  @override
  void initState() {
    super.initState();
    if (widget.text.length > textHeight) {
      firstHalf = widget.text.substring(0, textHeight.toInt());
      secondHalf =
          widget.text.substring(textHeight.toInt() + 1, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: secondHalf.isEmpty
            ? Text(
                firstHalf,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Epilogue',
                    color: widget.color,
                    fontWeight: FontWeight.normal),
              )
            : InkWell(
                onTap: () {
                  setState(() {
                    hiddenText = !hiddenText;
                  });
                },
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                      text: (hiddenText
                          ? ('$firstHalf...')
                          : (firstHalf + secondHalf)),
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: <TextSpan>[
                        TextSpan(
                            text: hiddenText ? 'Lihat selengkapnya..' : '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.apply(color: AppColors.secondarySoft),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  hiddenText = !hiddenText;
                                });
                              }),
                      ]),
                ),
              ));
  }
}
