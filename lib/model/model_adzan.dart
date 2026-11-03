class ModelAdzan {
  String? strSubuh;
  String? strFajar;
  String? strZuhur;
  String? strAshar;
  String? strMaghrib;
  String? strIsya;
  String? strImsak;

  ModelAdzan({this.strSubuh, this.strFajar, this.strZuhur,
    this.strAshar, this.strMaghrib, this.strIsya, this.strImsak});

  factory ModelAdzan.fromJson(Map<String, dynamic> json) {
    return ModelAdzan(
      strSubuh: json['data']['timings']['Fajr'].toString(),
      strFajar: json['data']['timings']['Sunrise'].toString(),
      strZuhur: json['data']['timings']['Dhuhr'].toString(),
      strAshar: json['data']['timings']['Asr'].toString(),
      strMaghrib: json['data']['timings']['Maghrib'].toString(),
      strIsya: json['data']['timings']['Isha'].toString(),
      strImsak: json['data']['timings']['Imsak'].toString(),
    );
  }

}