# Test Setup Templates

This directory contains pre-configured test data setups for quick testing and development.

## Files

### `dev_main.dart` 🚀 NEW!
A development version of the main app that automatically loads test data.

**To run the development app:**
```bash
flutter run -t test/setup_templates/dev_main.dart
```

**Features:**
- ✅ Pre-loaded test event "Test Test Test"
- ✅ 10 Czech participants with cultural references
- ✅ Medical records with Easter eggs
- ✅ Visual development mode indicator (orange banner)
- ✅ Uses in-memory database for fast iterations
- ✅ Perfect for UI development and testing

### `hardcoded_setup.dart`
Test data setup utility that creates realistic test data.

### What it creates:

1. **Test Event**: "Test Test Test" with Czech description
2. **Insurance Companies**: VZP and OZKP
3. **Paramedic**: Dr. František Zdravotník
4. **10 Czech Participants** with cultural references:
   - Václav Havlík (reference to Václav Havel)
   - Karel Čapková (reference to Karel Čapek)
   - Bedřich Smetana (the composer)
   - Antonín Dvořák (the composer)
   - Milan Kundera (the writer)
   - Jaroslav Hašek (author of Švejk)
   - Tomáš Baťa (shoe entrepreneur)
   - Ema Destinnová (opera singer)
   - Jan Komenský (educator)
   - Franz Kafka (writer)

5. **Medical Records** with Czech cultural easter eggs, including:
   - "má velrybí stoličku a hodně ho bolí" (as requested)
   - Other fun Czech cultural references

### Usage:

```dart
import 'setup_templates/hardcoded_setup.dart';

void main() {
  group('My Tests', () {
    setUp(() async {
      await HardcodedTestSetup.setupTestData();
    });
    
    tearDown(() async {
      await HardcodedTestSetup.cleanup();
    });
    
    test('my test', () async {
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      
      // Now you have 10 Czech participants ready for testing!
      expect(participants.length, equals(10));
    });
  });
}
```

### Quick Setup:

For even simpler usage:
```dart
setUp(() async {
  await HardcodedTestSetup.quickSetup();
});
```

### Features:

- ✅ **Database Safety**: Automatically sets test mode
- ✅ **Czech Cultural References**: Historical and cultural figures
- ✅ **Complete Data**: Events, participants, insurance, paramedics, records
- ✅ **Easter Eggs**: Fun Czech cultural references in medical records
- ✅ **Ready to Use**: Perfect for testing UI, logic, and integrations

### Example Output:

When setup completes, you'll see:
```
✅ Hardcoded test setup completed!
   Event ID: 1
   Participants: 10
   Available for testing with Czech cultural references
```

This setup gives you a realistic test environment that's immediately ready for any kind of testing scenario while maintaining Czech cultural authenticity and humor.

## Development Workflow Benefits

### Using `dev_main.dart` for Development:
- **No Setup Time**: Start coding immediately with populated data
- **Consistent Testing**: Same test data every run
- **Visual Feedback**: Orange banner clearly indicates dev mode
- **Fast Iterations**: In-memory database resets with each restart
- **UI Screenshots**: Perfect for documentation and demos

### Using `hardcoded_setup.dart` for Testing:
- **Unit Tests**: Reliable, consistent test data
- **Integration Tests**: Full app scenarios with realistic data
- **Manual Testing**: Quick setup for exploratory testing
- **CI/CD**: Deterministic test environments
