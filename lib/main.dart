import 'package:denik_zza/print_ops/pdf_old.dart';
import 'package:denik_zza/screens/login/login_page.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deník ZZA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Login(),
    );
  }
}
List<String> notes = [
  '10:35 bolest hlavy z programování',
  '11:00 - dlouhodobě si stěžuje natolik, aby byl text zápisu co nejdelší',
  'přitom obsahoval co nejvíce záludností',
  'dále by docela rád viděl jak se dlouhý text dále kupí a kupí, ale to se snad nějakým způsobem dále natáhne aby bylo vidět, jestli se text dokáže zalomit sám, bez vložení dalších speciálních znaků',
  '11:30 už to dále nezvládá',
  '14:30 absolutně nechápe, jaktože je ještě naživu',
];
