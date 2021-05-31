import 'dart:convert';

import 'package:floor/floor.dart';

@entity
class Department {
  @primaryKey
  @ColumnInfo(name: 'diachidiadiem', nullable: false)
  final String diachidiadiem;
  @ColumnInfo(name: 'madiadiem', nullable: false)
  final String madiadiem;
  @ColumnInfo(name: 'sdtdiadiem', nullable: false)
  final String sdtdiadiem;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;


  Department(this.diachidiadiem, this.madiadiem, this.sdtdiadiem, this.mac);

  String get departmentDiachiDecode {
    try {
      String s = diachidiadiem;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return diachidiadiem;
    }
  }

  Department.fromJson(Map<String, dynamic> json)
      : diachidiadiem = json['diachidiadiem'],
        madiadiem = json['madiadiem'],
        sdtdiadiem = json['sdtdiadiem'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'diachidiadiem': diachidiadiem,
        'madiadiem': madiadiem,
        'sdtdiadiem': sdtdiadiem,
        'mac': mac,
      };
// Room.fromJson(Map<String, dynamic> json)
//     : email = json['email'],
//       pass = json['pass'],
//       ten = json['ten'],
//       sdt = json['sdt'],
//       nha = json['nha'],
//       mac = json['mac'];
//
// Map<String, dynamic> toJson() => {
//   'email': email,
//   'pass': pass,
//   'ten': ten,
//   'sdt': sdt,
//   'nha': nha,
//   'mac': mac,
// };
}
