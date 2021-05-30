class GetBN {
  final String mac;
  final String makhoa;

  GetBN(this.mac, this.makhoa);

  Map<String, dynamic> toJson() => {
        'mac': mac,
        'makhoa': makhoa,
      };

  GetBN.fromJson(Map<String, dynamic> json)
      : mac = 'mac',
        makhoa = 'makhoa';
}
