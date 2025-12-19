import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';

/// Development entry point for Print Center testing.
///
/// Uses standard [DevEnvironment] to populate DB with Czech test participants
/// and records, enabling verification of real Service/Controller/UI stack.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use standard dev environment with Czech test data
  // This sets up DatabaseWrapper.getDatabase() to point to an in-memory test DB
  await DevEnvironment.initialize();

  runApp(buildDevAppWithBanner(
    title: 'Print Ops 2 Dev (Standard Env)',
    home: const DevPrintRoot(),
    bannerMessage: 'PRINT STD',
    bannerIcon: Icons.print_outlined,
  ));
}

/// Root widget that wires up the *Real* Service and Controller.
/// Since DatabaseWrapper is mocked by DevEnvironment, the real service works perfectly.
class DevPrintRoot extends StatelessWidget {
  const DevPrintRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        // Use Real Service (connected to InMemory DB via DevEnvironment)
        final service = PrintCenterService();
        final controller = PrintCenterController(service);
        controller.init(); // Load participants from DB
        return controller;
      },
      child: const PrintCenterPage(),
    );
  }
}
