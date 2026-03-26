import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/settings/data/data_transfer_service.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

void main() {
  late DataTransferService service;

  setUp(() {
    service = DataTransferService();
  });

  // Helpers
  Subscription _makeSub({
    String id = 'test-id-1',
    String name = 'Netflix',
    double cost = 15.99,
    BillingCycle cycle = BillingCycle.monthly,
    DateTime? firstBillDate,
    SubCategory category = SubCategory.entertainment,
    String colorHex = '#FF0000',
    SubStatus status = SubStatus.active,
  }) {
    return Subscription(
      id: id,
      name: name,
      cost: cost,
      cycle: cycle,
      firstBillDate: firstBillDate ?? DateTime(2024, 1, 1),
      category: category,
      colorHex: colorHex,
      status: status,
    );
  }

  // Builds a minimal valid CSV string with the version+header rows prepended.
  String _buildCsv(List<String> dataRows) {
    final header =
        '# SubSentry Data Export v1.0.0\r\n'
        'id,name,cost,cycle,firstBillDate,category,colorHex,status,'
        'nextBillOverride,paymentSource,cancellationUrl,isTrial,'
        'trialEndDate,contractEndDate,notes,ignoreWeekendShift,'
        'includeInWeeklySummary';
    return '$header\r\n${dataRows.join('\r\n')}';
  }

  // A valid data row for 'Netflix'
  const String _netflixRow =
      'test-id-1,Netflix,15.99,monthly,2024-01-01T00:00:00.000,'
      'entertainment,#FF0000,active,,,,0,,,,,0,1';

  // A valid data row for 'Spotify'
  const String _spotifyRow =
      'test-id-2,Spotify,9.99,monthly,2024-02-01T00:00:00.000,'
      'entertainment,#00FF00,active,,,,0,,,,,0,1';

  group('exportToCsv / importFromCsv round-trip', () {
    test('round-trips two subscriptions preserving key fields', () {
      final subs = [
        _makeSub(
          id: 'uuid-1',
          name: 'Netflix',
          cost: 15.99,
          cycle: BillingCycle.monthly,
          firstBillDate: DateTime(2024, 1, 15),
          category: SubCategory.entertainment,
          status: SubStatus.active,
        ),
        _makeSub(
          id: 'uuid-2',
          name: 'Adobe CC',
          cost: 52.99,
          cycle: BillingCycle.yearly,
          firstBillDate: DateTime(2023, 6, 1),
          category: SubCategory.software,
          status: SubStatus.active,
        ),
      ];

      final csv = service.exportToCsv(subs);
      final imported = service.importFromCsv(csv);

      expect(imported.length, 2);

      expect(imported[0].id, 'uuid-1');
      expect(imported[0].name, 'Netflix');
      expect(imported[0].cost, 15.99);
      expect(imported[0].cycle, BillingCycle.monthly);
      expect(imported[0].firstBillDate, DateTime(2024, 1, 15));
      expect(imported[0].category, SubCategory.entertainment);
      expect(imported[0].status, SubStatus.active);

      expect(imported[1].id, 'uuid-2');
      expect(imported[1].name, 'Adobe CC');
      expect(imported[1].cost, 52.99);
      expect(imported[1].cycle, BillingCycle.yearly);
      expect(imported[1].firstBillDate, DateTime(2023, 6, 1));
      expect(imported[1].category, SubCategory.software);
    });
  });

  group('importFromCsv — malformed rows', () {
    test('skips row with non-numeric cost and imports remaining rows', () {
      final badCostRow =
          'test-id-bad,BadSub,not-a-number,monthly,2024-01-01T00:00:00.000,'
          'entertainment,#FF0000,active,,,,0,,,,,0,1';

      final csv = _buildCsv([badCostRow, _spotifyRow]);
      final result = service.importFromCsv(csv);

      expect(result.length, 1);
      expect(result.first.name, 'Spotify');
    });

    test('skips row with fewer than 17 columns without throwing', () {
      const shortRow = 'test-id-short,ShortSub,9.99,monthly';
      final csv = _buildCsv([shortRow, _netflixRow]);
      final result = service.importFromCsv(csv);

      expect(result.length, 1);
      expect(result.first.name, 'Netflix');
    });

    test('skips row with invalid date without throwing', () {
      const badDateRow =
          'test-id-3,BadDate,9.99,monthly,not-a-date,'
          'entertainment,#FF0000,active,,,,0,,,,,0,1';
      final csv = _buildCsv([badDateRow, _netflixRow]);
      final result = service.importFromCsv(csv);

      expect(result.length, 1);
      expect(result.first.name, 'Netflix');
    });
  });

  group('importFromCsv — empty / header-only input', () {
    test('throws on completely empty string', () {
      expect(() => service.importFromCsv(''), throwsException);
    });

    test('returns empty list for header-only CSV (no data rows)', () {
      final csv = _buildCsv([]);
      final result = service.importFromCsv(csv);
      expect(result, isEmpty);
    });

    test('throws on missing version header', () {
      const noHeader = 'id,name,cost\r\ntest-id-1,Netflix,15.99';
      expect(() => service.importFromCsv(noHeader), throwsException);
    });
  });

  group('importFromCsv — import count', () {
    test('returns correct count for fully valid CSV', () {
      final csv = _buildCsv([_netflixRow, _spotifyRow]);
      final result = service.importFromCsv(csv);
      expect(result.length, 2);
    });

    test('returns correct count when one of two rows is malformed', () {
      const badRow =
          'bad-id,Bad,NOTANUMBER,monthly,2024-01-01T00:00:00.000,'
          'entertainment,#000,active,,,,0,,,,,0,1';
      final csv = _buildCsv([_netflixRow, badRow]);
      final result = service.importFromCsv(csv);
      expect(result.length, 1);
    });
  });
}
