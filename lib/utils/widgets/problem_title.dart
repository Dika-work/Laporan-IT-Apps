import 'package:flutter/material.dart';

class ProblemCategory extends StatefulWidget {
  const ProblemCategory({super.key});

  @override
  State<ProblemCategory> createState() => _ProblemCategoryState();
}

class _ProblemCategoryState extends State<ProblemCategory> {
  List<String> tileProblem = ['Bukti Kas', 'Gudang', 'Spk', 'MTC', 'Absensi'];

  int? selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8,
          children: List.generate(
            tileProblem.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index; // Menyimpan indeks yang dipilih
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                decoration: BoxDecoration(
                  color:
                      selectedIndex == index ? Colors.transparent : Colors.blue,
                  border: Border.all(
                    color: selectedIndex == index
                        ? Colors.green
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tileProblem[index],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.apply(
                        color: selectedIndex == index
                            ? Colors.green
                            : Colors.grey)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
