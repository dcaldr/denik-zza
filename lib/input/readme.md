# Input
Validace & input csv, a vstupů obecně 
- hlavní validace bude probíhat zde (ne až v databázi)
- věk, rok narození ...
- Bude dobrý zkusit najít nějakou knihovnu pro ulehčení práce

# Nápad na řešení validace dat
rozhodně se nemusí použít spíš to je jenom odrazový můstek (a nedělal jsem k tomu nějaký silný research)
Prakticky jsem jenom prokrastivnoval učení se na účetnictví :/
## Obecně
- mít něco jako ```verifyInputRecord()``` co by se dalo použít třeba i pro ruční vkládání dat dále v aplikaci
-  možná zkusit "chain of responsibility" pattern https://refactoring.guru/design-patterns/behavioral-patterns 
  - tj. brát to po kousích a třeba "čištění dat" (odebrání mezer/velkých písmen atd) by se dalo totiž použít několikrát
- Udělat si třídu (?+ enum) na odpověď volajícímu 
  - Typ:{ Ok, Info(např. malé písmeno na začátku jména ), Warning (asi chyba ale fungující např. divný formát rč), Error (fakt problém např. nelze sparsovat datum)}
  - \+ Message (zpráva uživateli, pokud potřeba)
  - \+ vrátit upravenou kolonku/ záznam _-- tady si nejsem jistý jak, když to jsou různé typy, rád se ale případně přidám do diskuse_
  - možná třeba na pojišťovny udělat třídu nebo nějaké porovnání/přirovnání (?)
### Možné kroky:
1) zkontrolovat že první řádek csv sedí - jinak to moc nedává smysl (šlo by přeskládat, ale to je zbytečně těžké asi)
2) zavolat na každý řádek methodu co jí vyhodnotí  (asi počítat s dalším použitím v aplikaci)>
3) pro každé políčko udělat pipeline (počítat s dalším použitím v aplikaci)
   1) vyčistit data (mezery uvozovky  atd.) (pro většinu asi bude stejný asi krom dat )
   2) zkusit naparsovat na dále očekávaný formát (např. rč. xxx/nnn == xxxnnn atd; pojišťovna 207 == OZP...)
   3) Verifikovat že dává smysl (např. rok_narození < současný rok atd. )
   4) Vrátit upravený záznam spolu s informací jak to dopadlo
4) methoda řádku vygeneruje objekt co se dá použít v aplikaci/ databázi (teď to je MemoryOsoba)

 ** v podstatě lze na začátku pro tu pipeline použít jenom prázdné funkce co si to předají a později až dodat logiku 

