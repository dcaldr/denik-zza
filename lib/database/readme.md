# Drift database

Vojtěch Keder

## Tables

* InsuranceCompanies
* ZzaActions
* Participants
* Paramedics
* Records

For table attribute details, see **tables.dart** file.

## API

### Inserting

For each table there is a method for inserting to that table.
The methods take a corresponding table **Companion** as a parameter.
Return type: `Future<int>`.

```
  await database.addZzaAction(
      ZzaActionsCompanion(
          actionTitle: Value('Tabor'),
          actionDescription: Value('Tento tabor bude skvely.'),
          dateFrom: Value(DateTime.now()),
          dateTo: Value(DateTime.now())
      )
  );
```

### Retrieving data

**Returns a list of all ZzaActions in database.**

Return type: `Future<List<ZzaAction>>`
```
await database.getAllZzaActions()
```

**Returns a list of all Participants in database.**

Return type: `Future<List<Participant>>`

```
await database.getAllParticipants()
```

**Returns a list of all Paramedics in database.**

Return type: `Future<List<Paramedic>>`

```
await database.getAllParamedics()
```

**Returns a ZzaAction based on an integer ID.**

Parameters: `int id`

Return type: `Future<ZzaAction>` or `null`

```
await database.getZzaActionByID(1)
```

**Returns a list of Records based on a Participant integer ID.**

Parameters: `int id`

Return type: `Future<List<Record>>`

```
await database.getRecordsByParticipantID(1)
```

**Returns an InsuranceCompany based on an integer ID.**

Parameters: `int id`

Return type: `Future<InsuranceCompany>` or `null`

```
await database.getInsuranceCompanyByID(1)
```