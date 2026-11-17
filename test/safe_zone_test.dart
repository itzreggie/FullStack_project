import 'package:flutter_test/flutter_test.dart';

import 'package:aught/services/notification_service.dart';

void main() {
  // A rough box around central Lappeenranta.
  final square = [
    {'lat': 61.050, 'lng': 28.170},
    {'lat': 61.050, 'lng': 28.200},
    {'lat': 61.070, 'lng': 28.200},
    {'lat': 61.070, 'lng': 28.170},
  ];

  group('NotificationService.pointInPolygon', () {
    test('finds a point inside the zone', () {
      expect(NotificationService.pointInPolygon(61.060, 28.185, square), isTrue);
    });

    test('rejects a point outside the zone', () {
      expect(NotificationService.pointInPolygon(61.080, 28.185, square), isFalse);
      expect(NotificationService.pointInPolygon(61.060, 28.150, square), isFalse);
    });

    test('works with a slanted shape', () {
      final slanted = [
        {'lat': 61.050, 'lng': 28.170},
        {'lat': 61.055, 'lng': 28.200},
        {'lat': 61.075, 'lng': 28.195},
        {'lat': 61.070, 'lng': 28.165},
      ];
      expect(NotificationService.pointInPolygon(61.062, 28.183, slanted), isTrue);
      expect(NotificationService.pointInPolygon(61.051, 28.198, slanted), isFalse);
    });
  });
}
