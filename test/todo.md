# todo 

## next steps
1) fix, unifiy switching to "testing mode" in app and verify all necessaery places are covered (database, fileManager, print ops, etc)
2)  unifiy persistance setups in code so there is oprion for examining "end state" of db and files
    - have InMemory (where none is written to disk)
    - have persist mode 
      - where there will be one folder for the run  in project but outside of git
      - logic for the temp folder  (maybe option to pass folder name from dart-define) -- like format : test_25-09-testFolder_23638  <- anti collision numbers >
      - somehow organize it with test names or something to be understandable
      - DONT DELETE AFTER EACH TEST/AUTOMATICALLY - so we can examine it after the run
    - have "real" mode - where it writes to real app
      - real db/files - preferably create some autoError if they get touched from tests - to prevent accidental data loss, overridable with dart-define flag
      - maybe use test detection or blocks running only in test mode (to prevent having it in production code)
3) cleanup/refactor existing tests - naming, removing unnecessary ones, organizing into groups, removing unnecessary prints etc.. see notes below
4) add more edge cases+  multi-step Unit and widgets tests - especiallly negative tests (error handling, concurrency, etc)
5) When main app loop is stable enough - **create integration tests** that will cover it basically running through main user flows (event setup, adding people, adding records, printing) - to protect main app flow  fully back to back< - to prevent accidental breakages
   - Expect at the very least Windows and Adroid, preferably Linux and web, bonus for iOS
   - both from "empty start" and from "some data already present" sceanarios (with no internet connection)
     - protect critical paths with back to back unit and widget tests as well
6) expand integration tests - add more complex scenarios, edge cases, error handling, concurrency etc., **negative tests** 
7) code coverage optimization
8) cleanup again 
9)  secutrity tests


## general notes
better way of handling file persistance in tests (now special way for db, fileManager,etc its messy)
- probably use --dart-define feature flags (similar to complier flags in c/c++) to switch between real and test implementations - 
- but still rewrite setups to be more uniform 
- in future even pdf generation needs some mocking 

## test reorganization 
 > "we are using unit tests , widget tests and (Should use)integration tests specially back to back to protect main app flow" -- this could lead to data duplication in test setups so we need something to prevent that
   for example current hardcoded_setup can setup starting point for unit tests and widget tests, but could be usable for integration tests too -- this is unsupported now 
[ ] need a way for detaching data from setups/arranges for now to support unit tests as well as be useful steps in integration tests 

## Setup Rules 
- all testting should explicitly NOT touch real db or files 
- no printing when tests is ok (print only for debugging tests - to help troubleshoot)
- widget tests should use widget_test in file name
- get specific TAGS for tests (list TBD) -- one test can have multiple tags
- use groups to organize tests -- 1 test can have only 1 group (nested groups are ok)

## tests refactoring
### rename 
- as menion above widget tests should have widget_test in name

### cleanup 
- find bad tests - fix unnecessary prints etc. 
- remove unnecessary tests / obvious tests 
- remove tests targeting print_ops (old version of print_ops2)
- remove tests targeting screens (old versions of screens2)
### move 
- ?? mirror /lib ?? 
- but break into smaller somethings


## integration tests
- have same level folder as /tests
- maybe can reuse widget tests?? or even unit tests??
- have minimal app loop - that is always protected by those tests (ie main actions form event setup, adding people, adding records to people, printing) -- well simulating minimal real user flow on real app 
- have both "empty start" and "some data already present" scenarios
### expected app flows 
- create event -> add people -> add records -> print
- create event -> add people -> add records (to multiple people) -> print -> add more records -> append print
- create event -> add people -> add records -> print -> change records -> reprint

### protected flows 
- focus on record &print mutiple paths (add record -> print change records -> reprint... )
- database failures signaling/recovery (if any present)
- file reading/writing failures 
- csv import -> muulti path ... with error handling