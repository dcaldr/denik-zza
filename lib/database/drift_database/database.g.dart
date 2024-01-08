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
  static const VerificationMeta _insuranceCompanyMeta =
      const VerificationMeta('insuranceCompany');
  @override
  late final GeneratedColumn<int> insuranceCompany = GeneratedColumn<int>(
      'insurance_company', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES insurance_companies (id)'));
  static const VerificationMeta _zzaActionMeta =
      const VerificationMeta('zzaAction');
  @override
  late final GeneratedColumn<int> zzaAction = GeneratedColumn<int>(
      'zza_action', aliasedName, false,
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
        insuranceCompany,
        zzaAction
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
    if (data.containsKey('insurance_company')) {
      context.handle(
          _insuranceCompanyMeta,
          insuranceCompany.isAcceptableOrUnknown(
              data['insurance_company']!, _insuranceCompanyMeta));
    } else if (isInserting) {
      context.missing(_insuranceCompanyMeta);
    }
    if (data.containsKey('zza_action')) {
      context.handle(_zzaActionMeta,
          zzaAction.isAcceptableOrUnknown(data['zza_action']!, _zzaActionMeta));
    } else if (isInserting) {
      context.missing(_zzaActionMeta);
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
      insuranceCompany: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}insurance_company'])!,
      zzaAction: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}zza_action'])!,
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
  final int insuranceCompany;
  final int zzaAction;
  const Participant(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.address,
      required this.birthNumber,
      required this.birthDate,
      required this.parentPhoneNumber,
      required this.insuranceCompany,
      required this.zzaAction});
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
    map['insurance_company'] = Variable<int>(insuranceCompany);
    map['zza_action'] = Variable<int>(zzaAction);
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
      insuranceCompany: Value(insuranceCompany),
      zzaAction: Value(zzaAction),
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
      insuranceCompany: serializer.fromJson<int>(json['insuranceCompany']),
      zzaAction: serializer.fromJson<int>(json['zzaAction']),
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
      'insuranceCompany': serializer.toJson<int>(insuranceCompany),
      'zzaAction': serializer.toJson<int>(zzaAction),
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
          int? insuranceCompany,
          int? zzaAction}) =>
      Participant(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        address: address ?? this.address,
        birthNumber: birthNumber ?? this.birthNumber,
        birthDate: birthDate ?? this.birthDate,
        parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
        insuranceCompany: insuranceCompany ?? this.insuranceCompany,
        zzaAction: zzaAction ?? this.zzaAction,
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
          ..write('insuranceCompany: $insuranceCompany, ')
          ..write('zzaAction: $zzaAction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, firstName, lastName, address, birthNumber,
      birthDate, parentPhoneNumber, insuranceCompany, zzaAction);
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
          other.insuranceCompany == this.insuranceCompany &&
          other.zzaAction == this.zzaAction);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> address;
  final Value<String> birthNumber;
  final Value<DateTime> birthDate;
  final Value<String> parentPhoneNumber;
  final Value<int> insuranceCompany;
  final Value<int> zzaAction;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.birthNumber = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.parentPhoneNumber = const Value.absent(),
    this.insuranceCompany = const Value.absent(),
    this.zzaAction = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    required String lastName,
    required String address,
    required String birthNumber,
    required DateTime birthDate,
    required String parentPhoneNumber,
    required int insuranceCompany,
    required int zzaAction,
  })  : firstName = Value(firstName),
        lastName = Value(lastName),
        address = Value(address),
        birthNumber = Value(birthNumber),
        birthDate = Value(birthDate),
        parentPhoneNumber = Value(parentPhoneNumber),
        insuranceCompany = Value(insuranceCompany),
        zzaAction = Value(zzaAction);
  static Insertable<Participant> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? address,
    Expression<String>? birthNumber,
    Expression<DateTime>? birthDate,
    Expression<String>? parentPhoneNumber,
    Expression<int>? insuranceCompany,
    Expression<int>? zzaAction,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (birthNumber != null) 'birth_number': birthNumber,
      if (birthDate != null) 'birth_date': birthDate,
      if (parentPhoneNumber != null) 'parent_phone_number': parentPhoneNumber,
      if (insuranceCompany != null) 'insurance_company': insuranceCompany,
      if (zzaAction != null) 'zza_action': zzaAction,
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
      Value<int>? insuranceCompany,
      Value<int>? zzaAction}) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      birthNumber: birthNumber ?? this.birthNumber,
      birthDate: birthDate ?? this.birthDate,
      parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      zzaAction: zzaAction ?? this.zzaAction,
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
    if (insuranceCompany.present) {
      map['insurance_company'] = Variable<int>(insuranceCompany.value);
    }
    if (zzaAction.present) {
      map['zza_action'] = Variable<int>(zzaAction.value);
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
          ..write('insuranceCompany: $insuranceCompany, ')
          ..write('zzaAction: $zzaAction')
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
  static const VerificationMeta _paramedicMeta =
      const VerificationMeta('paramedic');
  @override
  late final GeneratedColumn<int> paramedic = GeneratedColumn<int>(
      'paramedic', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES paramedics (id)'));
  static const VerificationMeta _participantMeta =
      const VerificationMeta('participant');
  @override
  late final GeneratedColumn<int> participant = GeneratedColumn<int>(
      'participant', aliasedName, false,
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
        paramedic,
        participant
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
    if (data.containsKey('paramedic')) {
      context.handle(_paramedicMeta,
          paramedic.isAcceptableOrUnknown(data['paramedic']!, _paramedicMeta));
    } else if (isInserting) {
      context.missing(_paramedicMeta);
    }
    if (data.containsKey('participant')) {
      context.handle(
          _participantMeta,
          participant.isAcceptableOrUnknown(
              data['participant']!, _participantMeta));
    } else if (isInserting) {
      context.missing(_participantMeta);
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
      paramedic: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paramedic'])!,
      participant: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}participant'])!,
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
  final int paramedic;
  final int participant;
  const Record(
      {required this.id,
      required this.dateAndTime,
      required this.title,
      required this.description,
      required this.treatment,
      required this.wasPrinted,
      required this.paramedic,
      required this.participant});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_and_time'] = Variable<DateTime>(dateAndTime);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['treatment'] = Variable<String>(treatment);
    map['was_printed'] = Variable<bool>(wasPrinted);
    map['paramedic'] = Variable<int>(paramedic);
    map['participant'] = Variable<int>(participant);
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
      paramedic: Value(paramedic),
      participant: Value(participant),
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
      paramedic: serializer.fromJson<int>(json['paramedic']),
      participant: serializer.fromJson<int>(json['participant']),
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
      'paramedic': serializer.toJson<int>(paramedic),
      'participant': serializer.toJson<int>(participant),
    };
  }

  Record copyWith(
          {int? id,
          DateTime? dateAndTime,
          String? title,
          String? description,
          String? treatment,
          bool? wasPrinted,
          int? paramedic,
          int? participant}) =>
      Record(
        id: id ?? this.id,
        dateAndTime: dateAndTime ?? this.dateAndTime,
        title: title ?? this.title,
        description: description ?? this.description,
        treatment: treatment ?? this.treatment,
        wasPrinted: wasPrinted ?? this.wasPrinted,
        paramedic: paramedic ?? this.paramedic,
        participant: participant ?? this.participant,
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
          ..write('paramedic: $paramedic, ')
          ..write('participant: $participant')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateAndTime, title, description,
      treatment, wasPrinted, paramedic, participant);
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
          other.paramedic == this.paramedic &&
          other.participant == this.participant);
}

