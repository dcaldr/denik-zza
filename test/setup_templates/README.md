# Setup templates 
Contains modular functions to quickly get to state that can be tested. It is for removing repetitive work and allow for quick situation/ state creation


to avoid repeating *create event* --> create 10 people for it --> then do  the test

consists of: 
- setup functions 
    - group(s) of functions 
- test data 
- tests that test data are correct (maybe) [ ]

## Goals: 
1) avoid duplications 
2) avoid need for manually creating long test data
3) quickly simulate situations (have 10 people --> test X --> add new 8 people --> test Y, helps focus only on tests X,Y)
4) having +-same data across tests 
5) have it modular (allow creating "groups" from modular blocks ie. "basic event" == create event + create 10 people to it + add some records to the people... ) 
6) have place to store the test data (which can be big )


## List of templates: 
- Create event (1)
  - create events (ie. 5)
- basic person 
- basic set of people (ie 10)
  - have multiple sets of people to simulate changes
- record to person 
  - multiple records 

## info 
- data is in czech language
- cannot overlap (it is better to have setup10PeopleA, setup10PeopleB; than having "next" logic)
- format of rodne cislo is tested in-app so in test data it must be correct 