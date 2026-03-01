// ignore_for_file: avoid_print
// tmp_layout_diagnostic.dart
// Diagnostic script to trace constraint flow through the entire widget tree
// Run with: flutter run -t lib/dev/tmp_layout_diagnostic.dart

import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';

void main() {
  runApp(const LayoutDiagnosticApp());
}

class LayoutDiagnosticApp extends StatelessWidget {
  const LayoutDiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layout Diagnostic',
      theme: ThemeData(useMaterial3: true),
      home: const DiagnosticPage(),
    );
  }
}

class DiagnosticPage extends StatelessWidget {
  const DiagnosticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Diagnostic'),
      ),
      body: LayoutBuilder(
        builder: (context, scaffoldConstraints) {
          print('');
          print('=== SCAFFOLD BODY CONSTRAINTS ===');
          print('  minWidth: ${scaffoldConstraints.minWidth}');
          print('  maxWidth: ${scaffoldConstraints.maxWidth}');
          print('  minHeight: ${scaffoldConstraints.minHeight}');
          print('  maxHeight: ${scaffoldConstraints.maxHeight}');
          print('  isBounded: ${scaffoldConstraints.maxHeight.isFinite}');
          print('');

          return Padding(
            padding: AppSpacing.screenPadding,
            child: LayoutBuilder(
              builder: (context, paddedConstraints) {
                print('=== AFTER PADDING (20px all) ===');
                print('  maxHeight: ${paddedConstraints.maxHeight}');
                print(
                    '  Expected: scaffoldMax - 40 = ${scaffoldConstraints.maxHeight - 40}');
                print('');

                // Simulate the form structure
                return _buildFormSimulation(context, paddedConstraints);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormSimulation(
      BuildContext context, BoxConstraints formConstraints) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, scrollViewConstraints) {
          print('=== INSIDE SingleChildScrollView ===');
          print('  minHeight: ${scrollViewConstraints.minHeight}');
          print('  maxHeight: ${scrollViewConstraints.maxHeight}');
          print('  isBounded: ${scrollViewConstraints.maxHeight.isFinite}');
          print('  !!! This is UNBOUNDED - infinite height allowed');
          print('');

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulate form fields
              _buildMeasuredWidget('GridView (3 rows)', 180),
              AppSpacing.mediumGap,
              _buildMeasuredWidget('TextField (maxLines: 3)', 80),
              AppSpacing.mediumGap,
              _buildMeasuredWidget('CheckboxSection', 84),
              AppSpacing.smallGap,

              // Simulate RestrictionsSection with Row
              _buildRestrictionsSection(context),

              AppSpacing.smallGap,
              _buildMeasuredWidget('FilledButton', 48),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRestrictionsSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, rowConstraints) {
        print('=== RESTRICTIONS ROW CONSTRAINTS ===');
        print('  maxWidth: ${rowConstraints.maxWidth}');
        print('  maxHeight: ${rowConstraints.maxHeight}');
        print('  isBounded: ${rowConstraints.maxHeight.isFinite}');
        print('');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildRestrictionsWidget(context, 'Omezeni')),
            AppSpacing.buttonGap,
            Expanded(child: _buildRestrictionsWidget(context, 'Leky')),
          ],
        );
      },
    );
  }

  Widget _buildRestrictionsWidget(BuildContext context, String name) {
    return LayoutBuilder(
      builder: (context, widgetConstraints) {
        print('=== RestrictionsWidget ($name) CONSTRAINTS ===');
        print('  maxWidth: ${widgetConstraints.maxWidth}');
        print('  maxHeight: ${widgetConstraints.maxHeight}');
        print('  isBounded: ${widgetConstraints.maxHeight.isFinite}');

        // This is what the current RestrictionsWidget does in _buildBoundedList
        final listHeight = widgetConstraints.maxHeight.isFinite
            ? widgetConstraints.maxHeight
            : AppBreakpoints.listHeightForItems(context, widgetConstraints,
                itemCount: 3);

        print('  Calculated listHeight: $listHeight');
        print('');

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name (Title)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              height: listHeight.clamp(50.0, 200.0), // Clamp for visibility
              color: Colors.blue.shade100,
              child: Center(
                  child: Text('List area: ${listHeight.toStringAsFixed(0)}px')),
            ),
            const SizedBox(height: 8),
            _buildMeasuredWidget('Input area', 56),
          ],
        );
      },
    );
  }

  Widget _buildMeasuredWidget(String label, double estimatedHeight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: estimatedHeight,
          color: Colors.grey.shade200,
          child: Center(
            child: Text('$label (~${estimatedHeight.toInt()}px)'),
          ),
        );
      },
    );
  }
}