class RecordsCompanion extends UpdateCompanion<Record> {
  final Value<int> id;
  final Value<DateTime> dateAndTime;
  final Value<String> title;
  final Value<String> description;
  final Value<String> treatment;
  final Value<bool> wasPrinted;
  final Value<int> paramedic;
  final Value<int> participant;
  const RecordsCompanion({
    this.id = const Value.absent(),
    this.dateAndTime = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.treatment = const Value.absent(),
    this.wasPrinted = const Value.absent(),
    this.paramedic = const Value.absent(),
    this.participant = const Value.absent(),
  });
  RecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime dateAndTime,
    required String title,
    required String description,
    required String treatment,
    this.wasPrinted = const Value.absent(),
    required int paramedic,
    required int participant,
  })  : dateAndTime = Value(dateAndTime),
        title = Value(title),
        description = Value(description),
        treatment = Value(treatment),
        paramedic = Value(paramedic),
        participant = Value(participant);
  static Insertable<Record> custom({
    Expression<int>? id,
    Expression<DateTime>? dateAndTime,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? treatment,
    Expression<bool>? wasPrinted,
    Expression<int>? paramedic,
    Expression<int>? participant,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateAndTime != null) 'date_and_time': dateAndTime,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (treatment != null) 'treatment': treatment,
      if (wasPrinted != null) 'was_printed': wasPrinted,
      if (paramedic != null) 'paramedic': paramedic,
      if (participant != null) 'participant': participant,
    });
  }

  RecordsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? dateAndTime,
      Value<String>? title,
      Value<String>? description,
      Value<String>? treatment,
      Value<bool>? wasPrinted,
      Value<int>? paramedic,
      Value<int>? participant}) {
    return RecordsCompanion(
      id: id ?? this.id,
      dateAndTime: dateAndTime ?? this.dateAndTime,
      title: title ?? this.title,
      description: description ?? this.description,
      treatment: treatment ?? this.treatment,
      wasPrinted: wasPrinted ?? this.wasPrinted,
      paramedic: paramedic ?? this.paramedic,
      participant: participant ?? this.participant,
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
    if (paramedic.present) {
      map['paramedic'] = Variable<int>(paramedic.value);
    }
    if (participant.present) {
      map['participant'] = Variable<int>(participant.value);
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
          ..write('paramedic: $paramedic, ')
          ..write('participant: $participant')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [insuranceCompanies, zzaActions, participants, paramedics, records];
}
