# Quick UI notes

quick notes and scribbles - **this isn't a plan** but can be used to make some
main purpose is documenting findings unrelated to open task and writing them down so they ne

## just notes in no order

- seznam akcí
  - -> list of participants needs to work search (at least in intake form was already done) etc  (see other parts of app if thjis wasnt already done )
- nový záznam úrazu
  - at least put it to menu preferably to AppBar (the top bar)
  - and try to document its ui style  
- seznam účastníků
  - probably also to the menu
- registrace účastníka
  - should default fit the screen w/o scroll (take max one screen)
- Intake form should by default fit the screen w/o scroll
  - and use all horizontal space (there appears to be 3 empty column )
  - has nice action buttons
- print center
  - tykání is bad !!
- deduplicate přijímací formulář
- menu UI styling
- add db protections
  - see menu structure below for securing proper state/context
  - document max lengths for fields in db model
    - make at least UI limits and see if there is proper place to put logic constraints

## similarity notes

### each screen

- appbar (or the top bar)
  - name
  - menu
  - info button (popup info regarding the screen)
  - (investigate back button)
  - some screens- action button (refresh/edit....)
- move to flexible layout

## menu structure

- proper redesign
- find if any screens are missing or should be added from above notes (and other notes)
- import osoba and osoby by csv (think of cleaner way to do it )
  - ? ie maybe import osoba item should have expandable subitem for csv import
  - ? and/or having special button on import osova screen for csv import
- prevent from accessing screens that cannot be logically accessed -- ie don't have proper state/context (ie. cannot add participant if no event is selected etc)
  - research if menu is proper place or if there is more fluter way to do it (or more logical and cleaner way)
