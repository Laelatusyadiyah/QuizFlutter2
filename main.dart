import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DaftarUMKM {
  int id;
  String nama;
  String jenis;
  DaftarUMKM({required this.id, required this.nama, required this.jenis});
}

class ListNamaDaftarUMKM extends ChangeNotifier {
  List<DaftarUMKM> listNamaDaftarUMKM = <DaftarUMKM>[];

  ListNamaDaftarUMKM({required this.listNamaDaftarUMKM}) {
    fetchData();
  }

  void setFromJson(List<dynamic> json) {
    listNamaDaftarUMKM.clear();
    for (var val in json) {
      var id = val["id"];
      var nama = val["nama"][0];
      var jenis = val["jenis"][0];
      listNamaDaftarUMKM.add(DaftarUMKM(id: id, nama: nama, jenis: jenis));
      notifyListeners();
    }
  }

  void fetchData() async {
    String url = "http://178.128.17.76:8000/daftar_umkm";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
      for (DaftarUMKM umkm in listNamaDaftarUMKM) {
        String detailUrl = "http://178.128.17.76:8000/detil_umkm/";
        final detailResponse = await http.get(Uri.parse(detailUrl));
        if (detailResponse.statusCode == 200) {
          setFromJson(jsonDecode(response.body));
        } else {
          throw Exception('Gagal load');
        }
      }
      notifyListeners();
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  // final counter = CounterCubit();
  // counter.stream.listen((event) {});
  // counter.increment();
  runApp(
    ChangeNotifierProvider<ListNamaDaftarUMKM>(
      create: (context) => ListNamaDaftarUMKM(listNamaDaftarUMKM: []),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Quiz Flutter',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('My App'),
            centerTitle: true,
          ),
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Consumer<ListNamaDaftarUMKM>(builder: (context, id, child) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: const Text(
                            '2108804, Laelatusyadiyah; 2102421, Kania Dinda Fasya; Kami berjanji tidak akan berbuat curang dan atau membantu kelompok lain berbuat curang.'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            id.fetchData();
                          },
                          child: const Text("Reload Daftar UMKM"),
                        ),
                      ),
                    ]));
              }),
              Expanded(
                child: Consumer<ListNamaDaftarUMKM>(
                  builder: (context, id, child) {
                    if (id.listNamaDaftarUMKM.isNotEmpty) {
                      return ListView.builder(
                        itemCount: id.listNamaDaftarUMKM.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Tab(
                                  text: id.listNamaDaftarUMKM[index].nama,
                                ),
                                Tab(
                                  text: id.listNamaDaftarUMKM[index].jenis,
                                ),
                                TabBarView(children: [
                                  FutureBuilder(
                                    future: http.get(Uri.parse(
                                        'http://178.128.17.76:8000/detil_umkm/${id.listNamaDaftarUMKM[index].id}')),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData) {
                                          var data =
                                              jsonDecode(snapshot.data!.body);
                                          return Center(
                                              child: Text(data['detil']));
                                        } else {
                                          return const Text(
                                              'Gagal mengambil data');
                                        }
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ])
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ]),
          ),
        ));
  }
}
