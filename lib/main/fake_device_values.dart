import 'dart:math';

import 'package:health_care/model/thietbi.dart';

class FakeDevices {}

List<ThietBi> createSampleDevices() {
  List<ThietBi> devices = List();
  for (int i = 0; i < 16; i++) {
    var randomId = Random().nextInt(120);
    ThietBi tb = ThietBi('a1','','','','','','');
    tb.nguongcb = '20';
    tb.vitri = 'abc';

    devices.add(tb);
  }
  return devices;
}

