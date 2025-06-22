// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $InsuranceCompaniesTable extends InsuranceCompanies
    with TableInfo<$InsuranceCompaniesTable, InsuranceCompany> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsuranceCompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurance_companies';
  @override
  VerificationContext validateIntegrity(Insertable<InsuranceCompany> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InsuranceCompany map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsuranceCompany(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $InsuranceCompaniesTable createAlias(String alias) {
    return $InsuranceCompaniesTable(attachedDatabase, alias);
  }
}

class InsuranceCompany extends DataClass
    implements Insertable<InsuranceCompany> {
  final int id;
  final String name;
  const InsuranceCompany({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  InsuranceCompaniesCompanion toCompanion(bool nullToAbsent) {
    return InsuranceCompaniesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory InsuranceCompany.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsuranceCompany(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  InsuranceCompany copyWith({int? id, String? name}) => InsuranceCompany(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  InsuranceCompany copyWithCompanion(InsuranceCompaniesCompanion data) {
    return InsuranceCompany(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsuranceCompany(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsuranceCompany &&
          other.id == this.id &&
          other.name == this.name);
}

class InsuranceCompaniesCompanion extends UpdateCompanion<InsuranceCompany> {
  final Value<int> id;
  final Value<String> name;
  const InsuranceCompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  InsuranceCompaniesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<InsuranceCompany> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  InsuranceCompaniesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return InsuranceCompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsuranceCompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ZzaActionsTable extends ZzaActions
    with TableInfo<$ZzaActionsTable, ZzaAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZzaActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionTitleMeta =
      const VerificationMeta('actionTitle');
  @override
  late final GeneratedColumn<String> actionTitle = GeneratedColumn<String>(
      'action_title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _actionDescriptionMeta =
      const VerificationMeta('actionDescription');
  @override
  late final GeneratedColumn<String> actionDescription =
      GeneratedColumn<String>('action_description', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 0, maxTextLength: 1024),
          type: DriftSqlType.string,
          requiredDuringInsert: false);
  static const VerificationMeta _dateFromMeta =
      const VerificationMeta('dateFrom');
  @override
  late final GeneratedColumn<DateTime> dateFrom = GeneratedColumn<DateTime>(
      'date_from', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateToMeta = const VerificationMeta('dateTo');
  @override
  late final GeneratedColumn<DateTime> dateTo = GeneratedColumn<DateTime>(
      'date_to', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _homeDirectoryMeta =
      const VerificationMeta('homeDirectory');
  @override
  late final GeneratedColumn<String> homeDirectory = GeneratedColumn<String>(
      'home_directory', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, actionTitle, actionDescription, dateFrom, dateTo, homeDirectory];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zza_actions';
  @override
  VerificationContext validateIntegrity(Insertable<ZzaAction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_title')) {
      context.handle(
          _actionTitleMeta,
          actionTitle.isAcceptableOrUnknown(
              data['action_title']!, _actionTitleMeta));
    } else if (isInserting) {
      context.missing(_actionTitleMeta);
    }
    if (data.containsKey('action_description')) {
      context.handle(
          _actionDescriptionMeta,
          actionDescription.isAcceptableOrUnknown(
              data['action_description']!, _actionDescriptionMeta));
    }
    if (data.containsKey('date_from')) {
      context.handle(_dateFromMeta,
          dateFrom.isAcceptableOrUnknown(data['date_from']!, _dateFromMeta));
    } else if (isInserting) {
      context.missing(_dateFromMeta);
    }
    if (data.containsKey('date_to')) {
      context.handle(_dateToMeta,
          dateTo.isAcceptableOrUnknown(data['date_to']!, _dateToMeta));
    } else if (isInserting) {
      context.missing(_dateToMeta);
    }
    if (data.containsKey('home_directory')) {
      context.handle(
          _homeDirectoryMeta,
          homeDirectory.isAcceptableOrUnknown(
              data['home_directory']!, _homeDirectoryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZzaAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZzaAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      actionTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_title'])!,
      actionDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}action_description']),
      dateFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_from'])!,
      dateTo: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_to'])!,
      homeDirectory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}home_directory']),
    );
  }

  @override
  $ZzaActionsTable createAlias(String alias) {
    return $ZzaActionsTable(attachedDatabase, alias);
  }
}

class ZzaAction extends DataClass implements Insertable<ZzaAction> {
  final int id;
  final String actionTitle;
  final String? actionDescription;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? homeDirectory;
  const ZzaAction(
      {required this.id,
      required this.actionTitle,
      this.actionDescription,
      required this.dateFrom,
      required this.dateTo,
      this.homeDirectory});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_title'] = Variable<String>(actionTitle);
    if (!nullToAbsent || actionDescription != null) {
      map['action_description'] = Variable<String>(actionDescription);
    }
    map['date_from'] = Variable<DateTime>(dateFrom);
    map['date_to'] = Variable<DateTime>(dateTo);
    if (!nullToAbsent || homeDirectory != null) {
      map['home_directory'] = Variable<String>(homeDirectory);
    }
    return map;
  }

  ZzaActionsCompanion toCompanion(bool nullToAbsent) {
    return ZzaActionsCompanion(
      id: Value(id),
      actionTitle: Value(actionTitle),
      actionDescription: actionDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(actionDescription),
      dateFrom: Value(dateFrom),
      dateTo: Value(dateTo),
      homeDirectory: homeDirectory == null && nullToAbsent
          ? const Value.absent()
          : Value(homeDirectory),
    );
  }

  factory ZzaAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZzaAction(
      id: serializer.fromJson<int>(json['id']),
      actionTitle: serializer.fromJson<String>(json['actionTitle']),
      actionDescription:
          serializer.fromJson<String?>(json['actionDescription']),
      dateFrom: serializer.fromJson<DateTime>(json['dateFrom']),
      dateTo: serializer.fromJson<DateTime>(json['dateTo']),
      homeDirectory: serializer.fromJson<String?>(json['homeDirectory']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionTitle': serializer.toJson<String>(actionTitle),
      'actionDescription': serializer.toJson<String?>(actionDescription),
      'dateFrom': serializer.toJson<DateTime>(dateFrom),
      'dateTo': serializer.toJson<DateTime>(dateTo),
      'homeDirectory': serializer.toJson<String?>(homeDirectory),
    };
  }

  ZzaAction copyWith(
          {int? id,
          String? actionTitle,
          Value<String?> actionDescription = const Value.absent(),
          DateTime? dateFrom,
          DateTime? dateTo,
          Value<String?> homeDirectory = const Value.absent()}) =>
      ZzaAction(
        id: id ?? this.id,
        actionTitle: actionTitle ?? this.actionTitle,
        actionDescription: actionDescription.present
            ? actionDescription.value
            : this.actionDescription,
        dateFrom: dateFrom ?? this.dateFrom,
        dateTo: dateTo ?? this.dateTo,
        homeDirectory:
            homeDirectory.present ? homeDirectory.value : this.homeDirectory,
      );
  ZzaAction copyWithCompanion(ZzaActionsCompanion data) {
    return ZzaAction(
      id: data.id.present ? data.id.value : this.id,
      actionTitle:
          data.actionTitle.present ? data.actionTitle.value : this.actionTitle,
      actionDescription: data.actionDescription.present
          ? data.actionDescription.value
          : this.actionDescription,
      dateFrom: data.dateFrom.present ? data.dateFrom.value : this.dateFrom,
      dateTo: data.dateTo.present ? data.dateTo.value : this.dateTo,
      homeDirectory: data.homeDirectory.present
          ? data.homeDirectory.value
          : this.homeDirectory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZzaAction(')
          ..write('id: $id, ')
          ..write('actionTitle: $actionTitle, ')
          ..write('actionDescription: $actionDescription, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('homeDirectory: $homeDirectory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, actionTitle, actionDescription, dateFrom, dateTo, homeDirectory);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZzaAction &&
          other.id == this.id &&
          other.actionTitle == this.actionTitle &&
          other.actionDescription == this.actionDescription &&
          other.dateFrom == this.dateFrom &&
          other.dateTo == this.dateTo &&
          other.homeDirectory == this.homeDirectory);
}

class ZzaActionsCompanion extends UpdateCompanion<ZzaAction> {
  final Value<int> id;
  final Value<String> actionTitle;
  final Value<String?> actionDescription;
  final Value<DateTime> dateFrom;
  final Value<DateTime> dateTo;
  final Value<String?> homeDirectory;
  const ZzaActionsCompanion({
    this.id = const Value.absent(),
    this.actionTitle = const Value.absent(),
    this.actionDescription = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.homeDirectory = const Value.absent(),
  });
  ZzaActionsCompanion.insert({
    this.id = const Value.absent(),
    required String actionTitle,
    this.actionDescription = const Value.absent(),
    required DateTime dateFrom,
    required DateTime dateTo,
    this.homeDirectory = const Value.absent(),
  })  : actionTitle = Value(actionTitle),
        dateFrom = Value(dateFrom),
        dateTo = Value(dateTo);
  static Insertable<ZzaAction> custom({
    Expression<int>? id,
    Expression<String>? actionTitle,
    Expression<String>? actionDescription,
    Expression<DateTime>? dateFrom,
    Expression<DateTime>? dateTo,
    Expression<String>? homeDirectory,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionTitle != null) 'action_title': actionTitle,
      if (actionDescription != null) 'action_description': actionDescription,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (homeDirectory != null) 'home_directory': homeDirectory,
    });
  }

  ZzaActionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? actionTitle,
      Value<String?>? actionDescription,
      Value<DateTime>? dateFrom,
      Value<DateTime>? dateTo,
      Value<String?>? homeDirectory}) {
    return ZzaActionsCompanion(
      id: id ?? this.id,
      actionTitle: actionTitle ?? this.actionTitle,
      actionDescription: actionDescription ?? this.actionDescription,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      homeDirectory: homeDirectory ?? this.homeDirectory,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionTitle.present) {
      map['action_title'] = Variable<String>(actionTitle.value);
    }
    if (actionDescription.present) {
      map['action_description'] = Variable<String>(actionDescription.value);
    }
    if (dateFrom.present) {
      map['date_from'] = Variable<DateTime>(dateFrom.value);
    }
    if (dateTo.present) {
      map['date_to'] = Variable<DateTime>(dateTo.value);
    }
    if (homeDirectory.present) {
      map['home_directory'] = Variable<String>(homeDirectory.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZzaActionsCompanion(')
          ..write('id: $id, ')
          ..write('actionTitle: $actionTitle, ')
          ..write('actionDescription: $actionDescription, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('homeDirectory: $homeDirectory')
          ..write(')'))
        .toString();
  }
}

class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, Participant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<int> gender = GeneratedColumn<int>(
      'gender', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _birthNumberMeta =
      const VerificationMeta('birthNumber');
  @override
  late final GeneratedColumn<String> birthNumber = GeneratedColumn<String>(
      'birth_number', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 15),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _parentPhoneNumberMeta =
      const VerificationMeta('parentPhoneNumber');
  @override
  late final GeneratedColumn<String> parentPhoneNumber =
      GeneratedColumn<String>('parent_phone_number', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 0, maxTextLength: 13),
          type: DriftSqlType.string,
          requiredDuringInsert: false);
  static const VerificationMeta _eligibleConfirmationMeta =
      const VerificationMeta('eligibleConfirmation');
  @override
  late final GeneratedColumn<bool> eligibleConfirmation = GeneratedColumn<bool>(
      'eligible_confirmation', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("eligible_confirmation" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nonInfectiousConfirmationMeta =
      const VerificationMeta('nonInfectiousConfirmation');
  @override
  late final GeneratedColumn<bool> nonInfectiousConfirmation =
      GeneratedColumn<bool>('non_infectious_confirmation', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("non_infectious_confirmation" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _wasPrintedMeta =
      const VerificationMeta('wasPrinted');
  @override
  late final GeneratedColumn<bool> wasPrinted = GeneratedColumn<bool>(
      'was_printed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("was_printed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _parentNameMeta =
      const VerificationMeta('parentName');
  @override
  late final GeneratedColumn<String> parentName = GeneratedColumn<String>(
      'parent_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _parentEmailMeta =
      const VerificationMeta('parentEmail');
  @override
  late final GeneratedColumn<String> parentEmail = GeneratedColumn<String>(
      'parent_email', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _campUnitMeta =
      const VerificationMeta('campUnit');
  @override
  late final GeneratedColumn<String> campUnit = GeneratedColumn<String>(
      'camp_unit', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _arrivedConfirmationMeta =
      const VerificationMeta('arrivedConfirmation');
  @override
  late final GeneratedColumn<bool> arrivedConfirmation = GeneratedColumn<bool>(
      'arrived_confirmation', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("arrived_confirmation" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _eligibleConfirmationPathMeta =
      const VerificationMeta('eligibleConfirmationPath');
  @override
  late final GeneratedColumn<String> eligibleConfirmationPath =
      GeneratedColumn<String>('eligible_confirmation_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _insuranceCompanyFKMeta =
      const VerificationMeta('insuranceCompanyFK');
  @override
  late final GeneratedColumn<int> insuranceCompanyFK = GeneratedColumn<int>(
      'insurance_company_f_k', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES insurance_companies (id)'));
  static const VerificationMeta _zzaActionFKMeta =
      const VerificationMeta('zzaActionFK');
  @override
  late final GeneratedColumn<int> zzaActionFK = GeneratedColumn<int>(
      'zza_action_f_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES zza_actions (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        firstName,
        lastName,
        gender,
        address,
        birthNumber,
        birthDate,
        parentPhoneNumber,
        eligibleConfirmation,
        nonInfectiousConfirmation,
        wasPrinted,
        parentName,
        parentEmail,
        campUnit,
        note,
        arrivedConfirmation,
        eligibleConfirmationPath,
        insuranceCompanyFK,
        zzaActionFK
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(Insertable<Participant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('birth_number')) {
      context.handle(
          _birthNumberMeta,
          birthNumber.isAcceptableOrUnknown(
              data['birth_number']!, _birthNumberMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('parent_phone_number')) {
      context.handle(
          _parentPhoneNumberMeta,
          parentPhoneNumber.isAcceptableOrUnknown(
              data['parent_phone_number']!, _parentPhoneNumberMeta));
    }
    if (data.containsKey('eligible_confirmation')) {
      context.handle(
          _eligibleConfirmationMeta,
          eligibleConfirmation.isAcceptableOrUnknown(
              data['eligible_confirmation']!, _eligibleConfirmationMeta));
    }
    if (data.containsKey('non_infectious_confirmation')) {
      context.handle(
          _nonInfectiousConfirmationMeta,
          nonInfectiousConfirmation.isAcceptableOrUnknown(
              data['non_infectious_confirmation']!,
              _nonInfectiousConfirmationMeta));
    }
    if (data.containsKey('was_printed')) {
      context.handle(
          _wasPrintedMeta,
          wasPrinted.isAcceptableOrUnknown(
              data['was_printed']!, _wasPrintedMeta));
    }
    if (data.containsKey('parent_name')) {
      context.handle(
          _parentNameMeta,
          parentName.isAcceptableOrUnknown(
              data['parent_name']!, _parentNameMeta));
    }
    if (data.containsKey('parent_email')) {
      context.handle(
          _parentEmailMeta,
          parentEmail.isAcceptableOrUnknown(
              data['parent_email']!, _parentEmailMeta));
    }
    if (data.containsKey('camp_unit')) {
      context.handle(_campUnitMeta,
          campUnit.isAcceptableOrUnknown(data['camp_unit']!, _campUnitMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('arrived_confirmation')) {
      context.handle(
          _arrivedConfirmationMeta,
          arrivedConfirmation.isAcceptableOrUnknown(
              data['arrived_confirmation']!, _arrivedConfirmationMeta));
    }
    if (data.containsKey('eligible_confirmation_path')) {
      context.handle(
          _eligibleConfirmationPathMeta,
          eligibleConfirmationPath.isAcceptableOrUnknown(
              data['eligible_confirmation_path']!,
              _eligibleConfirmationPathMeta));
    }
    if (data.containsKey('insurance_company_f_k')) {
      context.handle(
          _insuranceCompanyFKMeta,
          insuranceCompanyFK.isAcceptableOrUnknown(
              data['insurance_company_f_k']!, _insuranceCompanyFKMeta));
    }
    if (data.containsKey('zza_action_f_k')) {
      context.handle(
          _zzaActionFKMeta,
          zzaActionFK.isAcceptableOrUnknown(
              data['zza_action_f_k']!, _zzaActionFKMeta));
    } else if (isInserting) {
      context.missing(_zzaActionFKMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Participant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Participant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gender']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      birthNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_number']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      parentPhoneNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_phone_number']),
      eligibleConfirmation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}eligible_confirmation'])!,
      nonInfectiousConfirmation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}non_infectious_confirmation'])!,
      wasPrinted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_printed'])!,
      parentName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_name']),
      parentEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_email']),
      campUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}camp_unit']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      arrivedConfirmation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}arrived_confirmation'])!,
      eligibleConfirmationPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}eligible_confirmation_path']),
      insuranceCompanyFK: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}insurance_company_f_k']),
      zzaActionFK: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}zza_action_f_k'])!,
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class Participant extends DataClass implements Insertable<Participant> {
  final int id;
  final String firstName;
  final String lastName;
  final int? gender;
  final String? address;
  final String? birthNumber;
  final DateTime? birthDate;
  final String? parentPhoneNumber;
  final bool eligibleConfirmation;
  final bool nonInfectiousConfirmation;
  final bool wasPrinted;
  final String? parentName;
  final String? parentEmail;
  final String? campUnit;
  final String? note;
  final bool arrivedConfirmation;
  final String? eligibleConfirmationPath;
  final int? insuranceCompanyFK;
  final int zzaActionFK;
  const Participant(
      {required this.id,
      required this.firstName,
      required this.lastName,
      this.gender,
      this.address,
      this.birthNumber,
      this.birthDate,
      this.parentPhoneNumber,
      required this.eligibleConfirmation,
      required this.nonInfectiousConfirmation,
      required this.wasPrinted,
      this.parentName,
      this.parentEmail,
      this.campUnit,
      this.note,
      required this.arrivedConfirmation,
      this.eligibleConfirmationPath,
      this.insuranceCompanyFK,
      required this.zzaActionFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<int>(gender);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || birthNumber != null) {
      map['birth_number'] = Variable<String>(birthNumber);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || parentPhoneNumber != null) {
      map['parent_phone_number'] = Variable<String>(parentPhoneNumber);
    }
    map['eligible_confirmation'] = Variable<bool>(eligibleConfirmation);
    map['non_infectious_confirmation'] =
        Variable<bool>(nonInfectiousConfirmation);
    map['was_printed'] = Variable<bool>(wasPrinted);
    if (!nullToAbsent || parentName != null) {
      map['parent_name'] = Variable<String>(parentName);
    }
    if (!nullToAbsent || parentEmail != null) {
      map['parent_email'] = Variable<String>(parentEmail);
    }
    if (!nullToAbsent || campUnit != null) {
      map['camp_unit'] = Variable<String>(campUnit);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['arrived_confirmation'] = Variable<bool>(arrivedConfirmation);
    if (!nullToAbsent || eligibleConfirmationPath != null) {
      map['eligible_confirmation_path'] =
          Variable<String>(eligibleConfirmationPath);
    }
    if (!nullToAbsent || insuranceCompanyFK != null) {
      map['insurance_company_f_k'] = Variable<int>(insuranceCompanyFK);
    }
    map['zza_action_f_k'] = Variable<int>(zzaActionFK);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      birthNumber: birthNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(birthNumber),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      parentPhoneNumber: parentPhoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(parentPhoneNumber),
      eligibleConfirmation: Value(eligibleConfirmation),
      nonInfectiousConfirmation: Value(nonInfectiousConfirmation),
      wasPrinted: Value(wasPrinted),
      parentName: parentName == null && nullToAbsent
          ? const Value.absent()
          : Value(parentName),
      parentEmail: parentEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(parentEmail),
      campUnit: campUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(campUnit),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      arrivedConfirmation: Value(arrivedConfirmation),
      eligibleConfirmationPath: eligibleConfirmationPath == null && nullToAbsent
          ? const Value.absent()
          : Value(eligibleConfirmationPath),
      insuranceCompanyFK: insuranceCompanyFK == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceCompanyFK),
      zzaActionFK: Value(zzaActionFK),
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Participant(
      id: serializer.fromJson<int>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      gender: serializer.fromJson<int?>(json['gender']),
      address: serializer.fromJson<String?>(json['address']),
      birthNumber: serializer.fromJson<String?>(json['birthNumber']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      parentPhoneNumber:
          serializer.fromJson<String?>(json['parentPhoneNumber']),
      eligibleConfirmation:
          serializer.fromJson<bool>(json['eligibleConfirmation']),
      nonInfectiousConfirmation:
          serializer.fromJson<bool>(json['nonInfectiousConfirmation']),
      wasPrinted: serializer.fromJson<bool>(json['wasPrinted']),
      parentName: serializer.fromJson<String?>(json['parentName']),
      parentEmail: serializer.fromJson<String?>(json['parentEmail']),
      campUnit: serializer.fromJson<String?>(json['campUnit']),
      note: serializer.fromJson<String?>(json['note']),
      arrivedConfirmation:
          serializer.fromJson<bool>(json['arrivedConfirmation']),
      eligibleConfirmationPath:
          serializer.fromJson<String?>(json['eligibleConfirmationPath']),
      insuranceCompanyFK: serializer.fromJson<int?>(json['insuranceCompanyFK']),
      zzaActionFK: serializer.fromJson<int>(json['zzaActionFK']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'gender': serializer.toJson<int?>(gender),
      'address': serializer.toJson<String?>(address),
      'birthNumber': serializer.toJson<String?>(birthNumber),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'parentPhoneNumber': serializer.toJson<String?>(parentPhoneNumber),
      'eligibleConfirmation': serializer.toJson<bool>(eligibleConfirmation),
      'nonInfectiousConfirmation':
          serializer.toJson<bool>(nonInfectiousConfirmation),
      'wasPrinted': serializer.toJson<bool>(wasPrinted),
      'parentName': serializer.toJson<String?>(parentName),
      'parentEmail': serializer.toJson<String?>(parentEmail),
      'campUnit': serializer.toJson<String?>(campUnit),
      'note': serializer.toJson<String?>(note),
      'arrivedConfirmation': serializer.toJson<bool>(arrivedConfirmation),
      'eligibleConfirmationPath':
          serializer.toJson<String?>(eligibleConfirmationPath),
      'insuranceCompanyFK': serializer.toJson<int?>(insuranceCompanyFK),
      'zzaActionFK': serializer.toJson<int>(zzaActionFK),
    };
  }

  Participant copyWith(
          {int? id,
          String? firstName,
          String? lastName,
          Value<int?> gender = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> birthNumber = const Value.absent(),
          Value<DateTime?> birthDate = const Value.absent(),
          Value<String?> parentPhoneNumber = const Value.absent(),
          bool? eligibleConfirmation,
          bool? nonInfectiousConfirmation,
          bool? wasPrinted,
          Value<String?> parentName = const Value.absent(),
          Value<String?> parentEmail = const Value.absent(),
          Value<String?> campUnit = const Value.absent(),
          Value<String?> note = const Value.absent(),
          bool? arrivedConfirmation,
          Value<String?> eligibleConfirmationPath = const Value.absent(),
          Value<int?> insuranceCompanyFK = const Value.absent(),
          int? zzaActionFK}) =>
      Participant(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        gender: gender.present ? gender.value : this.gender,
        address: address.present ? address.value : this.address,
        birthNumber: birthNumber.present ? birthNumber.value : this.birthNumber,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        parentPhoneNumber: parentPhoneNumber.present
            ? parentPhoneNumber.value
            : this.parentPhoneNumber,
        eligibleConfirmation: eligibleConfirmation ?? this.eligibleConfirmation,
        nonInfectiousConfirmation:
            nonInfectiousConfirmation ?? this.nonInfectiousConfirmation,
        wasPrinted: wasPrinted ?? this.wasPrinted,
        parentName: parentName.present ? parentName.value : this.parentName,
        parentEmail: parentEmail.present ? parentEmail.value : this.parentEmail,
        campUnit: campUnit.present ? campUnit.value : this.campUnit,
        note: note.present ? note.value : this.note,
        arrivedConfirmation: arrivedConfirmation ?? this.arrivedConfirmation,
        eligibleConfirmationPath: eligibleConfirmationPath.present
            ? eligibleConfirmationPath.value
            : this.eligibleConfirmationPath,
        insuranceCompanyFK: insuranceCompanyFK.present
            ? insuranceCompanyFK.value
            : this.insuranceCompanyFK,
        zzaActionFK: zzaActionFK ?? this.zzaActionFK,
      );
  Participant copyWithCompanion(ParticipantsCompanion data) {
    return Participant(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      gender: data.gender.present ? data.gender.value : this.gender,
      address: data.address.present ? data.address.value : this.address,
      birthNumber:
          data.birthNumber.present ? data.birthNumber.value : this.birthNumber,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      parentPhoneNumber: data.parentPhoneNumber.present
          ? data.parentPhoneNumber.value
          : this.parentPhoneNumber,
      eligibleConfirmation: data.eligibleConfirmation.present
          ? data.eligibleConfirmation.value
          : this.eligibleConfirmation,
      nonInfectiousConfirmation: data.nonInfectiousConfirmation.present
          ? data.nonInfectiousConfirmation.value
          : this.nonInfectiousConfirmation,
      wasPrinted:
          data.wasPrinted.present ? data.wasPrinted.value : this.wasPrinted,
      parentName:
          data.parentName.present ? data.parentName.value : this.parentName,
      parentEmail:
          data.parentEmail.present ? data.parentEmail.value : this.parentEmail,
      campUnit: data.campUnit.present ? data.campUnit.value : this.campUnit,
      note: data.note.present ? data.note.value : this.note,
      arrivedConfirmation: data.arrivedConfirmation.present
          ? data.arrivedConfirmation.value
          : this.arrivedConfirmation,
      eligibleConfirmationPath: data.eligibleConfirmationPath.present
          ? data.eligibleConfirmationPath.value
          : this.eligibleConfirmationPath,
      insuranceCompanyFK: data.insuranceCompanyFK.present
          ? data.insuranceCompanyFK.value
          : this.insuranceCompanyFK,
      zzaActionFK:
          data.zzaActionFK.present ? data.zzaActionFK.value : this.zzaActionFK,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('address: $address, ')
          ..write('birthNumber: $birthNumber, ')
          ..write('birthDate: $birthDate, ')
          ..write('parentPhoneNumber: $parentPhoneNumber, ')
          ..write('eligibleConfirmation: $eligibleConfirmation, ')
          ..write('nonInfectiousConfirmation: $nonInfectiousConfirmation, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('parentName: $parentName, ')
          ..write('parentEmail: $parentEmail, ')
          ..write('campUnit: $campUnit, ')
          ..write('note: $note, ')
          ..write('arrivedConfirmation: $arrivedConfirmation, ')
          ..write('eligibleConfirmationPath: $eligibleConfirmationPath, ')
          ..write('insuranceCompanyFK: $insuranceCompanyFK, ')
          ..write('zzaActionFK: $zzaActionFK')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      firstName,
      lastName,
      gender,
      address,
      birthNumber,
      birthDate,
      parentPhoneNumber,
      eligibleConfirmation,
      nonInfectiousConfirmation,
      wasPrinted,
      parentName,
      parentEmail,
      campUnit,
      note,
      arrivedConfirmation,
      eligibleConfirmationPath,
      insuranceCompanyFK,
      zzaActionFK);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.gender == this.gender &&
          other.address == this.address &&
          other.birthNumber == this.birthNumber &&
          other.birthDate == this.birthDate &&
          other.parentPhoneNumber == this.parentPhoneNumber &&
          other.eligibleConfirmation == this.eligibleConfirmation &&
          other.nonInfectiousConfirmation == this.nonInfectiousConfirmation &&
          other.wasPrinted == this.wasPrinted &&
          other.parentName == this.parentName &&
          other.parentEmail == this.parentEmail &&
          other.campUnit == this.campUnit &&
          other.note == this.note &&
          other.arrivedConfirmation == this.arrivedConfirmation &&
          other.eligibleConfirmationPath == this.eligibleConfirmationPath &&
          other.insuranceCompanyFK == this.insuranceCompanyFK &&
          other.zzaActionFK == this.zzaActionFK);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<int?> gender;
  final Value<String?> address;
  final Value<String?> birthNumber;
  final Value<DateTime?> birthDate;
  final Value<String?> parentPhoneNumber;
  final Value<bool> eligibleConfirmation;
  final Value<bool> nonInfectiousConfirmation;
  final Value<bool> wasPrinted;
  final Value<String?> parentName;
  final Value<String?> parentEmail;
  final Value<String?> campUnit;
  final Value<String?> note;
  final Value<bool> arrivedConfirmation;
  final Value<String?> eligibleConfirmationPath;
  final Value<int?> insuranceCompanyFK;
  final Value<int> zzaActionFK;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.gender = const Value.absent(),
    this.address = const Value.absent(),
    this.birthNumber = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.parentPhoneNumber = const Value.absent(),
    this.eligibleConfirmation = const Value.absent(),
    this.nonInfectiousConfirmation = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentEmail = const Value.absent(),
    this.campUnit = const Value.absent(),
    this.note = const Value.absent(),
    this.arrivedConfirmation = const Value.absent(),
    this.eligibleConfirmationPath = const Value.absent(),
    this.insuranceCompanyFK = const Value.absent(),
    this.zzaActionFK = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    required String lastName,
    this.gender = const Value.absent(),
    this.address = const Value.absent(),
    this.birthNumber = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.parentPhoneNumber = const Value.absent(),
    this.eligibleConfirmation = const Value.absent(),
    this.nonInfectiousConfirmation = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentEmail = const Value.absent(),
    this.campUnit = const Value.absent(),
    this.note = const Value.absent(),
    this.arrivedConfirmation = const Value.absent(),
    this.eligibleConfirmationPath = const Value.absent(),
    this.insuranceCompanyFK = const Value.absent(),
    required int zzaActionFK,
  })  : firstName = Value(firstName),
        lastName = Value(lastName),
        zzaActionFK = Value(zzaActionFK);
  static Insertable<Participant> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<int>? gender,
    Expression<String>? address,
    Expression<String>? birthNumber,
    Expression<DateTime>? birthDate,
    Expression<String>? parentPhoneNumber,
    Expression<bool>? eligibleConfirmation,
    Expression<bool>? nonInfectiousConfirmation,
    Expression<bool>? wasPrinted,
    Expression<String>? parentName,
    Expression<String>? parentEmail,
    Expression<String>? campUnit,
    Expression<String>? note,
    Expression<bool>? arrivedConfirmation,
    Expression<String>? eligibleConfirmationPath,
    Expression<int>? insuranceCompanyFK,
    Expression<int>? zzaActionFK,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (birthNumber != null) 'birth_number': birthNumber,
      if (birthDate != null) 'birth_date': birthDate,
      if (parentPhoneNumber != null) 'parent_phone_number': parentPhoneNumber,
      if (eligibleConfirmation != null)
        'eligible_confirmation': eligibleConfirmation,
      if (nonInfectiousConfirmation != null)
        'non_infectious_confirmation': nonInfectiousConfirmation,
      if (wasPrinted != null) 'was_printed': wasPrinted,
      if (parentName != null) 'parent_name': parentName,
      if (parentEmail != null) 'parent_email': parentEmail,
      if (campUnit != null) 'camp_unit': campUnit,
      if (note != null) 'note': note,
      if (arrivedConfirmation != null)
        'arrived_confirmation': arrivedConfirmation,
      if (eligibleConfirmationPath != null)
        'eligible_confirmation_path': eligibleConfirmationPath,
      if (insuranceCompanyFK != null)
        'insurance_company_f_k': insuranceCompanyFK,
      if (zzaActionFK != null) 'zza_action_f_k': zzaActionFK,
    });
  }

  ParticipantsCompanion copyWith(
      {Value<int>? id,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<int?>? gender,
      Value<String?>? address,
      Value<String?>? birthNumber,
      Value<DateTime?>? birthDate,
      Value<String?>? parentPhoneNumber,
      Value<bool>? eligibleConfirmation,
      Value<bool>? nonInfectiousConfirmation,
      Value<bool>? wasPrinted,
      Value<String?>? parentName,
      Value<String?>? parentEmail,
      Value<String?>? campUnit,
      Value<String?>? note,
      Value<bool>? arrivedConfirmation,
      Value<String?>? eligibleConfirmationPath,
      Value<int?>? insuranceCompanyFK,
      Value<int>? zzaActionFK}) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      birthNumber: birthNumber ?? this.birthNumber,
      birthDate: birthDate ?? this.birthDate,
      parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
      eligibleConfirmation: eligibleConfirmation ?? this.eligibleConfirmation,
      nonInfectiousConfirmation:
          nonInfectiousConfirmation ?? this.nonInfectiousConfirmation,
      wasPrinted: wasPrinted ?? this.wasPrinted,
      parentName: parentName ?? this.parentName,
      parentEmail: parentEmail ?? this.parentEmail,
      campUnit: campUnit ?? this.campUnit,
      note: note ?? this.note,
      arrivedConfirmation: arrivedConfirmation ?? this.arrivedConfirmation,
      eligibleConfirmationPath:
          eligibleConfirmationPath ?? this.eligibleConfirmationPath,
      insuranceCompanyFK: insuranceCompanyFK ?? this.insuranceCompanyFK,
      zzaActionFK: zzaActionFK ?? this.zzaActionFK,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<int>(gender.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (birthNumber.present) {
      map['birth_number'] = Variable<String>(birthNumber.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (parentPhoneNumber.present) {
      map['parent_phone_number'] = Variable<String>(parentPhoneNumber.value);
    }
    if (eligibleConfirmation.present) {
      map['eligible_confirmation'] = Variable<bool>(eligibleConfirmation.value);
    }
    if (nonInfectiousConfirmation.present) {
      map['non_infectious_confirmation'] =
          Variable<bool>(nonInfectiousConfirmation.value);
    }
    if (wasPrinted.present) {
      map['was_printed'] = Variable<bool>(wasPrinted.value);
    }
    if (parentName.present) {
      map['parent_name'] = Variable<String>(parentName.value);
    }
    if (parentEmail.present) {
      map['parent_email'] = Variable<String>(parentEmail.value);
    }
    if (campUnit.present) {
      map['camp_unit'] = Variable<String>(campUnit.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (arrivedConfirmation.present) {
      map['arrived_confirmation'] = Variable<bool>(arrivedConfirmation.value);
    }
    if (eligibleConfirmationPath.present) {
      map['eligible_confirmation_path'] =
          Variable<String>(eligibleConfirmationPath.value);
    }
    if (insuranceCompanyFK.present) {
      map['insurance_company_f_k'] = Variable<int>(insuranceCompanyFK.value);
    }
    if (zzaActionFK.present) {
      map['zza_action_f_k'] = Variable<int>(zzaActionFK.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('address: $address, ')
          ..write('birthNumber: $birthNumber, ')
          ..write('birthDate: $birthDate, ')
          ..write('parentPhoneNumber: $parentPhoneNumber, ')
          ..write('eligibleConfirmation: $eligibleConfirmation, ')
          ..write('nonInfectiousConfirmation: $nonInfectiousConfirmation, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('parentName: $parentName, ')
          ..write('parentEmail: $parentEmail, ')
          ..write('campUnit: $campUnit, ')
          ..write('note: $note, ')
          ..write('arrivedConfirmation: $arrivedConfirmation, ')
          ..write('eligibleConfirmationPath: $eligibleConfirmationPath, ')
          ..write('insuranceCompanyFK: $insuranceCompanyFK, ')
          ..write('zzaActionFK: $zzaActionFK')
          ..write(')'))
        .toString();
  }
}

class $ParamedicsTable extends Paramedics
    with TableInfo<$ParamedicsTable, Paramedic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParamedicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 13),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, firstName, lastName, address, birthDate, phoneNumber, username];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paramedics';
  @override
  VerificationContext validateIntegrity(Insertable<Paramedic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Paramedic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Paramedic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
    );
  }

  @override
  $ParamedicsTable createAlias(String alias) {
    return $ParamedicsTable(attachedDatabase, alias);
  }
}

class Paramedic extends DataClass implements Insertable<Paramedic> {
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final DateTime birthDate;
  final String phoneNumber;
  final String username;
  const Paramedic(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.address,
      required this.birthDate,
      required this.phoneNumber,
      required this.username});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['address'] = Variable<String>(address);
    map['birth_date'] = Variable<DateTime>(birthDate);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['username'] = Variable<String>(username);
    return map;
  }

  ParamedicsCompanion toCompanion(bool nullToAbsent) {
    return ParamedicsCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      address: Value(address),
      birthDate: Value(birthDate),
      phoneNumber: Value(phoneNumber),
      username: Value(username),
    );
  }

  factory Paramedic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Paramedic(
      id: serializer.fromJson<int>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      address: serializer.fromJson<String>(json['address']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      username: serializer.fromJson<String>(json['username']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'address': serializer.toJson<String>(address),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'username': serializer.toJson<String>(username),
    };
  }

  Paramedic copyWith(
          {int? id,
          String? firstName,
          String? lastName,
          String? address,
          DateTime? birthDate,
          String? phoneNumber,
          String? username}) =>
      Paramedic(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        address: address ?? this.address,
        birthDate: birthDate ?? this.birthDate,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        username: username ?? this.username,
      );
  Paramedic copyWithCompanion(ParamedicsCompanion data) {
    return Paramedic(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      address: data.address.present ? data.address.value : this.address,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      username: data.username.present ? data.username.value : this.username,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Paramedic(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('birthDate: $birthDate, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('username: $username')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, firstName, lastName, address, birthDate, phoneNumber, username);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Paramedic &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.address == this.address &&
          other.birthDate == this.birthDate &&
          other.phoneNumber == this.phoneNumber &&
          other.username == this.username);
}

class ParamedicsCompanion extends UpdateCompanion<Paramedic> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> address;
  final Value<DateTime> birthDate;
  final Value<String> phoneNumber;
  final Value<String> username;
  const ParamedicsCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.username = const Value.absent(),
  });
  ParamedicsCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    required String lastName,
    required String address,
    required DateTime birthDate,
    required String phoneNumber,
    required String username,
  })  : firstName = Value(firstName),
        lastName = Value(lastName),
        address = Value(address),
        birthDate = Value(birthDate),
        phoneNumber = Value(phoneNumber),
        username = Value(username);
  static Insertable<Paramedic> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? address,
    Expression<DateTime>? birthDate,
    Expression<String>? phoneNumber,
    Expression<String>? username,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (birthDate != null) 'birth_date': birthDate,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (username != null) 'username': username,
    });
  }

  ParamedicsCompanion copyWith(
      {Value<int>? id,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<String>? address,
      Value<DateTime>? birthDate,
      Value<String>? phoneNumber,
      Value<String>? username}) {
    return ParamedicsCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParamedicsCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('birthDate: $birthDate, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('username: $username')
          ..write(')'))
        .toString();
  }
}

class $RecordsTable extends Records with TableInfo<$RecordsTable, Record> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateAndTimeMeta =
      const VerificationMeta('dateAndTime');
  @override
  late final GeneratedColumn<DateTime> dateAndTime = GeneratedColumn<DateTime>(
      'date_and_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 512),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _treatmentMeta =
      const VerificationMeta('treatment');
  @override
  late final GeneratedColumn<String> treatment = GeneratedColumn<String>(
      'treatment', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 512),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _wasPrintedMeta =
      const VerificationMeta('wasPrinted');
  @override
  late final GeneratedColumn<bool> wasPrinted = GeneratedColumn<bool>(
      'was_printed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("was_printed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _picturePathMeta =
      const VerificationMeta('picturePath');
  @override
  late final GeneratedColumn<String> picturePath = GeneratedColumn<String>(
      'picture_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paramedicFKMeta =
      const VerificationMeta('paramedicFK');
  @override
  late final GeneratedColumn<int> paramedicFK = GeneratedColumn<int>(
      'paramedic_f_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES paramedics (id)'));
  static const VerificationMeta _participantFKMeta =
      const VerificationMeta('participantFK');
  @override
  late final GeneratedColumn<int> participantFK = GeneratedColumn<int>(
      'participant_f_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES participants (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dateAndTime,
        title,
        description,
        treatment,
        wasPrinted,
        note,
        temperature,
        picturePath,
        paramedicFK,
        participantFK
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'records';
  @override
  VerificationContext validateIntegrity(Insertable<Record> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_and_time')) {
      context.handle(
          _dateAndTimeMeta,
          dateAndTime.isAcceptableOrUnknown(
              data['date_and_time']!, _dateAndTimeMeta));
    } else if (isInserting) {
      context.missing(_dateAndTimeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('treatment')) {
      context.handle(_treatmentMeta,
          treatment.isAcceptableOrUnknown(data['treatment']!, _treatmentMeta));
    }
    if (data.containsKey('was_printed')) {
      context.handle(
          _wasPrintedMeta,
          wasPrinted.isAcceptableOrUnknown(
              data['was_printed']!, _wasPrintedMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('picture_path')) {
      context.handle(
          _picturePathMeta,
          picturePath.isAcceptableOrUnknown(
              data['picture_path']!, _picturePathMeta));
    }
    if (data.containsKey('paramedic_f_k')) {
      context.handle(
          _paramedicFKMeta,
          paramedicFK.isAcceptableOrUnknown(
              data['paramedic_f_k']!, _paramedicFKMeta));
    } else if (isInserting) {
      context.missing(_paramedicFKMeta);
    }
    if (data.containsKey('participant_f_k')) {
      context.handle(
          _participantFKMeta,
          participantFK.isAcceptableOrUnknown(
              data['participant_f_k']!, _participantFKMeta));
    } else if (isInserting) {
      context.missing(_participantFKMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Record map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Record(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dateAndTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_and_time'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      treatment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}treatment']),
      wasPrinted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_printed'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature']),
      picturePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}picture_path']),
      paramedicFK: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paramedic_f_k'])!,
      participantFK: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_f_k'])!,
    );
  }

  @override
  $RecordsTable createAlias(String alias) {
    return $RecordsTable(attachedDatabase, alias);
  }
}

class Record extends DataClass implements Insertable<Record> {
  final int id;
  final DateTime dateAndTime;
  final String title;
  final String description;
  final String? treatment;
  final bool wasPrinted;
  final String? note;
  final double? temperature;
  final String? picturePath;
  final int paramedicFK;
  final int participantFK;
  const Record(
      {required this.id,
      required this.dateAndTime,
      required this.title,
      required this.description,
      this.treatment,
      required this.wasPrinted,
      this.note,
      this.temperature,
      this.picturePath,
      required this.paramedicFK,
      required this.participantFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_and_time'] = Variable<DateTime>(dateAndTime);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || treatment != null) {
      map['treatment'] = Variable<String>(treatment);
    }
    map['was_printed'] = Variable<bool>(wasPrinted);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || picturePath != null) {
      map['picture_path'] = Variable<String>(picturePath);
    }
    map['paramedic_f_k'] = Variable<int>(paramedicFK);
    map['participant_f_k'] = Variable<int>(participantFK);
    return map;
  }

  RecordsCompanion toCompanion(bool nullToAbsent) {
    return RecordsCompanion(
      id: Value(id),
      dateAndTime: Value(dateAndTime),
      title: Value(title),
      description: Value(description),
      treatment: treatment == null && nullToAbsent
          ? const Value.absent()
          : Value(treatment),
      wasPrinted: Value(wasPrinted),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      picturePath: picturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(picturePath),
      paramedicFK: Value(paramedicFK),
      participantFK: Value(participantFK),
    );
  }

  factory Record.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Record(
      id: serializer.fromJson<int>(json['id']),
      dateAndTime: serializer.fromJson<DateTime>(json['dateAndTime']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      treatment: serializer.fromJson<String?>(json['treatment']),
      wasPrinted: serializer.fromJson<bool>(json['wasPrinted']),
      note: serializer.fromJson<String?>(json['note']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      picturePath: serializer.fromJson<String?>(json['picturePath']),
      paramedicFK: serializer.fromJson<int>(json['paramedicFK']),
      participantFK: serializer.fromJson<int>(json['participantFK']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateAndTime': serializer.toJson<DateTime>(dateAndTime),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'treatment': serializer.toJson<String?>(treatment),
      'wasPrinted': serializer.toJson<bool>(wasPrinted),
      'note': serializer.toJson<String?>(note),
      'temperature': serializer.toJson<double?>(temperature),
      'picturePath': serializer.toJson<String?>(picturePath),
      'paramedicFK': serializer.toJson<int>(paramedicFK),
      'participantFK': serializer.toJson<int>(participantFK),
    };
  }

  Record copyWith(
          {int? id,
          DateTime? dateAndTime,
          String? title,
          String? description,
          Value<String?> treatment = const Value.absent(),
          bool? wasPrinted,
          Value<String?> note = const Value.absent(),
          Value<double?> temperature = const Value.absent(),
          Value<String?> picturePath = const Value.absent(),
          int? paramedicFK,
          int? participantFK}) =>
      Record(
        id: id ?? this.id,
        dateAndTime: dateAndTime ?? this.dateAndTime,
        title: title ?? this.title,
        description: description ?? this.description,
        treatment: treatment.present ? treatment.value : this.treatment,
        wasPrinted: wasPrinted ?? this.wasPrinted,
        note: note.present ? note.value : this.note,
        temperature: temperature.present ? temperature.value : this.temperature,
        picturePath: picturePath.present ? picturePath.value : this.picturePath,
        paramedicFK: paramedicFK ?? this.paramedicFK,
        participantFK: participantFK ?? this.participantFK,
      );
  Record copyWithCompanion(RecordsCompanion data) {
    return Record(
      id: data.id.present ? data.id.value : this.id,
      dateAndTime:
          data.dateAndTime.present ? data.dateAndTime.value : this.dateAndTime,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      treatment: data.treatment.present ? data.treatment.value : this.treatment,
      wasPrinted:
          data.wasPrinted.present ? data.wasPrinted.value : this.wasPrinted,
      note: data.note.present ? data.note.value : this.note,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      picturePath:
          data.picturePath.present ? data.picturePath.value : this.picturePath,
      paramedicFK:
          data.paramedicFK.present ? data.paramedicFK.value : this.paramedicFK,
      participantFK: data.participantFK.present
          ? data.participantFK.value
          : this.participantFK,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Record(')
          ..write('id: $id, ')
          ..write('dateAndTime: $dateAndTime, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('treatment: $treatment, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('note: $note, ')
          ..write('temperature: $temperature, ')
          ..write('picturePath: $picturePath, ')
          ..write('paramedicFK: $paramedicFK, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dateAndTime,
      title,
      description,
      treatment,
      wasPrinted,
      note,
      temperature,
      picturePath,
      paramedicFK,
      participantFK);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Record &&
          other.id == this.id &&
          other.dateAndTime == this.dateAndTime &&
          other.title == this.title &&
          other.description == this.description &&
          other.treatment == this.treatment &&
          other.wasPrinted == this.wasPrinted &&
          other.note == this.note &&
          other.temperature == this.temperature &&
          other.picturePath == this.picturePath &&
          other.paramedicFK == this.paramedicFK &&
          other.participantFK == this.participantFK);
}

class RecordsCompanion extends UpdateCompanion<Record> {
  final Value<int> id;
  final Value<DateTime> dateAndTime;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> treatment;
  final Value<bool> wasPrinted;
  final Value<String?> note;
  final Value<double?> temperature;
  final Value<String?> picturePath;
  final Value<int> paramedicFK;
  final Value<int> participantFK;
  const RecordsCompanion({
    this.id = const Value.absent(),
    this.dateAndTime = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.treatment = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.note = const Value.absent(),
    this.temperature = const Value.absent(),
    this.picturePath = const Value.absent(),
    this.paramedicFK = const Value.absent(),
    this.participantFK = const Value.absent(),
  });
  RecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime dateAndTime,
    required String title,
    required String description,
    this.treatment = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.note = const Value.absent(),
    this.temperature = const Value.absent(),
    this.picturePath = const Value.absent(),
    required int paramedicFK,
    required int participantFK,
  })  : dateAndTime = Value(dateAndTime),
        title = Value(title),
        description = Value(description),
        paramedicFK = Value(paramedicFK),
        participantFK = Value(participantFK);
  static Insertable<Record> custom({
    Expression<int>? id,
    Expression<DateTime>? dateAndTime,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? treatment,
    Expression<bool>? wasPrinted,
    Expression<String>? note,
    Expression<double>? temperature,
    Expression<String>? picturePath,
    Expression<int>? paramedicFK,
    Expression<int>? participantFK,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateAndTime != null) 'date_and_time': dateAndTime,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (treatment != null) 'treatment': treatment,
      if (wasPrinted != null) 'was_printed': wasPrinted,
      if (note != null) 'note': note,
      if (temperature != null) 'temperature': temperature,
      if (picturePath != null) 'picture_path': picturePath,
      if (paramedicFK != null) 'paramedic_f_k': paramedicFK,
      if (participantFK != null) 'participant_f_k': participantFK,
    });
  }

  RecordsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? dateAndTime,
      Value<String>? title,
      Value<String>? description,
      Value<String?>? treatment,
      Value<bool>? wasPrinted,
      Value<String?>? note,
      Value<double?>? temperature,
      Value<String?>? picturePath,
      Value<int>? paramedicFK,
      Value<int>? participantFK}) {
    return RecordsCompanion(
      id: id ?? this.id,
      dateAndTime: dateAndTime ?? this.dateAndTime,
      title: title ?? this.title,
      description: description ?? this.description,
      treatment: treatment ?? this.treatment,
      wasPrinted: wasPrinted ?? this.wasPrinted,
      note: note ?? this.note,
      temperature: temperature ?? this.temperature,
      picturePath: picturePath ?? this.picturePath,
      paramedicFK: paramedicFK ?? this.paramedicFK,
      participantFK: participantFK ?? this.participantFK,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateAndTime.present) {
      map['date_and_time'] = Variable<DateTime>(dateAndTime.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (treatment.present) {
      map['treatment'] = Variable<String>(treatment.value);
    }
    if (wasPrinted.present) {
      map['was_printed'] = Variable<bool>(wasPrinted.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (picturePath.present) {
      map['picture_path'] = Variable<String>(picturePath.value);
    }
    if (paramedicFK.present) {
      map['paramedic_f_k'] = Variable<int>(paramedicFK.value);
    }
    if (participantFK.present) {
      map['participant_f_k'] = Variable<int>(participantFK.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordsCompanion(')
          ..write('id: $id, ')
          ..write('dateAndTime: $dateAndTime, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('treatment: $treatment, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('note: $note, ')
          ..write('temperature: $temperature, ')
          ..write('picturePath: $picturePath, ')
          ..write('paramedicFK: $paramedicFK, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }
}

class $AllergiesLimitationsTable extends AllergiesLimitations
    with TableInfo<$AllergiesLimitationsTable, AllergiesLimitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllergiesLimitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wasPrintedMeta =
      const VerificationMeta('wasPrinted');
  @override
  late final GeneratedColumn<bool> wasPrinted = GeneratedColumn<bool>(
      'was_printed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("was_printed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _participantFKMeta =
      const VerificationMeta('participantFK');
  @override
  late final GeneratedColumn<int> participantFK = GeneratedColumn<int>(
      'participant_f_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES participants (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, description, type, wasPrinted, participantFK];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allergies_limitations';
  @override
  VerificationContext validateIntegrity(
      Insertable<AllergiesLimitation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('was_printed')) {
      context.handle(
          _wasPrintedMeta,
          wasPrinted.isAcceptableOrUnknown(
              data['was_printed']!, _wasPrintedMeta));
    }
    if (data.containsKey('participant_f_k')) {
      context.handle(
          _participantFKMeta,
          participantFK.isAcceptableOrUnknown(
              data['participant_f_k']!, _participantFKMeta));
    } else if (isInserting) {
      context.missing(_participantFKMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AllergiesLimitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllergiesLimitation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      wasPrinted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_printed'])!,
      participantFK: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_f_k'])!,
    );
  }

  @override
  $AllergiesLimitationsTable createAlias(String alias) {
    return $AllergiesLimitationsTable(attachedDatabase, alias);
  }
}

class AllergiesLimitation extends DataClass
    implements Insertable<AllergiesLimitation> {
  final int id;
  final String description;
  final int type;
  final bool wasPrinted;
  final int participantFK;
  const AllergiesLimitation(
      {required this.id,
      required this.description,
      required this.type,
      required this.wasPrinted,
      required this.participantFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<int>(type);
    map['was_printed'] = Variable<bool>(wasPrinted);
    map['participant_f_k'] = Variable<int>(participantFK);
    return map;
  }

  AllergiesLimitationsCompanion toCompanion(bool nullToAbsent) {
    return AllergiesLimitationsCompanion(
      id: Value(id),
      description: Value(description),
      type: Value(type),
      wasPrinted: Value(wasPrinted),
      participantFK: Value(participantFK),
    );
  }

  factory AllergiesLimitation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllergiesLimitation(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<int>(json['type']),
      wasPrinted: serializer.fromJson<bool>(json['wasPrinted']),
      participantFK: serializer.fromJson<int>(json['participantFK']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<int>(type),
      'wasPrinted': serializer.toJson<bool>(wasPrinted),
      'participantFK': serializer.toJson<int>(participantFK),
    };
  }

  AllergiesLimitation copyWith(
          {int? id,
          String? description,
          int? type,
          bool? wasPrinted,
          int? participantFK}) =>
      AllergiesLimitation(
        id: id ?? this.id,
        description: description ?? this.description,
        type: type ?? this.type,
        wasPrinted: wasPrinted ?? this.wasPrinted,
        participantFK: participantFK ?? this.participantFK,
      );
  AllergiesLimitation copyWithCompanion(AllergiesLimitationsCompanion data) {
    return AllergiesLimitation(
      id: data.id.present ? data.id.value : this.id,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      wasPrinted:
          data.wasPrinted.present ? data.wasPrinted.value : this.wasPrinted,
      participantFK: data.participantFK.present
          ? data.participantFK.value
          : this.participantFK,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllergiesLimitation(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, description, type, wasPrinted, participantFK);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllergiesLimitation &&
          other.id == this.id &&
          other.description == this.description &&
          other.type == this.type &&
          other.wasPrinted == this.wasPrinted &&
          other.participantFK == this.participantFK);
}

class AllergiesLimitationsCompanion
    extends UpdateCompanion<AllergiesLimitation> {
  final Value<int> id;
  final Value<String> description;
  final Value<int> type;
  final Value<bool> wasPrinted;
  final Value<int> participantFK;
  const AllergiesLimitationsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.participantFK = const Value.absent(),
  });
  AllergiesLimitationsCompanion.insert({
    this.id = const Value.absent(),
    required String description,
    required int type,
    this.wasPrinted = const Value.absent(),
    required int participantFK,
  })  : description = Value(description),
        type = Value(type),
        participantFK = Value(participantFK);
  static Insertable<AllergiesLimitation> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<int>? type,
    Expression<bool>? wasPrinted,
    Expression<int>? participantFK,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (wasPrinted != null) 'was_printed': wasPrinted,
      if (participantFK != null) 'participant_f_k': participantFK,
    });
  }

  AllergiesLimitationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? description,
      Value<int>? type,
      Value<bool>? wasPrinted,
      Value<int>? participantFK}) {
    return AllergiesLimitationsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      wasPrinted: wasPrinted ?? this.wasPrinted,
      participantFK: participantFK ?? this.participantFK,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (wasPrinted.present) {
      map['was_printed'] = Variable<bool>(wasPrinted.value);
    }
    if (participantFK.present) {
      map['participant_f_k'] = Variable<int>(participantFK.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllergiesLimitationsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dosageTimingMeta =
      const VerificationMeta('dosageTiming');
  @override
  late final GeneratedColumn<String> dosageTiming = GeneratedColumn<String>(
      'dosage_timing', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wasPrintedMeta =
      const VerificationMeta('wasPrinted');
  @override
  late final GeneratedColumn<bool> wasPrinted = GeneratedColumn<bool>(
      'was_printed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("was_printed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _participantFKMeta =
      const VerificationMeta('participantFK');
  @override
  late final GeneratedColumn<int> participantFK = GeneratedColumn<int>(
      'participant_f_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES participants (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, dosageTiming, dosage, wasPrinted, participantFK];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(Insertable<Medication> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage_timing')) {
      context.handle(
          _dosageTimingMeta,
          dosageTiming.isAcceptableOrUnknown(
              data['dosage_timing']!, _dosageTimingMeta));
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    }
    if (data.containsKey('was_printed')) {
      context.handle(
          _wasPrintedMeta,
          wasPrinted.isAcceptableOrUnknown(
              data['was_printed']!, _wasPrintedMeta));
    }
    if (data.containsKey('participant_f_k')) {
      context.handle(
          _participantFKMeta,
          participantFK.isAcceptableOrUnknown(
              data['participant_f_k']!, _participantFKMeta));
    } else if (isInserting) {
      context.missing(_participantFKMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dosageTiming: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage_timing']),
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage']),
      wasPrinted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_printed'])!,
      participantFK: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant_f_k'])!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final String name;
  final String? dosageTiming;
  final String? dosage;
  final bool wasPrinted;
  final int participantFK;
  const Medication(
      {required this.id,
      required this.name,
      this.dosageTiming,
      this.dosage,
      required this.wasPrinted,
      required this.participantFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dosageTiming != null) {
      map['dosage_timing'] = Variable<String>(dosageTiming);
    }
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    map['was_printed'] = Variable<bool>(wasPrinted);
    map['participant_f_k'] = Variable<int>(participantFK);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      dosageTiming: dosageTiming == null && nullToAbsent
          ? const Value.absent()
          : Value(dosageTiming),
      dosage:
          dosage == null && nullToAbsent ? const Value.absent() : Value(dosage),
      wasPrinted: Value(wasPrinted),
      participantFK: Value(participantFK),
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosageTiming: serializer.fromJson<String?>(json['dosageTiming']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      wasPrinted: serializer.fromJson<bool>(json['wasPrinted']),
      participantFK: serializer.fromJson<int>(json['participantFK']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dosageTiming': serializer.toJson<String?>(dosageTiming),
      'dosage': serializer.toJson<String?>(dosage),
      'wasPrinted': serializer.toJson<bool>(wasPrinted),
      'participantFK': serializer.toJson<int>(participantFK),
    };
  }

  Medication copyWith(
          {int? id,
          String? name,
          Value<String?> dosageTiming = const Value.absent(),
          Value<String?> dosage = const Value.absent(),
          bool? wasPrinted,
          int? participantFK}) =>
      Medication(
        id: id ?? this.id,
        name: name ?? this.name,
        dosageTiming:
            dosageTiming.present ? dosageTiming.value : this.dosageTiming,
        dosage: dosage.present ? dosage.value : this.dosage,
        wasPrinted: wasPrinted ?? this.wasPrinted,
        participantFK: participantFK ?? this.participantFK,
      );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosageTiming: data.dosageTiming.present
          ? data.dosageTiming.value
          : this.dosageTiming,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      wasPrinted:
          data.wasPrinted.present ? data.wasPrinted.value : this.wasPrinted,
      participantFK: data.participantFK.present
          ? data.participantFK.value
          : this.participantFK,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosageTiming: $dosageTiming, ')
          ..write('dosage: $dosage, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, dosageTiming, dosage, wasPrinted, participantFK);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosageTiming == this.dosageTiming &&
          other.dosage == this.dosage &&
          other.wasPrinted == this.wasPrinted &&
          other.participantFK == this.participantFK);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> dosageTiming;
  final Value<String?> dosage;
  final Value<bool> wasPrinted;
  final Value<int> participantFK;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosageTiming = const Value.absent(),
    this.dosage = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.participantFK = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.dosageTiming = const Value.absent(),
    this.dosage = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    required int participantFK,
  })  : name = Value(name),
        participantFK = Value(participantFK);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dosageTiming,
    Expression<String>? dosage,
    Expression<bool>? wasPrinted,
    Expression<int>? participantFK,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosageTiming != null) 'dosage_timing': dosageTiming,
      if (dosage != null) 'dosage': dosage,
      if (wasPrinted != null) 'was_printed': wasPrinted,
      if (participantFK != null) 'participant_f_k': participantFK,
    });
  }

  MedicationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? dosageTiming,
      Value<String?>? dosage,
      Value<bool>? wasPrinted,
      Value<int>? participantFK}) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosageTiming: dosageTiming ?? this.dosageTiming,
      dosage: dosage ?? this.dosage,
      wasPrinted: wasPrinted ?? this.wasPrinted,
      participantFK: participantFK ?? this.participantFK,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosageTiming.present) {
      map['dosage_timing'] = Variable<String>(dosageTiming.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (wasPrinted.present) {
      map['was_printed'] = Variable<bool>(wasPrinted.value);
    }
    if (participantFK.present) {
      map['participant_f_k'] = Variable<int>(participantFK.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosageTiming: $dosageTiming, ')
          ..write('dosage: $dosage, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }
}

class $CacheTable extends Cache with TableInfo<$CacheTable, CacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pinnedActionIDMeta =
      const VerificationMeta('pinnedActionID');
  @override
  late final GeneratedColumn<int> pinnedActionID = GeneratedColumn<int>(
      'pinned_action_i_d', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(null));
  static const VerificationMeta _currentActionIDMeta =
      const VerificationMeta('currentActionID');
  @override
  late final GeneratedColumn<int> currentActionID = GeneratedColumn<int>(
      'current_action_i_d', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(null));
  @override
  List<GeneratedColumn> get $columns => [id, pinnedActionID, currentActionID];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache';
  @override
  VerificationContext validateIntegrity(Insertable<CacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pinned_action_i_d')) {
      context.handle(
          _pinnedActionIDMeta,
          pinnedActionID.isAcceptableOrUnknown(
              data['pinned_action_i_d']!, _pinnedActionIDMeta));
    }
    if (data.containsKey('current_action_i_d')) {
      context.handle(
          _currentActionIDMeta,
          currentActionID.isAcceptableOrUnknown(
              data['current_action_i_d']!, _currentActionIDMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pinnedActionID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pinned_action_i_d']),
      currentActionID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_action_i_d']),
    );
  }

  @override
  $CacheTable createAlias(String alias) {
    return $CacheTable(attachedDatabase, alias);
  }
}

class CacheData extends DataClass implements Insertable<CacheData> {
  final int id;
  final int? pinnedActionID;
  final int? currentActionID;
  const CacheData(
      {required this.id, this.pinnedActionID, this.currentActionID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || pinnedActionID != null) {
      map['pinned_action_i_d'] = Variable<int>(pinnedActionID);
    }
    if (!nullToAbsent || currentActionID != null) {
      map['current_action_i_d'] = Variable<int>(currentActionID);
    }
    return map;
  }

  CacheCompanion toCompanion(bool nullToAbsent) {
    return CacheCompanion(
      id: Value(id),
      pinnedActionID: pinnedActionID == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedActionID),
      currentActionID: currentActionID == null && nullToAbsent
          ? const Value.absent()
          : Value(currentActionID),
    );
  }

  factory CacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheData(
      id: serializer.fromJson<int>(json['id']),
      pinnedActionID: serializer.fromJson<int?>(json['pinnedActionID']),
      currentActionID: serializer.fromJson<int?>(json['currentActionID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pinnedActionID': serializer.toJson<int?>(pinnedActionID),
      'currentActionID': serializer.toJson<int?>(currentActionID),
    };
  }

  CacheData copyWith(
          {int? id,
          Value<int?> pinnedActionID = const Value.absent(),
          Value<int?> currentActionID = const Value.absent()}) =>
      CacheData(
        id: id ?? this.id,
        pinnedActionID:
            pinnedActionID.present ? pinnedActionID.value : this.pinnedActionID,
        currentActionID: currentActionID.present
            ? currentActionID.value
            : this.currentActionID,
      );
  CacheData copyWithCompanion(CacheCompanion data) {
    return CacheData(
      id: data.id.present ? data.id.value : this.id,
      pinnedActionID: data.pinnedActionID.present
          ? data.pinnedActionID.value
          : this.pinnedActionID,
      currentActionID: data.currentActionID.present
          ? data.currentActionID.value
          : this.currentActionID,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheData(')
          ..write('id: $id, ')
          ..write('pinnedActionID: $pinnedActionID, ')
          ..write('currentActionID: $currentActionID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pinnedActionID, currentActionID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheData &&
          other.id == this.id &&
          other.pinnedActionID == this.pinnedActionID &&
          other.currentActionID == this.currentActionID);
}

class CacheCompanion extends UpdateCompanion<CacheData> {
  final Value<int> id;
  final Value<int?> pinnedActionID;
  final Value<int?> currentActionID;
  const CacheCompanion({
    this.id = const Value.absent(),
    this.pinnedActionID = const Value.absent(),
    this.currentActionID = const Value.absent(),
  });
  CacheCompanion.insert({
    this.id = const Value.absent(),
    this.pinnedActionID = const Value.absent(),
    this.currentActionID = const Value.absent(),
  });
  static Insertable<CacheData> custom({
    Expression<int>? id,
    Expression<int>? pinnedActionID,
    Expression<int>? currentActionID,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinnedActionID != null) 'pinned_action_i_d': pinnedActionID,
      if (currentActionID != null) 'current_action_i_d': currentActionID,
    });
  }

  CacheCompanion copyWith(
      {Value<int>? id,
      Value<int?>? pinnedActionID,
      Value<int?>? currentActionID}) {
    return CacheCompanion(
      id: id ?? this.id,
      pinnedActionID: pinnedActionID ?? this.pinnedActionID,
      currentActionID: currentActionID ?? this.currentActionID,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pinnedActionID.present) {
      map['pinned_action_i_d'] = Variable<int>(pinnedActionID.value);
    }
    if (currentActionID.present) {
      map['current_action_i_d'] = Variable<int>(currentActionID.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheCompanion(')
          ..write('id: $id, ')
          ..write('pinnedActionID: $pinnedActionID, ')
          ..write('currentActionID: $currentActionID')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InsuranceCompaniesTable insuranceCompanies =
      $InsuranceCompaniesTable(this);
  late final $ZzaActionsTable zzaActions = $ZzaActionsTable(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $ParamedicsTable paramedics = $ParamedicsTable(this);
  late final $RecordsTable records = $RecordsTable(this);
  late final $AllergiesLimitationsTable allergiesLimitations =
      $AllergiesLimitationsTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $CacheTable cache = $CacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        insuranceCompanies,
        zzaActions,
        participants,
        paramedics,
        records,
        allergiesLimitations,
        medications,
        cache
      ];
}

typedef $$InsuranceCompaniesTableCreateCompanionBuilder
    = InsuranceCompaniesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$InsuranceCompaniesTableUpdateCompanionBuilder
    = InsuranceCompaniesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$InsuranceCompaniesTableReferences extends BaseReferences<
    _$AppDatabase, $InsuranceCompaniesTable, InsuranceCompany> {
  $$InsuranceCompaniesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ParticipantsTable, List<Participant>>
      _participantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.participants,
          aliasName: $_aliasNameGenerator(
              db.insuranceCompanies.id, db.participants.insuranceCompanyFK));

  $$ParticipantsTableProcessedTableManager get participantsRefs {
    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter(
            (f) => f.insuranceCompanyFK.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_participantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InsuranceCompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $InsuranceCompaniesTable> {
  $$InsuranceCompaniesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> participantsRefs(
      Expression<bool> Function($$ParticipantsTableFilterComposer f) f) {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.insuranceCompanyFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InsuranceCompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $InsuranceCompaniesTable> {
  $$InsuranceCompaniesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$InsuranceCompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsuranceCompaniesTable> {
  $$InsuranceCompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> participantsRefs<T extends Object>(
      Expression<T> Function($$ParticipantsTableAnnotationComposer a) f) {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.insuranceCompanyFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InsuranceCompaniesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InsuranceCompaniesTable,
    InsuranceCompany,
    $$InsuranceCompaniesTableFilterComposer,
    $$InsuranceCompaniesTableOrderingComposer,
    $$InsuranceCompaniesTableAnnotationComposer,
    $$InsuranceCompaniesTableCreateCompanionBuilder,
    $$InsuranceCompaniesTableUpdateCompanionBuilder,
    (InsuranceCompany, $$InsuranceCompaniesTableReferences),
    InsuranceCompany,
    PrefetchHooks Function({bool participantsRefs})> {
  $$InsuranceCompaniesTableTableManager(
      _$AppDatabase db, $InsuranceCompaniesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsuranceCompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsuranceCompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsuranceCompaniesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              InsuranceCompaniesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              InsuranceCompaniesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InsuranceCompaniesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({participantsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (participantsRefs) db.participants],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (participantsRefs)
                    await $_getPrefetchedData<InsuranceCompany,
                            $InsuranceCompaniesTable, Participant>(
                        currentTable: table,
                        referencedTable: $$InsuranceCompaniesTableReferences
                            ._participantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InsuranceCompaniesTableReferences(db, table, p0)
                                .participantsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.insuranceCompanyFK == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InsuranceCompaniesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InsuranceCompaniesTable,
    InsuranceCompany,
    $$InsuranceCompaniesTableFilterComposer,
    $$InsuranceCompaniesTableOrderingComposer,
    $$InsuranceCompaniesTableAnnotationComposer,
    $$InsuranceCompaniesTableCreateCompanionBuilder,
    $$InsuranceCompaniesTableUpdateCompanionBuilder,
    (InsuranceCompany, $$InsuranceCompaniesTableReferences),
    InsuranceCompany,
    PrefetchHooks Function({bool participantsRefs})>;
typedef $$ZzaActionsTableCreateCompanionBuilder = ZzaActionsCompanion Function({
  Value<int> id,
  required String actionTitle,
  Value<String?> actionDescription,
  required DateTime dateFrom,
  required DateTime dateTo,
  Value<String?> homeDirectory,
});
typedef $$ZzaActionsTableUpdateCompanionBuilder = ZzaActionsCompanion Function({
  Value<int> id,
  Value<String> actionTitle,
  Value<String?> actionDescription,
  Value<DateTime> dateFrom,
  Value<DateTime> dateTo,
  Value<String?> homeDirectory,
});

final class $$ZzaActionsTableReferences
    extends BaseReferences<_$AppDatabase, $ZzaActionsTable, ZzaAction> {
  $$ZzaActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ParticipantsTable, List<Participant>>
      _participantsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.participants,
              aliasName: $_aliasNameGenerator(
                  db.zzaActions.id, db.participants.zzaActionFK));

  $$ParticipantsTableProcessedTableManager get participantsRefs {
    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.zzaActionFK.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_participantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ZzaActionsTableFilterComposer
    extends Composer<_$AppDatabase, $ZzaActionsTable> {
  $$ZzaActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionTitle => $composableBuilder(
      column: $table.actionTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionDescription => $composableBuilder(
      column: $table.actionDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateFrom => $composableBuilder(
      column: $table.dateFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateTo => $composableBuilder(
      column: $table.dateTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homeDirectory => $composableBuilder(
      column: $table.homeDirectory, builder: (column) => ColumnFilters(column));

  Expression<bool> participantsRefs(
      Expression<bool> Function($$ParticipantsTableFilterComposer f) f) {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.zzaActionFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ZzaActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ZzaActionsTable> {
  $$ZzaActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionTitle => $composableBuilder(
      column: $table.actionTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionDescription => $composableBuilder(
      column: $table.actionDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateFrom => $composableBuilder(
      column: $table.dateFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateTo => $composableBuilder(
      column: $table.dateTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homeDirectory => $composableBuilder(
      column: $table.homeDirectory,
      builder: (column) => ColumnOrderings(column));
}

class $$ZzaActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZzaActionsTable> {
  $$ZzaActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionTitle => $composableBuilder(
      column: $table.actionTitle, builder: (column) => column);

  GeneratedColumn<String> get actionDescription => $composableBuilder(
      column: $table.actionDescription, builder: (column) => column);

  GeneratedColumn<DateTime> get dateFrom =>
      $composableBuilder(column: $table.dateFrom, builder: (column) => column);

  GeneratedColumn<DateTime> get dateTo =>
      $composableBuilder(column: $table.dateTo, builder: (column) => column);

  GeneratedColumn<String> get homeDirectory => $composableBuilder(
      column: $table.homeDirectory, builder: (column) => column);

  Expression<T> participantsRefs<T extends Object>(
      Expression<T> Function($$ParticipantsTableAnnotationComposer a) f) {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.zzaActionFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ZzaActionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ZzaActionsTable,
    ZzaAction,
    $$ZzaActionsTableFilterComposer,
    $$ZzaActionsTableOrderingComposer,
    $$ZzaActionsTableAnnotationComposer,
    $$ZzaActionsTableCreateCompanionBuilder,
    $$ZzaActionsTableUpdateCompanionBuilder,
    (ZzaAction, $$ZzaActionsTableReferences),
    ZzaAction,
    PrefetchHooks Function({bool participantsRefs})> {
  $$ZzaActionsTableTableManager(_$AppDatabase db, $ZzaActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZzaActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZzaActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZzaActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> actionTitle = const Value.absent(),
            Value<String?> actionDescription = const Value.absent(),
            Value<DateTime> dateFrom = const Value.absent(),
            Value<DateTime> dateTo = const Value.absent(),
            Value<String?> homeDirectory = const Value.absent(),
          }) =>
              ZzaActionsCompanion(
            id: id,
            actionTitle: actionTitle,
            actionDescription: actionDescription,
            dateFrom: dateFrom,
            dateTo: dateTo,
            homeDirectory: homeDirectory,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String actionTitle,
            Value<String?> actionDescription = const Value.absent(),
            required DateTime dateFrom,
            required DateTime dateTo,
            Value<String?> homeDirectory = const Value.absent(),
          }) =>
              ZzaActionsCompanion.insert(
            id: id,
            actionTitle: actionTitle,
            actionDescription: actionDescription,
            dateFrom: dateFrom,
            dateTo: dateTo,
            homeDirectory: homeDirectory,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ZzaActionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({participantsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (participantsRefs) db.participants],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (participantsRefs)
                    await $_getPrefetchedData<ZzaAction, $ZzaActionsTable,
                            Participant>(
                        currentTable: table,
                        referencedTable: $$ZzaActionsTableReferences
                            ._participantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ZzaActionsTableReferences(db, table, p0)
                                .participantsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.zzaActionFK == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ZzaActionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ZzaActionsTable,
    ZzaAction,
    $$ZzaActionsTableFilterComposer,
    $$ZzaActionsTableOrderingComposer,
    $$ZzaActionsTableAnnotationComposer,
    $$ZzaActionsTableCreateCompanionBuilder,
    $$ZzaActionsTableUpdateCompanionBuilder,
    (ZzaAction, $$ZzaActionsTableReferences),
    ZzaAction,
    PrefetchHooks Function({bool participantsRefs})>;
typedef $$ParticipantsTableCreateCompanionBuilder = ParticipantsCompanion
    Function({
  Value<int> id,
  required String firstName,
  required String lastName,
  Value<int?> gender,
  Value<String?> address,
  Value<String?> birthNumber,
  Value<DateTime?> birthDate,
  Value<String?> parentPhoneNumber,
  Value<bool> eligibleConfirmation,
  Value<bool> nonInfectiousConfirmation,
  Value<bool> wasPrinted,
  Value<String?> parentName,
  Value<String?> parentEmail,
  Value<String?> campUnit,
  Value<String?> note,
  Value<bool> arrivedConfirmation,
  Value<String?> eligibleConfirmationPath,
  Value<int?> insuranceCompanyFK,
  required int zzaActionFK,
});
typedef $$ParticipantsTableUpdateCompanionBuilder = ParticipantsCompanion
    Function({
  Value<int> id,
  Value<String> firstName,
  Value<String> lastName,
  Value<int?> gender,
  Value<String?> address,
  Value<String?> birthNumber,
  Value<DateTime?> birthDate,
  Value<String?> parentPhoneNumber,
  Value<bool> eligibleConfirmation,
  Value<bool> nonInfectiousConfirmation,
  Value<bool> wasPrinted,
  Value<String?> parentName,
  Value<String?> parentEmail,
  Value<String?> campUnit,
  Value<String?> note,
  Value<bool> arrivedConfirmation,
  Value<String?> eligibleConfirmationPath,
  Value<int?> insuranceCompanyFK,
  Value<int> zzaActionFK,
});

final class $$ParticipantsTableReferences
    extends BaseReferences<_$AppDatabase, $ParticipantsTable, Participant> {
  $$ParticipantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InsuranceCompaniesTable _insuranceCompanyFKTable(_$AppDatabase db) =>
      db.insuranceCompanies.createAlias($_aliasNameGenerator(
          db.participants.insuranceCompanyFK, db.insuranceCompanies.id));

  $$InsuranceCompaniesTableProcessedTableManager? get insuranceCompanyFK {
    final $_column = $_itemColumn<int>('insurance_company_f_k');
    if ($_column == null) return null;
    final manager =
        $$InsuranceCompaniesTableTableManager($_db, $_db.insuranceCompanies)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_insuranceCompanyFKTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ZzaActionsTable _zzaActionFKTable(_$AppDatabase db) =>
      db.zzaActions.createAlias(
          $_aliasNameGenerator(db.participants.zzaActionFK, db.zzaActions.id));

  $$ZzaActionsTableProcessedTableManager get zzaActionFK {
    final $_column = $_itemColumn<int>('zza_action_f_k')!;

    final manager = $$ZzaActionsTableTableManager($_db, $_db.zzaActions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zzaActionFKTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RecordsTable, List<Record>> _recordsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.records,
          aliasName: $_aliasNameGenerator(
              db.participants.id, db.records.participantFK));

  $$RecordsTableProcessedTableManager get recordsRefs {
    final manager = $$RecordsTableTableManager($_db, $_db.records)
        .filter((f) => f.participantFK.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AllergiesLimitationsTable,
      List<AllergiesLimitation>> _allergiesLimitationsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.allergiesLimitations,
          aliasName: $_aliasNameGenerator(
              db.participants.id, db.allergiesLimitations.participantFK));

  $$AllergiesLimitationsTableProcessedTableManager
      get allergiesLimitationsRefs {
    final manager = $$AllergiesLimitationsTableTableManager(
            $_db, $_db.allergiesLimitations)
        .filter((f) => f.participantFK.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_allergiesLimitationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MedicationsTable, List<Medication>>
      _medicationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.medications,
              aliasName: $_aliasNameGenerator(
                  db.participants.id, db.medications.participantFK));

  $$MedicationsTableProcessedTableManager get medicationsRefs {
    final manager = $$MedicationsTableTableManager($_db, $_db.medications)
        .filter((f) => f.participantFK.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthNumber => $composableBuilder(
      column: $table.birthNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentPhoneNumber => $composableBuilder(
      column: $table.parentPhoneNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get eligibleConfirmation => $composableBuilder(
      column: $table.eligibleConfirmation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get nonInfectiousConfirmation => $composableBuilder(
      column: $table.nonInfectiousConfirmation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentName => $composableBuilder(
      column: $table.parentName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentEmail => $composableBuilder(
      column: $table.parentEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get campUnit => $composableBuilder(
      column: $table.campUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get arrivedConfirmation => $composableBuilder(
      column: $table.arrivedConfirmation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eligibleConfirmationPath => $composableBuilder(
      column: $table.eligibleConfirmationPath,
      builder: (column) => ColumnFilters(column));

  $$InsuranceCompaniesTableFilterComposer get insuranceCompanyFK {
    final $$InsuranceCompaniesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.insuranceCompanyFK,
        referencedTable: $db.insuranceCompanies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InsuranceCompaniesTableFilterComposer(
              $db: $db,
              $table: $db.insuranceCompanies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ZzaActionsTableFilterComposer get zzaActionFK {
    final $$ZzaActionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.zzaActionFK,
        referencedTable: $db.zzaActions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ZzaActionsTableFilterComposer(
              $db: $db,
              $table: $db.zzaActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> recordsRefs(
      Expression<bool> Function($$RecordsTableFilterComposer f) f) {
    final $$RecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.records,
        getReferencedColumn: (t) => t.participantFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecordsTableFilterComposer(
              $db: $db,
              $table: $db.records,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> allergiesLimitationsRefs(
      Expression<bool> Function($$AllergiesLimitationsTableFilterComposer f)
          f) {
    final $$AllergiesLimitationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.allergiesLimitations,
        getReferencedColumn: (t) => t.participantFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AllergiesLimitationsTableFilterComposer(
              $db: $db,
              $table: $db.allergiesLimitations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> medicationsRefs(
      Expression<bool> Function($$MedicationsTableFilterComposer f) f) {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.participantFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableFilterComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthNumber => $composableBuilder(
      column: $table.birthNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentPhoneNumber => $composableBuilder(
      column: $table.parentPhoneNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get eligibleConfirmation => $composableBuilder(
      column: $table.eligibleConfirmation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get nonInfectiousConfirmation => $composableBuilder(
      column: $table.nonInfectiousConfirmation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentName => $composableBuilder(
      column: $table.parentName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentEmail => $composableBuilder(
      column: $table.parentEmail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get campUnit => $composableBuilder(
      column: $table.campUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get arrivedConfirmation => $composableBuilder(
      column: $table.arrivedConfirmation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eligibleConfirmationPath => $composableBuilder(
      column: $table.eligibleConfirmationPath,
      builder: (column) => ColumnOrderings(column));

  $$InsuranceCompaniesTableOrderingComposer get insuranceCompanyFK {
    final $$InsuranceCompaniesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.insuranceCompanyFK,
        referencedTable: $db.insuranceCompanies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InsuranceCompaniesTableOrderingComposer(
              $db: $db,
              $table: $db.insuranceCompanies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ZzaActionsTableOrderingComposer get zzaActionFK {
    final $$ZzaActionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.zzaActionFK,
        referencedTable: $db.zzaActions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ZzaActionsTableOrderingComposer(
              $db: $db,
              $table: $db.zzaActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<int> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get birthNumber => $composableBuilder(
      column: $table.birthNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get parentPhoneNumber => $composableBuilder(
      column: $table.parentPhoneNumber, builder: (column) => column);

  GeneratedColumn<bool> get eligibleConfirmation => $composableBuilder(
      column: $table.eligibleConfirmation, builder: (column) => column);

  GeneratedColumn<bool> get nonInfectiousConfirmation => $composableBuilder(
      column: $table.nonInfectiousConfirmation, builder: (column) => column);

  GeneratedColumn<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => column);

  GeneratedColumn<String> get parentName => $composableBuilder(
      column: $table.parentName, builder: (column) => column);

  GeneratedColumn<String> get parentEmail => $composableBuilder(
      column: $table.parentEmail, builder: (column) => column);

  GeneratedColumn<String> get campUnit =>
      $composableBuilder(column: $table.campUnit, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get arrivedConfirmation => $composableBuilder(
      column: $table.arrivedConfirmation, builder: (column) => column);

  GeneratedColumn<String> get eligibleConfirmationPath => $composableBuilder(
      column: $table.eligibleConfirmationPath, builder: (column) => column);

  $$InsuranceCompaniesTableAnnotationComposer get insuranceCompanyFK {
    final $$InsuranceCompaniesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.insuranceCompanyFK,
            referencedTable: $db.insuranceCompanies,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InsuranceCompaniesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.insuranceCompanies,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$ZzaActionsTableAnnotationComposer get zzaActionFK {
    final $$ZzaActionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.zzaActionFK,
        referencedTable: $db.zzaActions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ZzaActionsTableAnnotationComposer(
              $db: $db,
              $table: $db.zzaActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> recordsRefs<T extends Object>(
      Expression<T> Function($$RecordsTableAnnotationComposer a) f) {
    final $$RecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.records,
        getReferencedColumn: (t) => t.participantFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.records,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> allergiesLimitationsRefs<T extends Object>(
      Expression<T> Function($$AllergiesLimitationsTableAnnotationComposer a)
          f) {
    final $$AllergiesLimitationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.allergiesLimitations,
            getReferencedColumn: (t) => t.participantFK,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AllergiesLimitationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.allergiesLimitations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> medicationsRefs<T extends Object>(
      Expression<T> Function($$MedicationsTableAnnotationComposer a) f) {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.participantFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableAnnotationComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ParticipantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (Participant, $$ParticipantsTableReferences),
    Participant,
    PrefetchHooks Function(
        {bool insuranceCompanyFK,
        bool zzaActionFK,
        bool recordsRefs,
        bool allergiesLimitationsRefs,
        bool medicationsRefs})> {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<int?> gender = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> birthNumber = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<String?> parentPhoneNumber = const Value.absent(),
            Value<bool> eligibleConfirmation = const Value.absent(),
            Value<bool> nonInfectiousConfirmation = const Value.absent(),
            Value<bool> wasPrinted = const Value.absent(),
            Value<String?> parentName = const Value.absent(),
            Value<String?> parentEmail = const Value.absent(),
            Value<String?> campUnit = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> arrivedConfirmation = const Value.absent(),
            Value<String?> eligibleConfirmationPath = const Value.absent(),
            Value<int?> insuranceCompanyFK = const Value.absent(),
            Value<int> zzaActionFK = const Value.absent(),
          }) =>
              ParticipantsCompanion(
            id: id,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            address: address,
            birthNumber: birthNumber,
            birthDate: birthDate,
            parentPhoneNumber: parentPhoneNumber,
            eligibleConfirmation: eligibleConfirmation,
            nonInfectiousConfirmation: nonInfectiousConfirmation,
            wasPrinted: wasPrinted,
            parentName: parentName,
            parentEmail: parentEmail,
            campUnit: campUnit,
            note: note,
            arrivedConfirmation: arrivedConfirmation,
            eligibleConfirmationPath: eligibleConfirmationPath,
            insuranceCompanyFK: insuranceCompanyFK,
            zzaActionFK: zzaActionFK,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String firstName,
            required String lastName,
            Value<int?> gender = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> birthNumber = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<String?> parentPhoneNumber = const Value.absent(),
            Value<bool> eligibleConfirmation = const Value.absent(),
            Value<bool> nonInfectiousConfirmation = const Value.absent(),
            Value<bool> wasPrinted = const Value.absent(),
            Value<String?> parentName = const Value.absent(),
            Value<String?> parentEmail = const Value.absent(),
            Value<String?> campUnit = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> arrivedConfirmation = const Value.absent(),
            Value<String?> eligibleConfirmationPath = const Value.absent(),
            Value<int?> insuranceCompanyFK = const Value.absent(),
            required int zzaActionFK,
          }) =>
              ParticipantsCompanion.insert(
            id: id,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            address: address,
            birthNumber: birthNumber,
            birthDate: birthDate,
            parentPhoneNumber: parentPhoneNumber,
            eligibleConfirmation: eligibleConfirmation,
            nonInfectiousConfirmation: nonInfectiousConfirmation,
            wasPrinted: wasPrinted,
            parentName: parentName,
            parentEmail: parentEmail,
            campUnit: campUnit,
            note: note,
            arrivedConfirmation: arrivedConfirmation,
            eligibleConfirmationPath: eligibleConfirmationPath,
            insuranceCompanyFK: insuranceCompanyFK,
            zzaActionFK: zzaActionFK,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ParticipantsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {insuranceCompanyFK = false,
              zzaActionFK = false,
              recordsRefs = false,
              allergiesLimitationsRefs = false,
              medicationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recordsRefs) db.records,
                if (allergiesLimitationsRefs) db.allergiesLimitations,
                if (medicationsRefs) db.medications
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (insuranceCompanyFK) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.insuranceCompanyFK,
                    referencedTable: $$ParticipantsTableReferences
                        ._insuranceCompanyFKTable(db),
                    referencedColumn: $$ParticipantsTableReferences
                        ._insuranceCompanyFKTable(db)
                        .id,
                  ) as T;
                }
                if (zzaActionFK) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.zzaActionFK,
                    referencedTable:
                        $$ParticipantsTableReferences._zzaActionFKTable(db),
                    referencedColumn:
                        $$ParticipantsTableReferences._zzaActionFKTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recordsRefs)
                    await $_getPrefetchedData<Participant, $ParticipantsTable,
                            Record>(
                        currentTable: table,
                        referencedTable:
                            $$ParticipantsTableReferences._recordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .recordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.participantFK == item.id),
                        typedResults: items),
                  if (allergiesLimitationsRefs)
                    await $_getPrefetchedData<Participant, $ParticipantsTable,
                            AllergiesLimitation>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._allergiesLimitationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .allergiesLimitationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.participantFK == item.id),
                        typedResults: items),
                  if (medicationsRefs)
                    await $_getPrefetchedData<Participant, $ParticipantsTable,
                            Medication>(
                        currentTable: table,
                        referencedTable: $$ParticipantsTableReferences
                            ._medicationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParticipantsTableReferences(db, table, p0)
                                .medicationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.participantFK == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ParticipantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (Participant, $$ParticipantsTableReferences),
    Participant,
    PrefetchHooks Function(
        {bool insuranceCompanyFK,
        bool zzaActionFK,
        bool recordsRefs,
        bool allergiesLimitationsRefs,
        bool medicationsRefs})>;
typedef $$ParamedicsTableCreateCompanionBuilder = ParamedicsCompanion Function({
  Value<int> id,
  required String firstName,
  required String lastName,
  required String address,
  required DateTime birthDate,
  required String phoneNumber,
  required String username,
});
typedef $$ParamedicsTableUpdateCompanionBuilder = ParamedicsCompanion Function({
  Value<int> id,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> address,
  Value<DateTime> birthDate,
  Value<String> phoneNumber,
  Value<String> username,
});

final class $$ParamedicsTableReferences
    extends BaseReferences<_$AppDatabase, $ParamedicsTable, Paramedic> {
  $$ParamedicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecordsTable, List<Record>> _recordsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.records,
          aliasName:
              $_aliasNameGenerator(db.paramedics.id, db.records.paramedicFK));

  $$RecordsTableProcessedTableManager get recordsRefs {
    final manager = $$RecordsTableTableManager($_db, $_db.records)
        .filter((f) => f.paramedicFK.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ParamedicsTableFilterComposer
    extends Composer<_$AppDatabase, $ParamedicsTable> {
  $$ParamedicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  Expression<bool> recordsRefs(
      Expression<bool> Function($$RecordsTableFilterComposer f) f) {
    final $$RecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.records,
        getReferencedColumn: (t) => t.paramedicFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecordsTableFilterComposer(
              $db: $db,
              $table: $db.records,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ParamedicsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParamedicsTable> {
  $$ParamedicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));
}

class $$ParamedicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParamedicsTable> {
  $$ParamedicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  Expression<T> recordsRefs<T extends Object>(
      Expression<T> Function($$RecordsTableAnnotationComposer a) f) {
    final $$RecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.records,
        getReferencedColumn: (t) => t.paramedicFK,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.records,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ParamedicsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParamedicsTable,
    Paramedic,
    $$ParamedicsTableFilterComposer,
    $$ParamedicsTableOrderingComposer,
    $$ParamedicsTableAnnotationComposer,
    $$ParamedicsTableCreateCompanionBuilder,
    $$ParamedicsTableUpdateCompanionBuilder,
    (Paramedic, $$ParamedicsTableReferences),
    Paramedic,
    PrefetchHooks Function({bool recordsRefs})> {
  $$ParamedicsTableTableManager(_$AppDatabase db, $ParamedicsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParamedicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParamedicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParamedicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<DateTime> birthDate = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> username = const Value.absent(),
          }) =>
              ParamedicsCompanion(
            id: id,
            firstName: firstName,
            lastName: lastName,
            address: address,
            birthDate: birthDate,
            phoneNumber: phoneNumber,
            username: username,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String firstName,
            required String lastName,
            required String address,
            required DateTime birthDate,
            required String phoneNumber,
            required String username,
          }) =>
              ParamedicsCompanion.insert(
            id: id,
            firstName: firstName,
            lastName: lastName,
            address: address,
            birthDate: birthDate,
            phoneNumber: phoneNumber,
            username: username,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ParamedicsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({recordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (recordsRefs) db.records],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recordsRefs)
                    await $_getPrefetchedData<Paramedic, $ParamedicsTable,
                            Record>(
                        currentTable: table,
                        referencedTable:
                            $$ParamedicsTableReferences._recordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ParamedicsTableReferences(db, table, p0)
                                .recordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.paramedicFK == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ParamedicsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ParamedicsTable,
    Paramedic,
    $$ParamedicsTableFilterComposer,
    $$ParamedicsTableOrderingComposer,
    $$ParamedicsTableAnnotationComposer,
    $$ParamedicsTableCreateCompanionBuilder,
    $$ParamedicsTableUpdateCompanionBuilder,
    (Paramedic, $$ParamedicsTableReferences),
    Paramedic,
    PrefetchHooks Function({bool recordsRefs})>;
typedef $$RecordsTableCreateCompanionBuilder = RecordsCompanion Function({
  Value<int> id,
  required DateTime dateAndTime,
  required String title,
  required String description,
  Value<String?> treatment,
  Value<bool> wasPrinted,
  Value<String?> note,
  Value<double?> temperature,
  Value<String?> picturePath,
  required int paramedicFK,
  required int participantFK,
});
typedef $$RecordsTableUpdateCompanionBuilder = RecordsCompanion Function({
  Value<int> id,
  Value<DateTime> dateAndTime,
  Value<String> title,
  Value<String> description,
  Value<String?> treatment,
  Value<bool> wasPrinted,
  Value<String?> note,
  Value<double?> temperature,
  Value<String?> picturePath,
  Value<int> paramedicFK,
  Value<int> participantFK,
});

final class $$RecordsTableReferences
    extends BaseReferences<_$AppDatabase, $RecordsTable, Record> {
  $$RecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParamedicsTable _paramedicFKTable(_$AppDatabase db) =>
      db.paramedics.createAlias(
          $_aliasNameGenerator(db.records.paramedicFK, db.paramedics.id));

  $$ParamedicsTableProcessedTableManager get paramedicFK {
    final $_column = $_itemColumn<int>('paramedic_f_k')!;

    final manager = $$ParamedicsTableTableManager($_db, $_db.paramedics)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paramedicFKTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ParticipantsTable _participantFKTable(_$AppDatabase db) =>
      db.participants.createAlias(
          $_aliasNameGenerator(db.records.participantFK, db.participants.id));

  $$ParticipantsTableProcessedTableManager get participantFK {
    final $_column = $_itemColumn<int>('participant_f_k')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantFKTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateAndTime => $composableBuilder(
      column: $table.dateAndTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treatment => $composableBuilder(
      column: $table.treatment, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get picturePath => $composableBuilder(
      column: $table.picturePath, builder: (column) => ColumnFilters(column));

  $$ParamedicsTableFilterComposer get paramedicFK {
    final $$ParamedicsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paramedicFK,
        referencedTable: $db.paramedics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParamedicsTableFilterComposer(
              $db: $db,
              $table: $db.paramedics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableFilterComposer get participantFK {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateAndTime => $composableBuilder(
      column: $table.dateAndTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treatment => $composableBuilder(
      column: $table.treatment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get picturePath => $composableBuilder(
      column: $table.picturePath, builder: (column) => ColumnOrderings(column));

  $$ParamedicsTableOrderingComposer get paramedicFK {
    final $$ParamedicsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paramedicFK,
        referencedTable: $db.paramedics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParamedicsTableOrderingComposer(
              $db: $db,
              $table: $db.paramedics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableOrderingComposer get participantFK {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAndTime => $composableBuilder(
      column: $table.dateAndTime, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get treatment =>
      $composableBuilder(column: $table.treatment, builder: (column) => column);

  GeneratedColumn<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => column);

  GeneratedColumn<String> get picturePath => $composableBuilder(
      column: $table.picturePath, builder: (column) => column);

  $$ParamedicsTableAnnotationComposer get paramedicFK {
    final $$ParamedicsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.paramedicFK,
        referencedTable: $db.paramedics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParamedicsTableAnnotationComposer(
              $db: $db,
              $table: $db.paramedics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ParticipantsTableAnnotationComposer get participantFK {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecordsTable,
    Record,
    $$RecordsTableFilterComposer,
    $$RecordsTableOrderingComposer,
    $$RecordsTableAnnotationComposer,
    $$RecordsTableCreateCompanionBuilder,
    $$RecordsTableUpdateCompanionBuilder,
    (Record, $$RecordsTableReferences),
    Record,
    PrefetchHooks Function({bool paramedicFK, bool participantFK})> {
  $$RecordsTableTableManager(_$AppDatabase db, $RecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> dateAndTime = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> treatment = const Value.absent(),
            Value<bool> wasPrinted = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<String?> picturePath = const Value.absent(),
            Value<int> paramedicFK = const Value.absent(),
            Value<int> participantFK = const Value.absent(),
          }) =>
              RecordsCompanion(
            id: id,
            dateAndTime: dateAndTime,
            title: title,
            description: description,
            treatment: treatment,
            wasPrinted: wasPrinted,
            note: note,
            temperature: temperature,
            picturePath: picturePath,
            paramedicFK: paramedicFK,
            participantFK: participantFK,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime dateAndTime,
            required String title,
            required String description,
            Value<String?> treatment = const Value.absent(),
            Value<bool> wasPrinted = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<double?> temperature = const Value.absent(),
            Value<String?> picturePath = const Value.absent(),
            required int paramedicFK,
            required int participantFK,
          }) =>
              RecordsCompanion.insert(
            id: id,
            dateAndTime: dateAndTime,
            title: title,
            description: description,
            treatment: treatment,
            wasPrinted: wasPrinted,
            note: note,
            temperature: temperature,
            picturePath: picturePath,
            paramedicFK: paramedicFK,
            participantFK: participantFK,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RecordsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {paramedicFK = false, participantFK = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (paramedicFK) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.paramedicFK,
                    referencedTable:
                        $$RecordsTableReferences._paramedicFKTable(db),
                    referencedColumn:
                        $$RecordsTableReferences._paramedicFKTable(db).id,
                  ) as T;
                }
                if (participantFK) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantFK,
                    referencedTable:
                        $$RecordsTableReferences._participantFKTable(db),
                    referencedColumn:
                        $$RecordsTableReferences._participantFKTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecordsTable,
    Record,
    $$RecordsTableFilterComposer,
    $$RecordsTableOrderingComposer,
    $$RecordsTableAnnotationComposer,
    $$RecordsTableCreateCompanionBuilder,
    $$RecordsTableUpdateCompanionBuilder,
    (Record, $$RecordsTableReferences),
    Record,
    PrefetchHooks Function({bool paramedicFK, bool participantFK})>;
typedef $$AllergiesLimitationsTableCreateCompanionBuilder
    = AllergiesLimitationsCompanion Function({
  Value<int> id,
  required String description,
  required int type,
  Value<bool> wasPrinted,
  required int participantFK,
});
typedef $$AllergiesLimitationsTableUpdateCompanionBuilder
    = AllergiesLimitationsCompanion Function({
  Value<int> id,
  Value<String> description,
  Value<int> type,
  Value<bool> wasPrinted,
  Value<int> participantFK,
});

final class $$AllergiesLimitationsTableReferences extends BaseReferences<
    _$AppDatabase, $AllergiesLimitationsTable, AllergiesLimitation> {
  $$AllergiesLimitationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _participantFKTable(_$AppDatabase db) =>
      db.participants.createAlias($_aliasNameGenerator(
          db.allergiesLimitations.participantFK, db.participants.id));

  $$ParticipantsTableProcessedTableManager get participantFK {
    final $_column = $_itemColumn<int>('participant_f_k')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantFKTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AllergiesLimitationsTableFilterComposer
    extends Composer<_$AppDatabase, $AllergiesLimitationsTable> {
  $$AllergiesLimitationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnFilters(column));

  $$ParticipantsTableFilterComposer get participantFK {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AllergiesLimitationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AllergiesLimitationsTable> {
  $$AllergiesLimitationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnOrderings(column));

  $$ParticipantsTableOrderingComposer get participantFK {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AllergiesLimitationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllergiesLimitationsTable> {
  $$AllergiesLimitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => column);

  $$ParticipantsTableAnnotationComposer get participantFK {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AllergiesLimitationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AllergiesLimitationsTable,
    AllergiesLimitation,
    $$AllergiesLimitationsTableFilterComposer,
    $$AllergiesLimitationsTableOrderingComposer,
    $$AllergiesLimitationsTableAnnotationComposer,
    $$AllergiesLimitationsTableCreateCompanionBuilder,
    $$AllergiesLimitationsTableUpdateCompanionBuilder,
    (AllergiesLimitation, $$AllergiesLimitationsTableReferences),
    AllergiesLimitation,
    PrefetchHooks Function({bool participantFK})> {
  $$AllergiesLimitationsTableTableManager(
      _$AppDatabase db, $AllergiesLimitationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllergiesLimitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllergiesLimitationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllergiesLimitationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<bool> wasPrinted = const Value.absent(),
            Value<int> participantFK = const Value.absent(),
          }) =>
              AllergiesLimitationsCompanion(
            id: id,
            description: description,
            type: type,
            wasPrinted: wasPrinted,
            participantFK: participantFK,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String description,
            required int type,
            Value<bool> wasPrinted = const Value.absent(),
            required int participantFK,
          }) =>
              AllergiesLimitationsCompanion.insert(
            id: id,
            description: description,
            type: type,
            wasPrinted: wasPrinted,
            participantFK: participantFK,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AllergiesLimitationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({participantFK = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (participantFK) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantFK,
                    referencedTable: $$AllergiesLimitationsTableReferences
                        ._participantFKTable(db),
                    referencedColumn: $$AllergiesLimitationsTableReferences
                        ._participantFKTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AllergiesLimitationsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AllergiesLimitationsTable,
        AllergiesLimitation,
        $$AllergiesLimitationsTableFilterComposer,
        $$AllergiesLimitationsTableOrderingComposer,
        $$AllergiesLimitationsTableAnnotationComposer,
        $$AllergiesLimitationsTableCreateCompanionBuilder,
        $$AllergiesLimitationsTableUpdateCompanionBuilder,
        (AllergiesLimitation, $$AllergiesLimitationsTableReferences),
        AllergiesLimitation,
        PrefetchHooks Function({bool participantFK})>;
typedef $$MedicationsTableCreateCompanionBuilder = MedicationsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> dosageTiming,
  Value<String?> dosage,
  Value<bool> wasPrinted,
  required int participantFK,
});
typedef $$MedicationsTableUpdateCompanionBuilder = MedicationsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> dosageTiming,
  Value<String?> dosage,
  Value<bool> wasPrinted,
  Value<int> participantFK,
});

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParticipantsTable _participantFKTable(_$AppDatabase db) =>
      db.participants.createAlias($_aliasNameGenerator(
          db.medications.participantFK, db.participants.id));

  $$ParticipantsTableProcessedTableManager get participantFK {
    final $_column = $_itemColumn<int>('participant_f_k')!;

    final manager = $$ParticipantsTableTableManager($_db, $_db.participants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantFKTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosageTiming => $composableBuilder(
      column: $table.dosageTiming, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnFilters(column));

  $$ParticipantsTableFilterComposer get participantFK {
    final $$ParticipantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableFilterComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosageTiming => $composableBuilder(
      column: $table.dosageTiming,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => ColumnOrderings(column));

  $$ParticipantsTableOrderingComposer get participantFK {
    final $$ParticipantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableOrderingComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosageTiming => $composableBuilder(
      column: $table.dosageTiming, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<bool> get wasPrinted => $composableBuilder(
      column: $table.wasPrinted, builder: (column) => column);

  $$ParticipantsTableAnnotationComposer get participantFK {
    final $$ParticipantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.participantFK,
        referencedTable: $db.participants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParticipantsTableAnnotationComposer(
              $db: $db,
              $table: $db.participants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationsTable,
    Medication,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (Medication, $$MedicationsTableReferences),
    Medication,
    PrefetchHooks Function({bool participantFK})> {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> dosageTiming = const Value.absent(),
            Value<String?> dosage = const Value.absent(),
            Value<bool> wasPrinted = const Value.absent(),
            Value<int> participantFK = const Value.absent(),
          }) =>
              MedicationsCompanion(
            id: id,
            name: name,
            dosageTiming: dosageTiming,
            dosage: dosage,
            wasPrinted: wasPrinted,
            participantFK: participantFK,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> dosageTiming = const Value.absent(),
            Value<String?> dosage = const Value.absent(),
            Value<bool> wasPrinted = const Value.absent(),
            required int participantFK,
          }) =>
              MedicationsCompanion.insert(
            id: id,
            name: name,
            dosageTiming: dosageTiming,
            dosage: dosage,
            wasPrinted: wasPrinted,
            participantFK: participantFK,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MedicationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({participantFK = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (participantFK) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.participantFK,
                    referencedTable:
                        $$MedicationsTableReferences._participantFKTable(db),
                    referencedColumn:
                        $$MedicationsTableReferences._participantFKTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MedicationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicationsTable,
    Medication,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (Medication, $$MedicationsTableReferences),
    Medication,
    PrefetchHooks Function({bool participantFK})>;
typedef $$CacheTableCreateCompanionBuilder = CacheCompanion Function({
  Value<int> id,
  Value<int?> pinnedActionID,
  Value<int?> currentActionID,
});
typedef $$CacheTableUpdateCompanionBuilder = CacheCompanion Function({
  Value<int> id,
  Value<int?> pinnedActionID,
  Value<int?> currentActionID,
});

class $$CacheTableFilterComposer extends Composer<_$AppDatabase, $CacheTable> {
  $$CacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pinnedActionID => $composableBuilder(
      column: $table.pinnedActionID,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentActionID => $composableBuilder(
      column: $table.currentActionID,
      builder: (column) => ColumnFilters(column));
}

class $$CacheTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheTable> {
  $$CacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pinnedActionID => $composableBuilder(
      column: $table.pinnedActionID,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentActionID => $composableBuilder(
      column: $table.currentActionID,
      builder: (column) => ColumnOrderings(column));
}

class $$CacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheTable> {
  $$CacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pinnedActionID => $composableBuilder(
      column: $table.pinnedActionID, builder: (column) => column);

  GeneratedColumn<int> get currentActionID => $composableBuilder(
      column: $table.currentActionID, builder: (column) => column);
}

class $$CacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CacheTable,
    CacheData,
    $$CacheTableFilterComposer,
    $$CacheTableOrderingComposer,
    $$CacheTableAnnotationComposer,
    $$CacheTableCreateCompanionBuilder,
    $$CacheTableUpdateCompanionBuilder,
    (CacheData, BaseReferences<_$AppDatabase, $CacheTable, CacheData>),
    CacheData,
    PrefetchHooks Function()> {
  $$CacheTableTableManager(_$AppDatabase db, $CacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> pinnedActionID = const Value.absent(),
            Value<int?> currentActionID = const Value.absent(),
          }) =>
              CacheCompanion(
            id: id,
            pinnedActionID: pinnedActionID,
            currentActionID: currentActionID,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> pinnedActionID = const Value.absent(),
            Value<int?> currentActionID = const Value.absent(),
          }) =>
              CacheCompanion.insert(
            id: id,
            pinnedActionID: pinnedActionID,
            currentActionID: currentActionID,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CacheTable,
    CacheData,
    $$CacheTableFilterComposer,
    $$CacheTableOrderingComposer,
    $$CacheTableAnnotationComposer,
    $$CacheTableCreateCompanionBuilder,
    $$CacheTableUpdateCompanionBuilder,
    (CacheData, BaseReferences<_$AppDatabase, $CacheTable, CacheData>),
    CacheData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InsuranceCompaniesTableTableManager get insuranceCompanies =>
      $$InsuranceCompaniesTableTableManager(_db, _db.insuranceCompanies);
  $$ZzaActionsTableTableManager get zzaActions =>
      $$ZzaActionsTableTableManager(_db, _db.zzaActions);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$ParamedicsTableTableManager get paramedics =>
      $$ParamedicsTableTableManager(_db, _db.paramedics);
  $$RecordsTableTableManager get records =>
      $$RecordsTableTableManager(_db, _db.records);
  $$AllergiesLimitationsTableTableManager get allergiesLimitations =>
      $$AllergiesLimitationsTableTableManager(_db, _db.allergiesLimitations);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$CacheTableTableManager get cache =>
      $$CacheTableTableManager(_db, _db.cache);
}
