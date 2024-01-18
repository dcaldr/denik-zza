import 'package:drift/drift.dart';

class InsuranceCompanies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0, max: 64).unique()();
}

class ZzaActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionTitle => text().withLength(min: 0, max: 128)();
  TextColumn get actionDescription => text().withLength(min: 0, max: 1024).nullable()();
  DateTimeColumn get dateFrom => dateTime()();
  DateTimeColumn get dateTo => dateTime()();
}

class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text().withLength(min: 0, max: 64)();
  TextColumn get lastName => text().withLength(min: 0, max: 64)();
  TextColumn get address => text().withLength(min: 0, max: 128)();
  TextColumn get birthNumber => text().withLength(min: 0, max: 11)();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get parentPhoneNumber => text().withLength(min: 0, max: 13)();
  BoolColumn get eligibleConfirmation => boolean().withDefault(const Constant(false))();
  BoolColumn get nonInfectiousConfirmation => boolean().withDefault(const Constant(false))();
  BoolColumn get wasPrinted => boolean().withDefault(const Constant(false))();

  // Foreign keys
  IntColumn get insuranceCompany => integer().references(InsuranceCompanies, #id)();
  IntColumn get zzaAction => integer().references(ZzaActions, #id)();
}

class Paramedics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text().withLength(min: 0, max: 64)();
  TextColumn get lastName => text().withLength(min: 0, max: 64)();
  TextColumn get address => text().withLength(min: 0, max: 128)();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get phoneNumber => text().withLength(min: 0, max: 13)();
  TextColumn get username => text().withLength(min: 0, max: 64).unique()();
}

class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dateAndTime => dateTime()();
  TextColumn get title => text().withLength(min: 0, max: 64)();
  TextColumn get description => text().withLength(min: 0, max: 512)();
  TextColumn get treatment => text().withLength(min: 0, max: 512)();
  BoolColumn get wasPrinted => boolean().withDefault(const Constant(false))();

  // Foreign keys
  IntColumn get paramedic => integer().references(Paramedics, #id)();
  IntColumn get participant => integer().references(Participants, #id)();
}

class AllergiesLimitations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 0, max: 1024)();

  // Foreign keys
  IntColumn get participant => integer().references(Participants, #id)();
}

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0, max: 128)();
  TextColumn get dosage => text().withLength(min: 0, max: 512)();
  TextColumn get dosageTiming => text().withLength(min: 0, max: 1024)();

  // Foreign keys
  IntColumn get participant => integer().references(Participants, #id)();
}