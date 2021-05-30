class ThietBi {
  String mathietbi;
  String makhoa;
  String trangthai;
  String nguong;
  String vitri;
  String thoigian;
  String mac;

  ThietBi(this.mathietbi, this.makhoa, this.trangthai, this.nguong,
      this.thoigian, this.mac, this.vitri);

  ThietBi.fromJson(Map<String, dynamic> json)
      : mathietbi = json['mathietbi'],
        makhoa = json['makhoa'],
        trangthai = json['trangthai'],
        nguong = json['nguong'],
        vitri = json['vitri'],
        thoigian = json['thoigian'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'mathietbi': mathietbi,
        'makhoa': makhoa,
        'trangthai': trangthai,
        'nguong': nguong,
        'vitri': vitri,
        'thoigian': thoigian,
        'mac': mac,
      };

  @override
  String toString() {
    return '$mathietbi - $makhoa - $nguong - $vitri - $thoigian';
  }
}
