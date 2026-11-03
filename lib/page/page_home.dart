import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jadwal_sholat/page/page_list_jadwal.dart';
import 'package:lottie/lottie.dart';

import '../model/model_adzan.dart';
import '../tools/tools.dart';

var formatter = DateFormat('EEEE, dd MMM yyyy');
var date = DateTime.now();

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  String strLatLong = 'Belum Mendapatkan Lat dan Long, Silahkan tekan tombol';
  String strAlamat = 'Mencari lokasi...';
  String? strKota, strTimeNow;
  double latitude = 0;
  double longitude = 0;
  String strDate = formatter.format(date);
  Timer? timer;

  void getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);

    setState(() {
      strTimeNow = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  Future getLocation() async {
    Position position = await getGeoLocationPosition();
    setState(() {
      strLatLong = '${position.latitude}, ${position.longitude}';
    });

    getAddressFromLongLat(position);
  }

  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location service Not Enabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permission denied forever, we cannot access',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  Future getAddressFromLongLat(Position position) async {
    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    Placemark place = placemarks[0];
    setState(() {
      strAlamat = '${place.subLocality}, ${place.subAdministrativeArea}';
      strKota = '${place.subAdministrativeArea}';

      getJadwal();
    });
  }

  Future getJadwal() async {
    var url = Uri.parse(
      'http://api.aladhan.com/v1/timingsByCity/${GetDateToday.getDateToday3()}?city=${strKota!}&country=Indonesia&method=5',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return ModelAdzan.fromJson(data);
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  @override
  initState() {
    getLocation();
    strTimeNow = _formatDateTime(DateTime.now());
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => getTime());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/ic_prayer.png',
            width: 40,
            height: 40,
          ),
        ),
        title: const Text(
          'Jadwal Sholat',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F1F),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
                Icons.info_outline,
                color: Color(0xFF1F1F1F)
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/bg_masjid.jpg",
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    strTimeNow!,
                    style: TextStyle(
                      fontSize: 64,
                      color: Color(0xFFFFB030),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                top: 140,
                child: Column(
                  children: [
                    Text(
                      strDate,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(color: Colors.white, height: 2, width: 250),
                    SizedBox(height: 10),
                    Text(
                      VariableGlobal.strInfoTime,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                bottom: 25,
                child: Container(
                  margin: const EdgeInsets.only(top: 220, left: 30, right: 30),
                  height: 20,
                  width: size.width,
                  decoration: const BoxDecoration(
                    color: Color(0x45FFFFFF),
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10,
                            right: 10
                        ),
                        child: Text(
                          strAlamat,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Card(
            margin: const EdgeInsets.all(14),
            clipBehavior: Clip.antiAlias,
            elevation: 5,
            color: Colors.white,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: size.height * 0.55,
              child: FutureBuilder(
                future: getJadwal(),
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    return Lottie.asset(
                      'assets/raw/no_connection.json',
                      width: size.width,
                      height: size.height,
                    );
                  }
                  else {
                    if (!snapshot.hasData) {
                      SizedBox(
                        height: size.height / 1.3,
                        child: Center(
                          child: Text(
                            "Ups, Error ${snapshot.error}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }
                    else {
                      var items = snapshot.data as ModelAdzan;

                      var now = DateTime.now();
                      int dateHours = 0;
                      var formatterHour = DateFormat('HHmm');
                      dateHours = int.parse('1${formatterHour.format(now)}');

                      if (dateHours >= int.parse('1${items.strImsak.toString().replaceAll(':', '')}',)
                          && dateHours < int.parse('1${items.strSubuh.toString().replaceAll(':', '')}')) {
                        VariableGlobal.strInfoTime = 'Saatnya Imsak';
                      }
                      else if (dateHours >= int.parse('1${items.strSubuh.toString().replaceAll(':', '')}',)
                          && dateHours < int.parse('1${items.strFajar.toString().replaceAll(':', '')}')) {
                        VariableGlobal.strInfoTime = 'Menuju Waktu Subuh';
                      }
                      else if (dateHours >= int.parse('1${items.strFajar.toString().replaceAll(':', '')}',)
                          && dateHours < int.parse('1${items.strZuhur.toString().replaceAll(':', '')}')) {
                        VariableGlobal.strInfoTime = 'Menuju Waktu Zuhur';
                      }
                      else if (dateHours >= int.parse('1${items.strZuhur.toString().replaceAll(':', '')}')
                          && dateHours < int.parse('1${items.strAshar.toString().replaceAll(':', '')}')) {
                        VariableGlobal.strInfoTime = 'Menuju Waktu Ashar';
                      }
                      else if (dateHours >= int.parse('1${items.strAshar.toString().replaceAll(':', '')}')
                          && dateHours < int.parse('1${items.strMaghrib.toString().replaceAll(':', '')}')) {
                        VariableGlobal.strInfoTime = 'Menuju Waktu Maghrib';
                      }
                      else if (dateHours >= int.parse('1${items.strMaghrib.toString().replaceAll(':', '')}')
                          && dateHours < int.parse('1${items.strIsya.toString().replaceAll(':', '')}')) {
                        VariableGlobal.strInfoTime = 'Menuju Waktu Isya';
                      }
                      else {
                        VariableGlobal.strInfoTime = "Selamat Beristirahat 😊";
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              'Jadwal Sholat Hari ini:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color(0xFF1F1F1F),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                Row(
                                  children: [
                                    Lottie.asset(
                                      'assets/raw/raw_imsak.json',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Imsak',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strImsak.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Lottie.asset(
                                      'assets/raw/raw_subuh.json',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Subuh',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strSubuh.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Lottie.asset(
                                      'assets/raw/raw_terbit.json',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Fajar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strFajar.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Lottie.asset(
                                      'assets/raw/raw_zuhur.json',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Zuhur',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strZuhur.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Lottie.asset(
                                      'assets/raw/raw_ashar.json',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Ashar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strAshar.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Lottie.asset(
                                      'assets/raw/raw_maghrib.json',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Maghrib',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strMaghrib.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Lottie.asset(
                                      'assets/raw/raw_isya.json',
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Isya',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strIsya.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF353C4C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox(
                      height: size.height / 1.3,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF718355),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                const PageListJadwal()
            ),
          );
        },
        label: const Text(
          'Lihat Semua Jadwal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        icon: const Icon(
          Icons.align_horizontal_left,
          color: Colors.white,
          size: 12,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

  class VariableGlobal {
  static String strInfoTime = "Memuat...";

  static void updateInfoTime(int dateHours, dynamic items) {
  if (dateHours >= int.parse('1${items.strImsak.toString().replaceAll(':', '')}') &&
  dateHours < int.parse('1${items.strSubuh.toString().replaceAll(':', '')}')) {
  strInfoTime = 'Saatnya Imsak';
  }
  else if (dateHours >= int.parse('1${items.strSubuh.toString().replaceAll(':', '')}') &&
  dateHours < int.parse('1${items.strFajar.toString().replaceAll(':', '')}')) {
  strInfoTime = 'Menuju Waktu Subuh';
  }
  else if (dateHours >= int.parse('1${items.strFajar.toString().replaceAll(':', '')}') &&
  dateHours < int.parse('1${items.strZuhur.toString().replaceAll(':', '')}')) {
  strInfoTime = 'Menuju Waktu Zuhur';
  }
  else if (dateHours >= int.parse('1${items.strZuhur.toString().replaceAll(':', '')}') &&
  dateHours < int.parse('1${items.strAshar.toString().replaceAll(':', '')}')) {
  strInfoTime = 'Menuju Waktu Ashar';
  }
  else if (dateHours >= int.parse('1${items.strAshar.toString().replaceAll(':', '')}') &&
  dateHours < int.parse('1${items.strMaghrib.toString().replaceAll(':', '')}')) {
  strInfoTime = 'Menuju Waktu Maghrib';
  }
  else if (dateHours >= int.parse('1${items.strMaghrib.toString().replaceAll(':', '')}') &&
  dateHours < int.parse('1${items.strIsya.toString().replaceAll(':', '')}')) {
  strInfoTime = 'Menuju Waktu Isya';
  }
  else {
  strInfoTime = "Selamat Beristirahat 😊";
  }
  }
  }

class GetDateToday {
  static String getDateToday3() {
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(now);
  }
}
