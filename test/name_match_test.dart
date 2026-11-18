import 'package:flutter_test/flutter_test.dart';

import 'package:aught/services/mapbox_search_service.dart';

void main() {
  group('MapboxSearchService.isSimilarName', () {
    test('ignores case and spaces', () {
      expect(MapboxSearchService.isSimilarName('  Prisma ', 'prisma'), isTrue);
    });

    test('matches when one name contains the other', () {
      expect(MapboxSearchService.isSimilarName('Prisma Lappeenranta', 'Prisma'), isTrue);
      expect(MapboxSearchService.isSimilarName('LUT', 'LUT University'), isTrue);
    });

    test('rejects different names', () {
      expect(MapboxSearchService.isSimilarName('Prisma', 'K-Citymarket'), isFalse);
    });
  });
}
