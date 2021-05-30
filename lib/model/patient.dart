import 'dart:convert';

class Patient {
  String mabenhnhan;
  String ten;
  String sdt;
  String nha;
  String mathietbi;
  String phong;
  String giuong;
  String benhan;
  double nhietdo;
  String makhoa;
  String mac;
  String trangthaibn;

  Patient(
    this.mabenhnhan,
    this.ten,
    this.sdt,
    this.nha,
    this.mathietbi,
    this.phong,
    this.giuong,
    this.benhan,
    this.nhietdo,
    this.makhoa,
    this.trangthaibn,
    this.mac,
  );

  Map<String, dynamic> toJson() => {
        'mabenhnhan': mabenhnhan,
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mathietbi': mathietbi,
        'phong': phong,
        'giuong': giuong,
        'benhan': benhan,
        'nhietdo': nhietdo,
        'makhoa': makhoa,
        'trangthaibn': trangthaibn,
        'mac': mac,
      };

  Patient.fromJson(Map<String, dynamic> json)
      : mabenhnhan = json['mabenhnhan'],
        ten = json['ten'],
        sdt = json['sdt'],
        nha = json['nha'],
        mathietbi = json['mathietbi'],
        phong = json['phong'],
        giuong = json['giuong'],
        benhan = json['benhan'],
        nhietdo = json['nhietdo'],
        trangthaibn = json['trangthaibn'],
        mac = json['mac'],
        makhoa = json['makhoa'];

  String get tenDecode {
    try {
      String s = ten;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return ten;
    }
  }

  String get nhaDecode {
    try {
      String s = nha;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return nha;
    }
  }

  String get benhDecode {
    try {
      String s = benhan;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return benhan;
    }
  }

  @override
  String toString() {
    return '$mabenhnhan-$ten-$sdt-$nha-$mathietbi-$nhietdo-$phong-$giuong-$benhan-$makhoa-$mac-$trangthaibn';
  }
}
