import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:http/http.dart' as http;
import '../model/model_kota.dart';
import '../tools/tools.dart';
import 'package:intl/intl.dart';

class GetDateToday2 {
  // Untuk API: biasanya format yyyy/MM/dd
  static String getDateToday2() {
    return DateFormat('yyyy/MM/dd').format(DateTime.now());
  }
}

class GetDateToday3 {
  // Untuk pengecekan "hari ini"
  static String getDateToday() {
    return DateFormat('EEEE, dd/MM/yyyy', 'id_ID').format(DateTime.now());
  }
}

class SetTime {
  // Untuk format Nama Hari saja atau format pendek
  static String setTime(String date) {
    if (date == "null") return "-";
    // Sesuaikan dengan format yang diinginkan di UI Anda
    return date;
  }
}

class SetTime2 {
  // Digunakan untuk komparasi lastData (biasanya mengembalikan string tanggal saja)
  static String setTime2(String date) {
    if (date == "null") return "";
    return date; // Sesuaikan jika perlu manipulasi string
  }
}

class PageListJadwal extends StatefulWidget {
  const PageListJadwal({super.key});

  @override
  State<PageListJadwal> createState() => _PageListJadwalState();
}

class _PageListJadwalState extends State<PageListJadwal> {
  String selectedItems = '';
  List listAdzanSearch = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<ModelKota>> readJsonData() async {
    final jsonData = await rootBundle.rootBundle.loadString(
      'assets/data/list_kota.json',
    );
    final strKota = json.decode(jsonData) as List<dynamic>;
    return strKota.map((e) => ModelKota.fromJson(e)).toList();
  }

  Future getListAdzanSearch(String strLokasi) async {
    String strURL = 'https://api.myquran.com/v2/sholat/jadwal/$strLokasi/${GetDateToday2.getDateToday2()}';
    final response = await http.get(Uri.parse(strURL));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        listAdzanSearch = data['data']['jadwal'];
      });
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF353C4C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Jadwal Shalat",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF353C4C),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF87986A),
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: DropdownSearch<ModelKota>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    isDense: false,
                    labelText: "Daftar Kota",
                    focusedBorder: InputBorder.none,
                    focusColor: Colors.transparent,
                    suffixIconColor: Color(0xFF87986A),
                    labelStyle: TextStyle(
                      color: Color(0xFF353C4C),
                      fontSize: 14,
                    ),
                    hintStyle: TextStyle(
                      color: Color(0xFF353C4C),
                      fontSize: 16,
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  fit: FlexFit.loose,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Cari Kota",
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Color(0xFF87986A),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            width: 1,
                            color: Color(0xFF8694AF)
                        ),
                      ),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() => selectedItems = value!.id.toString());
                },
                itemAsString: (item) => "${item.lokasi}",
                asyncItems: (text) async {
                  final jsonData = await rootBundle.rootBundle.loadString(
                    'assets/data/list_kota.json',
                  );
                  final strKota = json.decode(jsonData) as List<dynamic>;

                  List listBranch = strKota;
                  var dataBranch = ModelKota.fromJsonList(listBranch);

                  return dataBranch;
                },
              ),
            ),
          ),
          if (selectedItems.toString() == '') ...[
            const SizedBox(),
          ] else ...[
            Flexible(
              child: FutureBuilder(
                future: getListAdzanSearch(selectedItems),
                builder: (context, snapshot) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: listAdzanSearch.length,
                    itemBuilder: (context, index) {
                      var lastData =
                          GetDateToday3.getDateToday() ==
                              SetTime2.setTime2(
                                listAdzanSearch[index]['tanggal'].toString(),
                              );
                      return Card(
                        margin: const EdgeInsets.all(10),
                        clipBehavior: Clip.antiAlias,
                        elevation: 5,
                        color: Color(0xFFFAFAFA),
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: lastData ? Color(0xFF718355) : Color(0xFFFAFAFA),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                height: 48,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: lastData ? Color(0xFF718355) : Color(0xFFE8E8E8),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          SetTime.setTime(
                                            listAdzanSearch[index]['tanggal'].toString(),
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: lastData ? Color(0xFFFAFAFA) : Color(0xFF353C4C),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        SetTime2.setTime2(
                                          listAdzanSearch[index]['tanggal'].toString(),
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: lastData
                                              ? Color(0xFFFAFAFA)
                                              : Color(0xFF353C4C),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 2,
                                              ),
                                              child: const Text(
                                                'Subuh',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF353C4C),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              listAdzanSearch[index]['subuh'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF353C4C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 2,
                                              ),
                                              child: const Text(
                                                'Zuhur',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF353C4C),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              listAdzanSearch[index]['dzuhur'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF353C4C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 2,
                                              ),
                                              child: const Text(
                                                'Ashar',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF353C4C),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              listAdzanSearch[index]['ashar'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF353C4C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 2,
                                              ),
                                              child: const Text(
                                                'Maghrib',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF353C4C),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              listAdzanSearch[index]['maghrib'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF353C4C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 2,
                                              ),
                                              child: const Text(
                                                'Isya',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF353C4C),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              listAdzanSearch[index]['isya'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF353C4C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
