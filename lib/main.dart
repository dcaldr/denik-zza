import 'package:denik_zza/design_system/zza_app_config.dart';
import 'package:denik_zza/screens2/event_list.dart';
import 'package:flutter/material.dart';
import '../input/file_manager.dart';

void main() async {
  // Shared initialization (Locales, Formatting)
  await ZzaAppConfig.initialize();

  // Backend initialization (Files, DB)
  FileManager();
  FileManager().changeEvent();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ZzaAppConfig.appTitle,
      theme: ZzaAppConfig.theme,
      builder: ZzaAppConfig.responsiveBuilder,
      home: EventList(),
      locale: ZzaAppConfig.supportedLocales.first,
      supportedLocales: ZzaAppConfig.supportedLocales,
      localizationsDelegates: ZzaAppConfig.delegates,
    );
  }
}
