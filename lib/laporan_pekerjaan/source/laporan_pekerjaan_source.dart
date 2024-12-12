import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:laporan/models/laporan_pekerjaan_model.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LaporanPekerjaanSource extends DataGridSource {
  final List<LaporanPekerjaanModel> model;
  final void Function(LaporanPekerjaanModel)? onEdited;
  final void Function(LaporanPekerjaanModel)? onDelete;
  int startIndex = 0;

  LaporanPekerjaanSource({
    required this.model,
    required this.onEdited,
    required this.onDelete,
    int startIndex = 0,
  }) {
    _updateDataPager(model, startIndex);
  }

  List<DataGridRow> data = [];
  int index = 0;

  @override
  List<DataGridRow> get rows => data;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    int rowIndex = data.indexOf(row);
    bool isEvenRow = rowIndex % 2 == 0;

    // Create cells for the first 6 columns
    List<Widget> cells = [
      ...row.getCells().take(6).map<Widget>((e) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: CustomSize.md),
          child: Text(
            e.value.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: CustomSize.fontSizeXm),
          ),
        );
      }),
    ];

    // Add "Edit" and "Delete" buttons if model is not empty
    if (model.isNotEmpty) {
      // Add Edit button
      cells.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                if (onEdited != null) {
                  onEdited!(model[rowIndex]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.all(8.0),
              ),
              child: const Icon(Iconsax.edit),
            ),
          ),
        ],
      ));

      // Add Delete button
      cells.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                if (onDelete != null) {
                  onDelete!(model[rowIndex]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.all(8.0),
              ),
              child: const Icon(Iconsax.trash),
            ),
          ),
        ],
      ));
    }

    return DataGridRowAdapter(
      color: isEvenRow ? Colors.white : Colors.grey[200],
      cells: cells,
    );
  }

  List<DataGridRow> _generateEmptyRows(int count) {
    return List.generate(
      count,
      (index) {
        return const DataGridRow(cells: [
          DataGridCell<String>(columnName: 'No', value: '-'),
          DataGridCell<String>(columnName: 'Tanggal', value: '-'),
          DataGridCell<String>(columnName: 'Apk', value: '-'),
          DataGridCell<String>(columnName: 'Pekerjaan', value: '-'),
          DataGridCell<String>(columnName: 'Problem', value: '-'),
          DataGridCell<String>(columnName: 'Status', value: '-'),
        ]);
      },
    );
  }

  void _updateDataPager(List<LaporanPekerjaanModel> model, int startIndex) {
    this.startIndex = startIndex;
    index = startIndex;

    if (model.isEmpty) {
      // Jika data kosong, tampilkan baris kosong dan hilangkan kolom Edit dan Hapus
      data = _generateEmptyRows(1);
    } else {
      data = model.skip(startIndex).map<DataGridRow>((data) {
        index++;
        final tglParsed =
            DateFormat('dd MMM yyyy').format(DateTime.parse(data.tgl));

        // Create row cells
        List<DataGridCell> cells = [
          DataGridCell<int>(columnName: 'No', value: index),
          DataGridCell<String>(columnName: 'Tanggal', value: tglParsed),
          DataGridCell<String>(columnName: 'Apk', value: data.apk),
          DataGridCell<String>(columnName: 'Pekerjaan', value: data.pekerjaan),
          DataGridCell<String>(columnName: 'Problem', value: data.problem),
          DataGridCell<String>(
              columnName: 'Status',
              value: data.status == '1' ? 'Selesai' : 'Belum\nSelesai'),
        ];

        return DataGridRow(cells: cells);
      }).toList();
    }

    notifyListeners();
  }
}
