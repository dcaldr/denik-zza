import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

class EventDetailRobot extends BaseRobot {
  EventDetailRobot(super.tester);

  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(findKey('EventDetail_addButton'), findsOneWidget);
    expect(findKey('EventDetail_searchField'), findsOneWidget);
  }

  Future<void> verifyParticipantPresent(String name) async {
    await pumpAndSettle();
    expect(find.text(name), findsOneWidget);
  }

  Future<void> tapParticipant(String name) async {
    // For Jurský Park: 'Karel Čapek' is index 0.
    // If we can't find by text easily (due to Row complexity), we might use index key.
    // However, find.text usually works if the text is visible.
    // Fallback: look for the "Detail" button associated with the participant.
    // For now, let's try finding the text and then finding the button near it or just finding the button by index if known.

    // Better approach given our Key analysis:
    // We know 'Karel Čapek' is the first participant (index 0).
    // Let's support tapping by Name (text) OR by Index (Key).

    final participantFinder = find.text(name);
    if (participantFinder.evaluate().isNotEmpty) {
      await tap(participantFinder);
      return;
    }

    // If text lookup fails (e.g. obscured), try Key fallback if we assume order.
    // For the Canary test, we know Karel Capek is likely Index 0.
    // But let's stick to the text finding as primary interaction for "User" simulation.
    // If this fails, we will refine.
    throw TestFailure('Participant "$name" not found on screen');
  }

  Future<void> tapParticipantDetailButtonByIndex(int index) async {
    final buttonKey = 'ParticipantListItem_${index}_detailButton';
    final buttonFinder = findKey(buttonKey);
    print('[DIAG][EventDetailRobot.tapParticipantDetailButtonByIndex] '
      'before tap: key=$buttonKey count=${buttonFinder.evaluate().length}');
    await tap(buttonFinder);
    final hasDetailScroll =
      findKey('ParticipantDetail_scroll_list').evaluate().isNotEmpty;
    final hasEventDetailAdd =
      findKey('EventDetail_addButton').evaluate().isNotEmpty;
    final personalInfoTextCount = find.text('Osobní údaje').evaluate().length;
    print('[DIAG][EventDetailRobot.tapParticipantDetailButtonByIndex] '
      'after tap: hasParticipantDetailScroll=$hasDetailScroll '
      'hasEventDetailAdd=$hasEventDetailAdd '
      'osobniUdajeTextCount=$personalInfoTextCount');
  }

  Finder get addParticipantButton => findKey('EventDetail_addButton');

  Future<void> tapAddParticipant() async {
    // Wait for button to exist in widget tree
    final found = await waitForKey('EventDetail_addButton',
        timeout: const Duration(seconds: 5));
    if (!found) {
      throw StateError('EventDetail_addButton not found after waiting 5s');
    }
    await ensureVisible(addParticipantButton);
    await tap(addParticipantButton);
  }

  /// Searches for a participant by typing in the search field.
  Future<void> searchParticipant(String query) async {
    final searchField = findKey('EventDetail_searchField');
    await waitForKey('EventDetail_searchField', timeout: const Duration(seconds: 3));
    await enterText(searchField, query, settle: false);
    // Wait until the search input reflects the query and one frame processes filtering.
    await waitForFieldText('EventDetail_searchField', query);
    await pump();
  }

  /// Clears the search field.
  Future<void> clearSearch() async {
    final searchField = findKey('EventDetail_searchField');
    await enterText(searchField, '', settle: false);
    await waitForFieldText('EventDetail_searchField', '');
    await pump();
  }

  /// Verifies empty-state label rendered by EventDetail search filtering.
  Future<void> verifyNoSearchResults(String query) async {
    final label = 'Žádné výsledky pro "${query}"';
    final found = await waitForText(label, timeout: const Duration(seconds: 3));
    expect(found, isTrue, reason: 'Expected EventDetail empty state for query "$query"');
  }

  Future<void> waitForFieldText(String fieldKey, String expectedText,
      {Duration timeout = const Duration(seconds: 3)}) async {
    final fieldFinder = findKey(fieldKey);
    final sw = Stopwatch()..start();
    while (sw.elapsed < timeout) {
      if (fieldFinder.evaluate().isNotEmpty) {
        final widget = fieldFinder.evaluate().first.widget;
        if (widget is TextField && (widget.controller?.text ?? '') == expectedText) {
          return;
        }
      }
      await pump(const Duration(milliseconds: 50));
    }
    throw TestFailure('Field "$fieldKey" did not reach expected text "$expectedText" within timeout');
  }
}
