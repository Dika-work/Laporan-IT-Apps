import 'package:flutter/material.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/presence_tile.dart';

class AllProblem extends StatefulWidget {
  final int initialCategory;

  const AllProblem(
      {super.key, this.initialCategory = 1}); // Default ke Problem Baru

  @override
  State<AllProblem> createState() => _AllProblemState();
}

class _AllProblemState extends State<AllProblem> {
  late ValueNotifier<int> _selectedCategory;

  final List<Map<String, dynamic>> _problems = [
    {'id': 1, 'category': 1, 'title': 'Problem 1 Baru'},
    {'id': 1, 'category': 1, 'title': 'Problem 1 Baru'},
    {'id': 1, 'category': 1, 'title': 'Problem 1 Baru'},
    {'id': 2, 'category': 2, 'title': 'Problem 2 Proses'},
    {'id': 3, 'category': 3, 'title': 'Problem 3 Selesai'},
    {'id': 3, 'category': 3, 'title': 'Problem 3 Selesai'},
  ];

  @override
  void initState() {
    super.initState();
    // Gunakan initialCategory untuk menentukan kategori awal
    _selectedCategory = ValueNotifier<int>(widget.initialCategory);
  }

  @override
  void dispose() {
    _selectedCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Filter Kategori
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              margin: const EdgeInsets.fromLTRB(
                  CustomSize.md, 0, CustomSize.md, CustomSize.md),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedCategory,
                builder: (context, selectedCategory, _) {
                  return Row(
                    children: [
                      _buildCategoryOption(
                        context,
                        index: 1,
                        label: "Problem\nBaru",
                        count:
                            _problems.where((e) => e['category'] == 1).length,
                        isSelected: selectedCategory == 1,
                      ),
                      Container(
                        width: 1.5,
                        height: 24,
                        color: Colors.white,
                      ),
                      _buildCategoryOption(
                        context,
                        index: 2,
                        label: "Problem\nProses",
                        count:
                            _problems.where((e) => e['category'] == 2).length,
                        isSelected: selectedCategory == 2,
                      ),
                      Container(
                        width: 1.5,
                        height: 24,
                        color: Colors.white,
                      ),
                      _buildCategoryOption(
                        context,
                        index: 3,
                        label: "Problem\nSelesai",
                        count:
                            _problems.where((e) => e['category'] == 3).length,
                        isSelected: selectedCategory == 3,
                      ),
                    ],
                  );
                },
              ),
            ),

            // List Problem
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedCategory,
                builder: (context, selectedCategory, _) {
                  final filteredProblems = _problems
                      .where(
                          (problem) => problem['category'] == selectedCategory)
                      .toList();

                  if (filteredProblems.isEmpty) {
                    return const Center(
                      child: Text('Tidak Ada Permasalahan'),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: CustomSize.md),
                    itemCount: filteredProblems.length,
                    itemBuilder: (context, index) {
                      final problem = filteredProblems[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: CustomSize.spaceBtwItems),
                        child: PresenceTile(
                          nama: problem['title'],
                          divisi: 'Test',
                          deskripsi: 'asf',
                          tglDiproses: '2024-11-30',
                          priority: '4',
                          statusKerja: '2',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(BuildContext context,
      {required int index,
      required String label,
      required int count,
      required bool isSelected}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectedCategory.value = index,
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.apply(color: isSelected ? Colors.yellow : Colors.white),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.yellow : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
