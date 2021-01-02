import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

Future main(List<String> arguments) async {
  await run('git', ['submodule', 'init']);
  await run('git', ['submodule', 'update', '--remote', '--merge']);
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
    for (final entry in data
        .where((entry) => entry[3] == 'Germany' || entry[1] == 'Germany')) {
      final isShort = entry[1] == 'Germany';
      DateTime dateTime;
      try {
        dateTime =
            DateTime.parse(isShort ? entry[2] as String : entry[4] as String);
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        dateTime = DateFormat('MM/dd/yyyy HH:mm')
            .parse(isShort ? entry[2] as String : entry[4] as String);
      }
      dateTime = DateTime(
          dateTime.year < 2000 ? dateTime.year + 2000 : dateTime.year,
          dateTime.month,
          dateTime.day);
      final count = isShort ? entry[3] as int : entry[7] as int;
      if (intermediate[dateTime] == null) {
        intermediate[dateTime] = 0;
      }
      intermediate[dateTime] += count;
    }
  }
  final output = <List<dynamic>>[
    ['date', 'daily cases'],
  ];
  for (final dateTime in intermediate.keys.toList()
    ..sort((a, b) =>
        a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch))) {
    final previous = intermediate[dateTime.subtract(const Duration(days: 1))];
    // Some data is wrong and produces negative daily cases
    if (previous != null && !(intermediate[dateTime] - previous).isNegative) {
      output.add([
        '${dateTime.year}-${dateTime.month}-${dateTime.day}',
        intermediate[dateTime] - previous,
      ]);
    }
  }
  File('dump.csv')
      .writeAsStringSync(const ListToCsvConverter().convert(output));
  await run('gnuplot', ['-p', 'dump.plot']);
}

Future run(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
