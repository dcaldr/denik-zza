# Screeny
Zde bude prakticky grafická stránka aplikace 
- chtěl bych aby vstupní pole spolupracovala s ```state_persistence``` knihovnou (nebo něčím co v případě pádu aplikace zachrání neuložené  pole )
- existuje ještě ``` shared_preferences```  ale to jsem vůbec nijak neviděl 

## Popis důležitých screenů, co nyní moc neodpovídají

### Obecně
- víc ikonek
- UI zlepšit stav
- tlačítka zpět
- zlikvidovat překrytí tlačítka 
- přesun co nejvíce UI definic nahoru do stromu 
- chybí používání setState po změnách nebo podobného mechanizmu https://docs.flutter.dev/ui#bringing-it-all-together 
- přejít na forms https://docs.flutter.dev/cookbook/forms/validation
- bacha dost věcí se používá vícekrát 

### příjem 
- vyhledá se už existující člověk + možnost vytvořit nového 
- umožní změnu základních polí (?možná po speciálním kliknutí- předejít náhodnému přepsání?)
- zaškrtnutí lékařského potvrzení (možná optional datum vydání? v budoucnu), bezinfekčnosti
- dopsání léků, omezení/alergií
- checkbox pro "přišel" <- může být auto true po zaškrtnutí bezinfekčnosti
- "statistika přišlých" 15 / 148 (později může na hover/klik zobrazit jména) 
- v budoucnu přidat nahrání/zobrazení potvrzení 

### vyšetření 
- v podstatě funguje dobře 
- přidat možnost teploty 
- přidat (?na rozklik?) zobrazení základního infa 
- v budoucnu zobrazení potvrzení 

### boční menu 
- přidat search pole -> rovnou vedoucí na vyšetření s daným člověkem

### (Nový) přehled / hlavní stránka - do budoucna
- různé přehledy/ statistiky 
- ošetření po dnech 
- děti s aktivní teplotou 
- ... 
### Login
- fix pokud neexistuje uživatel (buď nastavit 1 co bude vždy/ nebo navést na vytvoření účtu)
- hlášky špatného už. jména 
- ! bacha na kolize při vytváření
- umožnit změnu loginu za běhu aplikace
### Upravit/vytvořit profil 
- make it make sense 
  - je duplikovaná, nefunguje, nevrací ...
- v podstatě od základu 

### přidat akci 
- lepší fungování zapsání dat
### (nový) screen na zapsání oddílů 
- asi seznam jmen s autocomplete polem na přiřazení oddílu  
- možnost přepsat jméno oddílu 

<s>
CHECK LIST - už neplatí

1) zapomenute heslo chybi, dodelat screen, navigace z login screen- update: snad vše done
2) side bar
3) logo nejde nacist ??? zmena profilovky nahrat profilovku
4) popup neumim, je to tezsi, podivat se na to - update: něco mám tak snad v pohodě kdyžtak zkontrolovat
5) vsechny akce logika, list akci, pridavani do listu, search bar??? to bude propojene s databazi i guess
6) vytvorit screeny na akce, edit, detail - upadate: snad done jen automatiké vyplňování 
7) pridat ucastnika csv import, screeny 
8) novy zaznam, uprava, tisk screeny
9) vsichni ucastnici, list jmen, upravy, pridat, odebrat logika z listu
10) ikona nahore?? idk
11) 
12) 
13) 
14) 
15) 
16) 
17) 
18) 
19) 
20) 
</s>