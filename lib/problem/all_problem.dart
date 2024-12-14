import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/widgets/expandable_container.dart';

import '../home_admin/controller/home_admin_controller.dart';

class AllProblem extends StatefulWidget {
  final String initialCategory;

  const AllProblem({super.key, this.initialCategory = '0'});

  @override
  State<AllProblem> createState() => _AllProblemState();
}

class _AllProblemState extends State<AllProblem> {
  late ValueNotifier<String> _selectedCategory;
  final HomeAdminController _controller = Get.put(HomeAdminController());

  @override
  void initState() {
    super.initState();
    _selectedCategory = ValueNotifier<String>(widget.initialCategory);
  }

  @override
  void dispose() {
    _selectedCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Filter Kategori
            _buildCategoryFilter(context),
            // List Problem
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _selectedCategory,
                builder: (context, selectedCategory, _) {
                  // Ambil filtered problems berdasarkan kategori yang dipilih
                  final filteredProblems = _controller.problemList
                      .where(
                          (problem) => problem.statusKerja == selectedCategory)
                      .toList();

                  if (filteredProblems.isEmpty) {
                    return Expanded(
                      child: Image.asset('assets/images/lps.png',
                          width: 50, height: 50),
                    );
                  }

                  // Gunakan ListView.builder untuk menampilkan masalah
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: CustomSize.sm),
                    itemCount: filteredProblems.length +
                        (_controller.isLoadingMore.value
                            ? 1
                            : 0), // Tambahkan item loading spinner
                    itemBuilder: (context, index) {
                      if (index == filteredProblems.length) {
                        // Menampilkan indikator loading saat memuat data tambahan
                        return const Center(child: CircularProgressIndicator());
                      }

                      final problem = filteredProblems[index];
                      final now = DateTime.now();
                      final String formattedDate =
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: CustomSize.sm),
                        child: ExpandableContainer(
                          nama: problem.username,
                          fotoProfile: problem.fotoProfile,
                          divisi: problem.divisi,
                          apk: problem.apk,
                          deskripsi: problem.lampiran,
                          tglDiproses: problem.tglDiproses,
                          priority: problem.priority,
                          statusKerja: problem.statusKerja,
                          fotoUser: problem.fotoUser,
                          bgTransitionColor: AppColors.white,
                          onTapAccept: () => _controller.changeStatusBug(
                              hashId: _controller.generateHash(problem.id),
                              tglAcc: formattedDate,
                              statusKerja: _getNextStatus(problem.statusKerja)),
                          onTapDenied: () => _controller.changeStatusBug(
                              hashId: _controller.generateHash(problem.id),
                              tglAcc: formattedDate,
                              statusKerja: _getPrepStatus(problem.statusKerja)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  // Fungsi untuk mendapatkan status berikutnya (terima -> proses -> selesai)
  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case '0':
        return '1'; // Dari Problem Baru -> ke Problem Proses
      case '1':
        return '2'; // Dari Problem Proses -> ke Problem Selesai
      default:
        return currentStatus; // Tidak ada perubahan
    }
  }

  // Fungsi untuk menolak status menjadi 0
  String _getPrepStatus(String currentStatus) {
    switch (currentStatus) {
      case '0':
        return '2'; // Dari Problem Baru -> ke Problem Proses
      case '1':
        return '2'; // Dari Problem Proses -> ke Problem Selesai
      default:
        return currentStatus; // Tidak ada perubahan
    }
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(
            width: 1,
            color: AppColors.secondarySoft,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(CustomSize.borderRadiusLg),
          bottomRight: Radius.circular(CustomSize.borderRadiusLg),
        ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: ValueListenableBuilder<String>(
          valueListenable: _selectedCategory,
          builder: (context, selectedCategory, _) {
            return Row(
              children: [
                _buildCategoryOption(
                  context,
                  category: '0',
                  label: "Problem\nBaru",
                  count: _controller.problemList
                      .where((e) => e.statusKerja == '0')
                      .length,
                  isSelected: selectedCategory == '0',
                ),
                Container(
                  width: 1.5,
                  height: 24,
                  color: Colors.white,
                ),
                _buildCategoryOption(
                  context,
                  category: '1',
                  label: "Problem\nProses",
                  count: _controller.problemList
                      .where((e) => e.statusKerja == '1')
                      .length,
                  isSelected: selectedCategory == '1',
                ),
                Container(
                  width: 1.5,
                  height: 24,
                  color: Colors.white,
                ),
                _buildCategoryOption(
                  context,
                  category: '2',
                  label: "Problem\nSelesai",
                  count: _controller.problemList
                      .where((e) => e.statusKerja == '2')
                      .length,
                  isSelected: selectedCategory == '2',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryOption(BuildContext context,
      {required String category,
      required String label,
      required int count,
      required bool isSelected}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectedCategory.value = category,
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.apply(
                  color:
                      isSelected ? AppColors.textPrimary : AppColors.darkGrey),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.textPrimary : AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
