# basic
## timeline
preEvent ---> Intake --> Event --> afterEvent

## PreEvent 
In time before the event start, can be huge for preparing 
1) creating event in system 
2) adding people in event* (name+surname at the min)
3) adding preexisting info to people*

## intake
Time and persistence critical part of workflow --> people are queing and medic is approving them in
the workflow must be quick, persistent, correct 
1) _person arrives_ 
2) medic intake page queries if person exists
   3) if no creates person as in PreEvent point 2 (expect minimal use)
3) has the person correct info 
   4) no - corrects it / marks for review later 
4) has the person (image/pdf) with doctor approval attached/or is marked as ok
   5) no - medic asks person and adds approval (mostly as mark not file upload, file upload can be later)
6) marks person as reviewed and present - UI changes to empty goto: 1

After all people are processed medic has option to add file uploads, go through review later , print all or print edits 

## Event 
Medic documents its treatements to each person with goal to add it to paper as quickly as possible (in case pc fails)
To prevent overprinting tool should have have some append print logic - to properly handle only adding to the page (or reprint enirely if it is needed/or something got broken)
1) _person gets sick and goes to the medic_ 
2) medic looks-up person for previous treatments and can add current treatment 
3) _after 1-n new treatments_ (preferably after each one) medic append prints the new treatment(s), or reprints entire page/person if its  needed 