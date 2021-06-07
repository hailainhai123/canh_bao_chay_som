import 'package:flutter/cupertino.dart';

class ThietBi {
  String matb;
  String madiadiem;
  String trangthai;
  String nguongcb;
  String vitri;
  String thoigian;
  String nhietdo;
  String mac;
  Color color;
  List<dynamic> id;

  ThietBi(this.matb, this.madiadiem, this.trangthai, this.nguongcb,
      this.thoigian, this.mac, this.vitri);

  ThietBi.fromJson(Map<String, dynamic> json)
      : matb = json['matb'],
        madiadiem = json['madiadiem'],
        trangthai = json['trangthai'],
        nguongcb = json['nguongcb'],
        vitri = json['vitri'],
        thoigian = json['thoigian'],
        nhietdo = json['nhietdo'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'matb': matb,
        'madiadiem': madiadiem,
        'trangthai': trangthai,
        'nguongcb': nguongcb,
        'nhietdo': nhietdo,
        'vitri': vitri,
        'thoigian': thoigian,
        'mac': mac,
      };

  @override
  String toString() {
    return '$matb - $madiadiem - $nguongcb - $vitri - $thoigian';
  }
}
