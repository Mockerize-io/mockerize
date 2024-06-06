import 'dart:math';

import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart';

class LogsHeatmap extends StatefulWidget {
  final List<Color> colorPalette;

  const LogsHeatmap({
    super.key,
    required this.colorPalette,
  });

  @override
  State<LogsHeatmap> createState() => _LogsHeatmapState();
}

class _LogsHeatmapState extends State<LogsHeatmap> {
  HeatmapItem? selectedItem;

  // late HeatmapData heatmapDataPower;

  // @override
  // void initState() {
  //   _initExampleData();
  //   super.initState();
  // }

  // void _initExampleData() {
  //   const rows = [
  //     '2022',
  //     '2021',
  //     '2020',
  //     '2019',
  //     '2018',
  //     '2017',
  //     '2016',
  //     '2015',
  //   ];
  //   const columns = [
  //     'Jan',
  //     'Feb',
  //     'Mär',
  //     'Apr',
  //     'Mai',
  //     'Jun',
  //     'Jul',
  //     'Aug',
  //     'Sep',
  //     'Okt',
  //     'Nov',
  //     'Dez',
  //   ];
  //   final r = Random();
  //   const String unit = 'hits';

  //   final items = [
  //     for (int row = 0; row < rows.length; row++)
  //       for (int col = 0; col < columns.length; col++)
  //         if (!(row == 3 &&
  //             col <
  //                 2)) // Do not add the very first item (incomplete data edge case)
  //           HeatmapItem(
  //             value: r.nextDouble() * 6,
  //             // style: row == 0 && col > 1
  //             //     ? HeatmapItemStyle.hatched
  //             //     : HeatmapItemStyle.filled,
  //             style: HeatmapItemStyle.filled,
  //             unit: unit,
  //             xAxisLabel: columns[col],
  //             yAxisLabel: rows[row],
  //           ),
  //   ];

  //   heatmapDataPower = HeatmapData(
  //     rows: rows,
  //     columns: columns,
  //     radius: 6.0,
  //     items: items,
  //     colorPalette: widget.colorPalette,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    HeatmapData hmData() {
      const rows = [
        '2022',
        '2021',
        '2020',
        '2019',
        '2018',
        '2017',
        '2016',
        '2015',
      ];
      const columns = [
        'Jan',
        'Feb',
        'Mär',
        'Apr',
        'Mai',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Okt',
        'Nov',
        'Dez',
      ];
      final r = Random();
      const String unit = 'hits';

      final items = [
        for (int row = 0; row < rows.length; row++)
          for (int col = 0; col < columns.length; col++)
            if (!(row == 3 &&
                col <
                    2)) // Do not add the very first item (incomplete data edge case)
              HeatmapItem(
                value: r.nextDouble() * 6,
                // style: row == 0 && col > 1
                //     ? HeatmapItemStyle.hatched
                //     : HeatmapItemStyle.filled,
                style: HeatmapItemStyle.filled,
                unit: unit,
                xAxisLabel: columns[col],
                yAxisLabel: rows[row],
              ),
      ];

      return HeatmapData(
        rows: rows,
        columns: columns,
        radius: 6.0,
        items: items,
        colorPalette: widget.colorPalette,
      );
    }

    return Heatmap(
      showXAxisLabels: false,
      showYAxisLabels: false,
      onItemSelectedListener: (HeatmapItem? selectedItem) {
        debugPrint(
            'Item ${selectedItem?.yAxisLabel}/${selectedItem?.xAxisLabel} with value ${selectedItem?.value} selected');
        setState(() {
          this.selectedItem = selectedItem;
        });
      },
      showAll: const SizedBox(),
      rowsVisible: 3,
      // heatmapData: heatmapDataPower,
      heatmapData: hmData(),
    );
  }
}
