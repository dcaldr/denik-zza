import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../input/file_manager.dart';
import 'event_registration_form.dart';

void main() async {
  // tests if can be commented out the 3 lines below
 // WidgetsFlutterBinding.ensureInitialized();
//  Intl.defaultLocale = 'cs_CZ';
//  await initializeDateFormatting('cs_CZ', null);

  FileManager();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EventRegistrationForm(),
      //home: const ParticipantRegistrationForm(),
      locale: const Locale('cs', 'CZ'),
      supportedLocales: const [
        Locale('cs', 'CZ'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}