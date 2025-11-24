import 'package:denik_zza/screens2/event_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denik_zza/dev/ui/dev_theme.dart';
import '../input/file_manager.dart';

void main() async {
  // tests if can be commented out the 3 lines below
  // WidgetsFlutterBinding.ensureInitialized();
//  Intl.defaultLocale = 'cs_CZ';
//  await initializeDateFormatting('cs_CZ', null);

  FileManager();
  //db stuff here
  FileManager().changeEvent();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Registration',
      theme: DevTheme.theme,
      // home: const EventRegistrationForm(),
      //home: const ParticipantRegistrationForm(),
      home: EventList(),
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
