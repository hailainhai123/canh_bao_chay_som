import 'package:flutter/cupertino.dart';

class ThietBi {
  String matb;
  String madiadiem;
  String trangthai;
  String nguongcb;
  String tu;
  String thoigian;
  String nhietdo;
  String mac;
  Color color;
  List<dynamic> id;

  ThietBi(this.matb, this.madiadiem, this.trangthai, this.nguongcb,
      this.thoigian, this.mac, this.tu);

  ThietBi.fromJson(Map<String, dynamic> json)
      : matb = json['matb'],
        madiadiem = json['madiadiem'],
        trangthai = json['trangthai'],
        nguongcb = json['nguongcb'],
        tu = json['tu'],
        thoigian = json['thoigian'],
        nhietdo = json['nhietdo'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'matb': matb,
        'madiadiem': madiadiem,
        'trangthai': trangthai,
        'nguongcb': nguongcb,
        'nhietdo': nhietdo,
        'tu': tu,
        'thoigian': thoigian,
        'mac': mac,
      };

  @override
  String toString() {
    return '$matb - $madiadiem - $nguongcb - $tu - $thoigian';
  }
}
