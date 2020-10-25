import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  final files = Directory(path.join(
    'data',
    'csse_covid_19_data',
    'csse_covid_19_daily_reports',
  )).listSync().where((file) => file.path.endsWith('.csv')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final intermediate = <DateTime, int>{};
  for (final file in files) {
    final data = const CsvToListConverter(
      eol: '\n',
    ).convert(File(file.path).readAsStringSync());
    for (final entry in data.where((entry) => entry[3] == 'Germany')) {
      DateTime dateTime;
      try {
        dateTime = DateTime.parse(entry[4] as String);
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        dateTime = DateFormat('MM/dd/yyyy HH:mm').parse(entry[4] as String);
      }
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final count = entry[7] as int;
      if (intermediate[dateTime] == null) {
        intermediate[dateTime] = 0;
      }
      intermediate[dateTime] += count;
    }
  }
  final output = <List<dynamic>>[
    ['date', 'daily cases'],
  ];
  for (final dateTime in intermediate.keys) {
    final previous = intermediate[dateTime.subtract(const Duration(days: 1))];
    if (previous != null) {
      output.add([
        dateTime,
        intermediate[dateTime] - previous,
      ]);
    }
  }
  File('dump.csv')
      .writeAsStringSync(const ListToCsvConverter().convert(output));
}
