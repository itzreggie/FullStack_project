import 'package:flutter_test/flutter_test.dart';

import 'package:ahtet/services/device_location.dart';

void main() {
  group('DeviceLocation.generateDeviceId', () {
    test('uses the XXX-XXX format', () {
      final id = DeviceLocation.generateDeviceId();
      expect(id, matches(RegExp(r'^[0-9A-Z]{3}-[0-9A-Z]{3}$')));
    });

    test('has four digits and two letters', () {
      for (var i = 0; i < 50; i++) {
        final chars = DeviceLocation.generateDeviceId().replaceAll('-', '');
        final digits = chars.split('').where((c) => RegExp(r'[0-9]').hasMatch(c));
        final letters = chars.split('').where((c) => RegExp(r'[A-Z]').hasMatch(c));
        expect(digits.length, 4);
        expect(letters.length, 2);
      }
    });
  });
}
