import 'package:drift/drift.dart';

// Represents a table for storing information about insurance companies.
class InsuranceCompanies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0, max: 64).unique()();
}

// Represents a table for storing information about ZZa actions.
class ZzaActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionTitle => text().withLength(min: 0, max: 128)();
  TextColumn get actionDescription => text().withLength(min: 0, max: 1024).nullable()();
  DateTimeColumn get dateFrom => dateTime()();
  DateTimeColumn get dateTo => dateTime()();
}

// Represents a table for storing information about participants.
class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text().withLength(min: 0, max: 64)();
  TextColumn get lastName => text().withLength(min: 0, max: 64)();
  IntColumn get gender => integer().nullable().nullable()();
  TextColumn get address => text().withLength(min: 0, max: 128).nullable()();
  TextColumn get birthNumber => text().withLength(min: 0, max: 11).nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get parentPhoneNumber => text().withLength(min: 0, max: 13).nullable()();
  BoolColumn get eligibleConfirmation => boolean().withDefault(const Constant(false))();
  BoolColumn get nonInfectiousConfirmation => boolean().withDefault(const Constant(false))();
  BoolColumn get wasPrinted => boolean().withDefault(const Constant(false))();

  // Foreign keys
  IntColumn get insuranceCompanyFK => integer().references(InsuranceCompanies, #id).nullable()();
  IntColumn get zzaActionFK => integer().references(ZzaActions, #id)();
}

// Represents a table for storing information about Paramedics.
class Paramedics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text().withLength(min: 0, max: 64)();
  TextColumn get lastName => text().withLength(min: 0, max: 64)();
  TextColumn get address => text().withLength(min: 0, max: 128)();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get phoneNumber => text().withLength(min: 0, max: 13)();
  TextColumn get username => text().withLength(min: 0, max: 64).unique()();
}

// Represents a table for storing information about Records.
class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dateAndTime => dateTime()();
  TextColumn get title => text().withLength(min: 0, max: 64)();
  TextColumn get description => text().withLength(min: 0, max: 512)();
  TextColumn get treatment => text().withLength(min: 0, max: 512).nullable()();
  BoolColumn get wasPrinted => boolean().withDefault(const Constant(false))();

  // Foreign keys
  IntColumn get paramedicFK => integer().references(Paramedics, #id)();
  IntColumn get participantFK => integer().references(Participants, #id)();
}

// Represents a table for storing information about Allergies.
class AllergiesLimitations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 0, max: 1024)();

  // Foreign keys
  IntColumn get participantFK => integer().references(Participants, #id)();
}

// Represents a table for storing information about Medications.
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0, max: 128)();
  TextColumn get dosage => text().withLength(min: 0, max: 512)();
  TextColumn get dosageTiming => text().withLength(min: 0, max: 1024)();

  // Foreign keys
  IntColumn get participantFK => integer().references(Participants, #id)();
}

// Represents a table for storing information about Cache.
class Cache extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pinnedActionID => integer().nullable().withDefault(const Constant(null))();
  IntColumn get currentActionID => integer().nullable().withDefault(const Constant(null))();
}