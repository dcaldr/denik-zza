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
  @override
  List<GeneratedColumn> get $columns =>
      [id, actionTitle, actionDescription, dateFrom, dateTo];
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
  const ZzaAction(
      {required this.id,
      required this.actionTitle,
      this.actionDescription,
      required this.dateFrom,
      required this.dateTo});
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
    };
  }

  ZzaAction copyWith(
          {int? id,
          String? actionTitle,
          Value<String?> actionDescription = const Value.absent(),
          DateTime? dateFrom,
          DateTime? dateTo}) =>
      ZzaAction(
        id: id ?? this.id,
        actionTitle: actionTitle ?? this.actionTitle,
        actionDescription: actionDescription.present
            ? actionDescription.value
            : this.actionDescription,
        dateFrom: dateFrom ?? this.dateFrom,
        dateTo: dateTo ?? this.dateTo,
      );
  @override
  String toString() {
    return (StringBuffer('ZzaAction(')
          ..write('id: $id, ')
          ..write('actionTitle: $actionTitle, ')
          ..write('actionDescription: $actionDescription, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, actionTitle, actionDescription, dateFrom, dateTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZzaAction &&
          other.id == this.id &&
          other.actionTitle == this.actionTitle &&
          other.actionDescription == this.actionDescription &&
          other.dateFrom == this.dateFrom &&
          other.dateTo == this.dateTo);
}

class ZzaActionsCompanion extends UpdateCompanion<ZzaAction> {
  final Value<int> id;
  final Value<String> actionTitle;
  final Value<String?> actionDescription;
  final Value<DateTime> dateFrom;
  final Value<DateTime> dateTo;
  const ZzaActionsCompanion({
    this.id = const Value.absent(),
    this.actionTitle = const Value.absent(),
    this.actionDescription = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
  });
  ZzaActionsCompanion.insert({
    this.id = const Value.absent(),
    required String actionTitle,
    this.actionDescription = const Value.absent(),
    required DateTime dateFrom,
    required DateTime dateTo,
  })  : actionTitle = Value(actionTitle),
        dateFrom = Value(dateFrom),
        dateTo = Value(dateTo);
  static Insertable<ZzaAction> custom({
    Expression<int>? id,
    Expression<String>? actionTitle,
    Expression<String>? actionDescription,
    Expression<DateTime>? dateFrom,
    Expression<DateTime>? dateTo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionTitle != null) 'action_title': actionTitle,
      if (actionDescription != null) 'action_description': actionDescription,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
    });
  }

  ZzaActionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? actionTitle,
      Value<String?>? actionDescription,
      Value<DateTime>? dateFrom,
      Value<DateTime>? dateTo}) {
    return ZzaActionsCompanion(
      id: id ?? this.id,
      actionTitle: actionTitle ?? this.actionTitle,
      actionDescription: actionDescription ?? this.actionDescription,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZzaActionsCompanion(')
          ..write('id: $id, ')
          ..write('actionTitle: $actionTitle, ')
          ..write('actionDescription: $actionDescription, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo')
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
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _birthNumberMeta =
      const VerificationMeta('birthNumber');
  @override
  late final GeneratedColumn<String> birthNumber = GeneratedColumn<String>(
      'birth_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 11),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _parentPhoneNumberMeta =
      const VerificationMeta('parentPhoneNumber');
  @override
  late final GeneratedColumn<String> parentPhoneNumber =
      GeneratedColumn<String>('parent_phone_number', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 0, maxTextLength: 13),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
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
  static const VerificationMeta _insuranceCompanyFKMeta =
      const VerificationMeta('insuranceCompanyFK');
  @override
  late final GeneratedColumn<int> insuranceCompanyFK = GeneratedColumn<int>(
      'insurance_company_f_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
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
        address,
        birthNumber,
        birthDate,
        parentPhoneNumber,
        eligibleConfirmation,
        nonInfectiousConfirmation,
        wasPrinted,
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
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('birth_number')) {
      context.handle(
          _birthNumberMeta,
          birthNumber.isAcceptableOrUnknown(
              data['birth_number']!, _birthNumberMeta));
    } else if (isInserting) {
      context.missing(_birthNumberMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('parent_phone_number')) {
      context.handle(
          _parentPhoneNumberMeta,
          parentPhoneNumber.isAcceptableOrUnknown(
              data['parent_phone_number']!, _parentPhoneNumberMeta));
    } else if (isInserting) {
      context.missing(_parentPhoneNumberMeta);
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
    if (data.containsKey('insurance_company_f_k')) {
      context.handle(
          _insuranceCompanyFKMeta,
          insuranceCompanyFK.isAcceptableOrUnknown(
              data['insurance_company_f_k']!, _insuranceCompanyFKMeta));
    } else if (isInserting) {
      context.missing(_insuranceCompanyFKMeta);
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
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      birthNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_number'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date'])!,
      parentPhoneNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_phone_number'])!,
      eligibleConfirmation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}eligible_confirmation'])!,
      nonInfectiousConfirmation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}non_infectious_confirmation'])!,
      wasPrinted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_printed'])!,
      insuranceCompanyFK: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}insurance_company_f_k'])!,
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
  final String address;
  final String birthNumber;
  final DateTime birthDate;
  final String parentPhoneNumber;
  final bool eligibleConfirmation;
  final bool nonInfectiousConfirmation;
  final bool wasPrinted;
  final int insuranceCompanyFK;
  final int zzaActionFK;
  const Participant(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.address,
      required this.birthNumber,
      required this.birthDate,
      required this.parentPhoneNumber,
      required this.eligibleConfirmation,
      required this.nonInfectiousConfirmation,
      required this.wasPrinted,
      required this.insuranceCompanyFK,
      required this.zzaActionFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['address'] = Variable<String>(address);
    map['birth_number'] = Variable<String>(birthNumber);
    map['birth_date'] = Variable<DateTime>(birthDate);
    map['parent_phone_number'] = Variable<String>(parentPhoneNumber);
    map['eligible_confirmation'] = Variable<bool>(eligibleConfirmation);
    map['non_infectious_confirmation'] =
        Variable<bool>(nonInfectiousConfirmation);
    map['was_printed'] = Variable<bool>(wasPrinted);
    map['insurance_company_f_k'] = Variable<int>(insuranceCompanyFK);
    map['zza_action_f_k'] = Variable<int>(zzaActionFK);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      address: Value(address),
      birthNumber: Value(birthNumber),
      birthDate: Value(birthDate),
      parentPhoneNumber: Value(parentPhoneNumber),
      eligibleConfirmation: Value(eligibleConfirmation),
      nonInfectiousConfirmation: Value(nonInfectiousConfirmation),
      wasPrinted: Value(wasPrinted),
      insuranceCompanyFK: Value(insuranceCompanyFK),
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
      address: serializer.fromJson<String>(json['address']),
      birthNumber: serializer.fromJson<String>(json['birthNumber']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      parentPhoneNumber: serializer.fromJson<String>(json['parentPhoneNumber']),
      eligibleConfirmation:
          serializer.fromJson<bool>(json['eligibleConfirmation']),
      nonInfectiousConfirmation:
          serializer.fromJson<bool>(json['nonInfectiousConfirmation']),
      wasPrinted: serializer.fromJson<bool>(json['wasPrinted']),
      insuranceCompanyFK: serializer.fromJson<int>(json['insuranceCompanyFK']),
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
      'address': serializer.toJson<String>(address),
      'birthNumber': serializer.toJson<String>(birthNumber),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'parentPhoneNumber': serializer.toJson<String>(parentPhoneNumber),
      'eligibleConfirmation': serializer.toJson<bool>(eligibleConfirmation),
      'nonInfectiousConfirmation':
          serializer.toJson<bool>(nonInfectiousConfirmation),
      'wasPrinted': serializer.toJson<bool>(wasPrinted),
      'insuranceCompanyFK': serializer.toJson<int>(insuranceCompanyFK),
      'zzaActionFK': serializer.toJson<int>(zzaActionFK),
    };
  }

  Participant copyWith(
          {int? id,
          String? firstName,
          String? lastName,
          String? address,
          String? birthNumber,
          DateTime? birthDate,
          String? parentPhoneNumber,
          bool? eligibleConfirmation,
          bool? nonInfectiousConfirmation,
          bool? wasPrinted,
          int? insuranceCompanyFK,
          int? zzaActionFK}) =>
      Participant(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        address: address ?? this.address,
        birthNumber: birthNumber ?? this.birthNumber,
        birthDate: birthDate ?? this.birthDate,
        parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
        eligibleConfirmation: eligibleConfirmation ?? this.eligibleConfirmation,
        nonInfectiousConfirmation:
            nonInfectiousConfirmation ?? this.nonInfectiousConfirmation,
        wasPrinted: wasPrinted ?? this.wasPrinted,
        insuranceCompanyFK: insuranceCompanyFK ?? this.insuranceCompanyFK,
        zzaActionFK: zzaActionFK ?? this.zzaActionFK,
      );
  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('birthNumber: $birthNumber, ')
          ..write('birthDate: $birthDate, ')
          ..write('parentPhoneNumber: $parentPhoneNumber, ')
          ..write('eligibleConfirmation: $eligibleConfirmation, ')
          ..write('nonInfectiousConfirmation: $nonInfectiousConfirmation, ')
          ..write('wasPrinted: $wasPrinted, ')
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
      address,
      birthNumber,
      birthDate,
      parentPhoneNumber,
      eligibleConfirmation,
      nonInfectiousConfirmation,
      wasPrinted,
      insuranceCompanyFK,
      zzaActionFK);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.address == this.address &&
          other.birthNumber == this.birthNumber &&
          other.birthDate == this.birthDate &&
          other.parentPhoneNumber == this.parentPhoneNumber &&
          other.eligibleConfirmation == this.eligibleConfirmation &&
          other.nonInfectiousConfirmation == this.nonInfectiousConfirmation &&
          other.wasPrinted == this.wasPrinted &&
          other.insuranceCompanyFK == this.insuranceCompanyFK &&
          other.zzaActionFK == this.zzaActionFK);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> address;
  final Value<String> birthNumber;
  final Value<DateTime> birthDate;
  final Value<String> parentPhoneNumber;
  final Value<bool> eligibleConfirmation;
  final Value<bool> nonInfectiousConfirmation;
  final Value<bool> wasPrinted;
  final Value<int> insuranceCompanyFK;
  final Value<int> zzaActionFK;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.birthNumber = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.parentPhoneNumber = const Value.absent(),
    this.eligibleConfirmation = const Value.absent(),
    this.nonInfectiousConfirmation = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.insuranceCompanyFK = const Value.absent(),
    this.zzaActionFK = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    required String lastName,
    required String address,
    required String birthNumber,
    required DateTime birthDate,
    required String parentPhoneNumber,
    this.eligibleConfirmation = const Value.absent(),
    this.nonInfectiousConfirmation = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    required int insuranceCompanyFK,
    required int zzaActionFK,
  })  : firstName = Value(firstName),
        lastName = Value(lastName),
        address = Value(address),
        birthNumber = Value(birthNumber),
        birthDate = Value(birthDate),
        parentPhoneNumber = Value(parentPhoneNumber),
        insuranceCompanyFK = Value(insuranceCompanyFK),
        zzaActionFK = Value(zzaActionFK);
  static Insertable<Participant> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? address,
    Expression<String>? birthNumber,
    Expression<DateTime>? birthDate,
    Expression<String>? parentPhoneNumber,
    Expression<bool>? eligibleConfirmation,
    Expression<bool>? nonInfectiousConfirmation,
    Expression<bool>? wasPrinted,
    Expression<int>? insuranceCompanyFK,
    Expression<int>? zzaActionFK,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (birthNumber != null) 'birth_number': birthNumber,
      if (birthDate != null) 'birth_date': birthDate,
      if (parentPhoneNumber != null) 'parent_phone_number': parentPhoneNumber,
      if (eligibleConfirmation != null)
        'eligible_confirmation': eligibleConfirmation,
      if (nonInfectiousConfirmation != null)
        'non_infectious_confirmation': nonInfectiousConfirmation,
      if (wasPrinted != null) 'was_printed': wasPrinted,
      if (insuranceCompanyFK != null)
        'insurance_company_f_k': insuranceCompanyFK,
      if (zzaActionFK != null) 'zza_action_f_k': zzaActionFK,
    });
  }

  ParticipantsCompanion copyWith(
      {Value<int>? id,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<String>? address,
      Value<String>? birthNumber,
      Value<DateTime>? birthDate,
      Value<String>? parentPhoneNumber,
      Value<bool>? eligibleConfirmation,
      Value<bool>? nonInfectiousConfirmation,
      Value<bool>? wasPrinted,
      Value<int>? insuranceCompanyFK,
      Value<int>? zzaActionFK}) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      birthNumber: birthNumber ?? this.birthNumber,
      birthDate: birthDate ?? this.birthDate,
      parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
      eligibleConfirmation: eligibleConfirmation ?? this.eligibleConfirmation,
      nonInfectiousConfirmation:
          nonInfectiousConfirmation ?? this.nonInfectiousConfirmation,
      wasPrinted: wasPrinted ?? this.wasPrinted,
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
          ..write('address: $address, ')
          ..write('birthNumber: $birthNumber, ')
          ..write('birthDate: $birthDate, ')
          ..write('parentPhoneNumber: $parentPhoneNumber, ')
          ..write('eligibleConfirmation: $eligibleConfirmation, ')
          ..write('nonInfectiousConfirmation: $nonInfectiousConfirmation, ')
          ..write('wasPrinted: $wasPrinted, ')
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
      'treatment', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 512),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
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
    } else if (isInserting) {
      context.missing(_treatmentMeta);
    }
    if (data.containsKey('was_printed')) {
      context.handle(
          _wasPrintedMeta,
          wasPrinted.isAcceptableOrUnknown(
              data['was_printed']!, _wasPrintedMeta));
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
          .read(DriftSqlType.string, data['${effectivePrefix}treatment'])!,
      wasPrinted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_printed'])!,
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
  final String treatment;
  final bool wasPrinted;
  final int paramedicFK;
  final int participantFK;
  const Record(
      {required this.id,
      required this.dateAndTime,
      required this.title,
      required this.description,
      required this.treatment,
      required this.wasPrinted,
      required this.paramedicFK,
      required this.participantFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_and_time'] = Variable<DateTime>(dateAndTime);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['treatment'] = Variable<String>(treatment);
    map['was_printed'] = Variable<bool>(wasPrinted);
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
      treatment: Value(treatment),
      wasPrinted: Value(wasPrinted),
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
      treatment: serializer.fromJson<String>(json['treatment']),
      wasPrinted: serializer.fromJson<bool>(json['wasPrinted']),
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
      'treatment': serializer.toJson<String>(treatment),
      'wasPrinted': serializer.toJson<bool>(wasPrinted),
      'paramedicFK': serializer.toJson<int>(paramedicFK),
      'participantFK': serializer.toJson<int>(participantFK),
    };
  }

  Record copyWith(
          {int? id,
          DateTime? dateAndTime,
          String? title,
          String? description,
          String? treatment,
          bool? wasPrinted,
          int? paramedicFK,
          int? participantFK}) =>
      Record(
        id: id ?? this.id,
        dateAndTime: dateAndTime ?? this.dateAndTime,
        title: title ?? this.title,
        description: description ?? this.description,
        treatment: treatment ?? this.treatment,
        wasPrinted: wasPrinted ?? this.wasPrinted,
        paramedicFK: paramedicFK ?? this.paramedicFK,
        participantFK: participantFK ?? this.participantFK,
      );
  @override
  String toString() {
    return (StringBuffer('Record(')
          ..write('id: $id, ')
          ..write('dateAndTime: $dateAndTime, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('treatment: $treatment, ')
          ..write('wasPrinted: $wasPrinted, ')
          ..write('paramedicFK: $paramedicFK, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateAndTime, title, description,
      treatment, wasPrinted, paramedicFK, participantFK);
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
          other.paramedicFK == this.paramedicFK &&
          other.participantFK == this.participantFK);
}

class RecordsCompanion extends UpdateCompanion<Record> {
  final Value<int> id;
  final Value<DateTime> dateAndTime;
  final Value<String> title;
  final Value<String> description;
  final Value<String> treatment;
  final Value<bool> wasPrinted;
  final Value<int> paramedicFK;
  final Value<int> participantFK;
  const RecordsCompanion({
    this.id = const Value.absent(),
    this.dateAndTime = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.treatment = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.paramedicFK = const Value.absent(),
    this.participantFK = const Value.absent(),
  });
  RecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime dateAndTime,
    required String title,
    required String description,
    required String treatment,
    this.wasPrinted = const Value.absent(),
    required int paramedicFK,
    required int participantFK,
  })  : dateAndTime = Value(dateAndTime),
        title = Value(title),
        description = Value(description),
        treatment = Value(treatment),
        paramedicFK = Value(paramedicFK),
        participantFK = Value(participantFK);
  static Insertable<Record> custom({
    Expression<int>? id,
    Expression<DateTime>? dateAndTime,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? treatment,
    Expression<bool>? wasPrinted,
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
      if (paramedicFK != null) 'paramedic_f_k': paramedicFK,
      if (participantFK != null) 'participant_f_k': participantFK,
    });
  }

  RecordsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? dateAndTime,
      Value<String>? title,
      Value<String>? description,
      Value<String>? treatment,
      Value<bool>? wasPrinted,
      Value<int>? paramedicFK,
      Value<int>? participantFK}) {
    return RecordsCompanion(
      id: id ?? this.id,
      dateAndTime: dateAndTime ?? this.dateAndTime,
      title: title ?? this.title,
      description: description ?? this.description,
      treatment: treatment ?? this.treatment,
      wasPrinted: wasPrinted ?? this.wasPrinted,
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
  List<GeneratedColumn> get $columns => [id, description, participantFK];
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
  final int participantFK;
  const AllergiesLimitation(
      {required this.id,
      required this.description,
      required this.participantFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    map['participant_f_k'] = Variable<int>(participantFK);
    return map;
  }

  AllergiesLimitationsCompanion toCompanion(bool nullToAbsent) {
    return AllergiesLimitationsCompanion(
      id: Value(id),
      description: Value(description),
      participantFK: Value(participantFK),
    );
  }

  factory AllergiesLimitation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllergiesLimitation(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      participantFK: serializer.fromJson<int>(json['participantFK']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
      'participantFK': serializer.toJson<int>(participantFK),
    };
  }

  AllergiesLimitation copyWith(
          {int? id, String? description, int? participantFK}) =>
      AllergiesLimitation(
        id: id ?? this.id,
        description: description ?? this.description,
        participantFK: participantFK ?? this.participantFK,
      );
  @override
  String toString() {
    return (StringBuffer('AllergiesLimitation(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, description, participantFK);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllergiesLimitation &&
          other.id == this.id &&
          other.description == this.description &&
          other.participantFK == this.participantFK);
}

class AllergiesLimitationsCompanion
    extends UpdateCompanion<AllergiesLimitation> {
  final Value<int> id;
  final Value<String> description;
  final Value<int> participantFK;
  const AllergiesLimitationsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.participantFK = const Value.absent(),
  });
  AllergiesLimitationsCompanion.insert({
    this.id = const Value.absent(),
    required String description,
    required int participantFK,
  })  : description = Value(description),
        participantFK = Value(participantFK);
  static Insertable<AllergiesLimitation> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<int>? participantFK,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (participantFK != null) 'participant_f_k': participantFK,
    });
  }

  AllergiesLimitationsCompanion copyWith(
      {Value<int>? id, Value<String>? description, Value<int>? participantFK}) {
    return AllergiesLimitationsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
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
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 512),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dosageTimingMeta =
      const VerificationMeta('dosageTiming');
  @override
  late final GeneratedColumn<String> dosageTiming = GeneratedColumn<String>(
      'dosage_timing', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
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
      [id, name, dosage, dosageTiming, participantFK];
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
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('dosage_timing')) {
      context.handle(
          _dosageTimingMeta,
          dosageTiming.isAcceptableOrUnknown(
              data['dosage_timing']!, _dosageTimingMeta));
    } else if (isInserting) {
      context.missing(_dosageTimingMeta);
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
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage'])!,
      dosageTiming: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage_timing'])!,
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
  final String dosage;
  final String dosageTiming;
  final int participantFK;
  const Medication(
      {required this.id,
      required this.name,
      required this.dosage,
      required this.dosageTiming,
      required this.participantFK});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    map['dosage_timing'] = Variable<String>(dosageTiming);
    map['participant_f_k'] = Variable<int>(participantFK);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      dosage: Value(dosage),
      dosageTiming: Value(dosageTiming),
      participantFK: Value(participantFK),
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      dosageTiming: serializer.fromJson<String>(json['dosageTiming']),
      participantFK: serializer.fromJson<int>(json['participantFK']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'dosageTiming': serializer.toJson<String>(dosageTiming),
      'participantFK': serializer.toJson<int>(participantFK),
    };
  }

  Medication copyWith(
          {int? id,
          String? name,
          String? dosage,
          String? dosageTiming,
          int? participantFK}) =>
      Medication(
        id: id ?? this.id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        dosageTiming: dosageTiming ?? this.dosageTiming,
        participantFK: participantFK ?? this.participantFK,
      );
  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('dosageTiming: $dosageTiming, ')
          ..write('participantFK: $participantFK')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, dosage, dosageTiming, participantFK);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.dosageTiming == this.dosageTiming &&
          other.participantFK == this.participantFK);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> dosage;
  final Value<String> dosageTiming;
  final Value<int> participantFK;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.dosageTiming = const Value.absent(),
    this.participantFK = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String dosage,
    required String dosageTiming,
    required int participantFK,
  })  : name = Value(name),
        dosage = Value(dosage),
        dosageTiming = Value(dosageTiming),
        participantFK = Value(participantFK);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? dosageTiming,
    Expression<int>? participantFK,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (dosageTiming != null) 'dosage_timing': dosageTiming,
      if (participantFK != null) 'participant_f_k': participantFK,
    });
  }

  MedicationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? dosage,
      Value<String>? dosageTiming,
      Value<int>? participantFK}) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageTiming: dosageTiming ?? this.dosageTiming,
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
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (dosageTiming.present) {
      map['dosage_timing'] = Variable<String>(dosageTiming.value);
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
          ..write('dosage: $dosage, ')
          ..write('dosageTiming: $dosageTiming, ')
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
  @override
  List<GeneratedColumn> get $columns => [id, pinnedActionID];
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
  const CacheData({required this.id, this.pinnedActionID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || pinnedActionID != null) {
      map['pinned_action_i_d'] = Variable<int>(pinnedActionID);
    }
    return map;
  }

  CacheCompanion toCompanion(bool nullToAbsent) {
    return CacheCompanion(
      id: Value(id),
      pinnedActionID: pinnedActionID == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedActionID),
    );
  }

  factory CacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheData(
      id: serializer.fromJson<int>(json['id']),
      pinnedActionID: serializer.fromJson<int?>(json['pinnedActionID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pinnedActionID': serializer.toJson<int?>(pinnedActionID),
    };
  }

  CacheData copyWith(
          {int? id, Value<int?> pinnedActionID = const Value.absent()}) =>
      CacheData(
        id: id ?? this.id,
        pinnedActionID:
            pinnedActionID.present ? pinnedActionID.value : this.pinnedActionID,
      );
  @override
  String toString() {
    return (StringBuffer('CacheData(')
          ..write('id: $id, ')
          ..write('pinnedActionID: $pinnedActionID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pinnedActionID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheData &&
          other.id == this.id &&
          other.pinnedActionID == this.pinnedActionID);
}

class CacheCompanion extends UpdateCompanion<CacheData> {
  final Value<int> id;
  final Value<int?> pinnedActionID;
  const CacheCompanion({
    this.id = const Value.absent(),
    this.pinnedActionID = const Value.absent(),
  });
  CacheCompanion.insert({
    this.id = const Value.absent(),
    this.pinnedActionID = const Value.absent(),
  });
  static Insertable<CacheData> custom({
    Expression<int>? id,
    Expression<int>? pinnedActionID,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinnedActionID != null) 'pinned_action_i_d': pinnedActionID,
    });
  }

  CacheCompanion copyWith({Value<int>? id, Value<int?>? pinnedActionID}) {
    return CacheCompanion(
      id: id ?? this.id,
      pinnedActionID: pinnedActionID ?? this.pinnedActionID,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheCompanion(')
          ..write('id: $id, ')
          ..write('pinnedActionID: $pinnedActionID')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
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
