import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

class DataTransferService {
  static const String currentVersion = '1.0.0';
  static const String versionHeader = '# SubSentry Data Export v';

  String exportToCsv(List<Subscription> subscriptions) {
    final List<List<dynamic>> rows = [];

    // Version Information
    rows.add(['$versionHeader$currentVersion']);

    // Header Row
    rows.add([
      'id',
      'name',
      'cost',
      'cycle',
      'firstBillDate',
      'category',
      'colorHex',
      'status',
      'nextBillOverride',
      'paymentSource',
      'cancellationUrl',
      'isTrial',
      'trialEndDate',
      'contractEndDate',
      'notes',
      'ignoreWeekendShift',
      'includeInWeeklySummary'
    ]);

    // Data Rows
    for (final sub in subscriptions) {
      rows.add([
        sub.id,
        sub.name,
        sub.cost,
        sub.cycle.name,
        sub.firstBillDate.toIso8601String(),
        sub.category.name,
        sub.colorHex,
        sub.status.name,
        sub.nextBillOverride?.toIso8601String() ?? '',
        sub.paymentSource ?? '',
        sub.cancellationUrl ?? '',
        sub.isTrial ? 1 : 0,
        sub.trialEndDate?.toIso8601String() ?? '',
        sub.contractEndDate?.toIso8601String() ?? '',
        sub.notes ?? '',
        sub.ignoreWeekendShift ? 1 : 0,
        sub.includeInWeeklySummary ? 1 : 0,
      ]);
    }

    return CsvCodec().encode(rows);
  }

  List<Subscription> importFromCsv(String csvContent) {
    // Basic CSV parsing using CsvCodec
    final List<List<dynamic>> rows = CsvCodec().decode(csvContent);

    if (rows.isEmpty) throw Exception('CSV is empty');

    // Check version
    final firstRow = rows[0];
    if (firstRow.isEmpty || !firstRow[0].toString().startsWith(versionHeader)) {
      throw Exception('Invalid SubSentry export file (missing version header)');
    }

    // Skip version header and column header
    final dataRows = rows.skip(2).toList();
    final List<Subscription> subscriptions = [];

    for (final row in dataRows) {
      if (row.length < 17) continue; // Skip incomplete rows

      try {
        subscriptions.add(Subscription(
          id: row[0].toString(),
          name: row[1].toString(),
          cost: double.parse(row[2].toString()),
          cycle: BillingCycle.values.byName(row[3].toString()),
          firstBillDate: DateTime.parse(row[4].toString()),
          category: SubCategory.values.byName(row[5].toString()),
          colorHex: row[6].toString(),
          status: SubStatus.values.byName(row[7].toString()),
          nextBillOverride: row[8].toString().isNotEmpty
              ? DateTime.parse(row[8].toString())
              : null,
          paymentSource:
              row[9].toString().isNotEmpty ? row[9].toString() : null,
          cancellationUrl:
              row[10].toString().isNotEmpty ? row[10].toString() : null,
          isTrial: row[11].toString() == '1' || row[11].toString() == 'true',
          trialEndDate: row[12].toString().isNotEmpty
              ? DateTime.parse(row[12].toString())
              : null,
          contractEndDate: row[13].toString().isNotEmpty
              ? DateTime.parse(row[13].toString())
              : null,
          notes: row[14].toString().isNotEmpty ? row[14].toString() : null,
          ignoreWeekendShift:
              row[15].toString() == '1' || row[15].toString() == 'true',
          includeInWeeklySummary:
              row[16].toString() == '1' || row[16].toString() == 'true',
        ));
      } catch (e) {
        // Skip rows with parsing errors or log them
        if (kDebugMode) debugPrint('CSV row parse error: $e');
      }
    }

    return subscriptions;
  }
}
