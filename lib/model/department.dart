import 'dart:convert';

import 'package:floor/floor.dart';

@entity
class Department {
  @primaryKey
  @ColumnInfo(name: 'vitri', nullable: false)
  final String vitri;
  @ColumnInfo(name: 'mavitri', nullable: false)
  final String mavitri;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;


  Department(this.vitri, this.mavitri, this.mac);

  String get departmentNameDecode {
    try {
      String s = vitri;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return vitri;
    }
  }

  Department.fromJson(Map<String, dynamic> json)
      : vitri = json['vitri'],
        mavitri = json['mavitri'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'vitri': vitri,
        'mavitri': mavitri,
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
