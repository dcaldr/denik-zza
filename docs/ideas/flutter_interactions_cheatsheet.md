# Flutter Layout Widgets - Interakční Přehled
## Otázky, které si musí vývojář položit

---

## 🔴 CORE RULE
**Constraints go DOWN ↓ | Sizes go UP ↑ | Parent positions**

---

## QUICK CHECKLIST - 3 Kritické Otázky

### 1️⃣ Jaký widget je můj PŘÍMÝ RODIČ?

| Rodič | Constraint typ | Co to znamená |
|-------|----------------|---------------|
| **Row/Column** | Loose | Dávám dítku rozsah (0 až max), dítko si zvolí velikost |
| **Expanded** | Tight | Dítko MUSÍ být přesně tak velké jak Expanded |
| **Flexible** | Loose + max | Dítko může být menší, ale ne větší |
| **SingleChildScrollView** | Infinite | Na ose scrollování mohu být jakkoliv velký (⚠️ problém!) |
| **Container bez velikosti** | Loose | Expanduji na maximum |
| **SizedBox(w, h)** | Tight | Musím být přesně ty dimenze |
| **ListView** | Tight | Mohu být přesně ta velikost co ListView určí |
| **Stack** | Loose | Dostat si loose constraints (nebo Positioned = tight) |

**Prakticky:** Vždy ví co je přímý rodič!

---

### 2️⃣ Co chci aby se stalo s mým WIDGETem?

| Situace | Otázka | Odpověď |
|---------|--------|---------|
| Chci zabrat **zbytek místa** v Row | Jak to udělám? | Zabal do **Expanded** |
| Chci zabrat místo ale **dítko se nemusí expandovat** | Co když obsah je malý? | Zabal do **Flexible(fit: FlexFit.loose)** |
| Chci přesně **200x100px** | Jak to fixit? | Zabal do **SizedBox(200, 100)** |
| Chci **% šířky rodiče** (80%) | Jak to udělám? | Zabal do **FractionallySizedBox(widthFactor: 0.8)** |
| Chci **měnit velikost se screenem** | Jak responsive? | Zabal do **Container(width: MediaQuery.of(context).size.width * 0.8)** nebo **LayoutBuilder** |
| Chci **škálovat obsah aby se vešel** | Jak to udělám? | Zabal do **FittedBox** (musí být bounded!) |
| Chci **centrovat obsah** | Jak to udělám? | Zabal do **Center** nebo **Align(alignment: Alignment.center)** |
| Chci aby se **obsah scrolloval** | Jak to udělám? | Zabal do **SingleChildScrollView** |
| Chci aby se **list scrolloval efektivně** | Jak to udělám? | Zabal do **ListView.builder** |

---

### 3️⃣ Co chci aby se stalo s mým DITKem (dítko = co je uvnitř)?

| Situace | Otázka | Odpověď |
|---------|--------|---------|
| Dítko je **Text a chci aby zůstal malý** | Proč se expanduje? | Container bez alignment → expands. Řešení: **Přidej alignment** |
| Dítko je **Container bez velikosti** | Jak velký bude? | Expanduje na maximum (pokud nemá alignment) |
| Dítko je **seznam** | Jak to funguje? | Zabal do **ListView** (má tight constraints) |
| Dítko se **nezmešťuje v Row** | Proč overflow? | Nemáš **Expanded/Flexible**. Řešení: Zabal v Expanded |
| Dítko je **Widget bez známé velikosti** | Jak zjistím? | Testuj. Standardní widgets: Text, Icon znají svou velikost. |

---

## WIDGET REFERENCE - Matice Interakcí

### Container
**Expects size from parent?** Loose constraints
**Gives to child?** Depends na alignment
**Interaction questions:**
- ❓ Je v mém Containeru dítko? → Bez alignment = expands; S alignment = shrinks to child
- ❓ Chci aby Container zůstal malý? → Přidej alignment
- ❓ Chci aby zbytek místa zůstal? → Nepoužívej Container, použij Expanded

---

### SizedBox
**Expects size from parent?** Ignores parent (forces exact)
**Gives to child?** Tight (exactly w×h)
**Interaction questions:**
- ❓ Potřebuji spacing? → SizedBox(height: 16)
- ❓ Chci fixed dimensions? → SizedBox(width: 100, height: 50)
- ❓ Nebude width: double.infinity fungovat? → Správně! Použij Expanded místo toho

---

### Expanded
**Expects size from parent?** Must be in Row/Column/Flex
**Gives to child?** Tight (forced to be Expanded size)
**Interaction questions:**
- ❓ Mohu ho používat v SingleChildScrollView? → ❌ NE! Infinite constraint konflikt
- ❓ Mohu mít více Expandedů? → ✅ Ano, podělí se podle `flex`
- ❓ Co když chci aby child byl menší? → Použij Flexible místo Expanded
- ❓ Kde přesně se ho používá? → Jen v Row/Column/Flex direktně

---

### Flexible
**Expects size from parent?** Must be in Row/Column/Flex
**Gives to child?** Loose with max limit (FlexFit.loose = default)
**Interaction questions:**
- ❓ Jak se liší od Expanded? → Flexible dává loose, dítko se nemusí expandovat
- ❓ Kdy bych ho měl používat? → Když obsah MŮŽE být menší
- ❓ Lze ho použít s mainAxisSize.min? → ✅ Ano! To je ideální řešení

---

### SingleChildScrollView
**Expects size from parent?** Loose
**Gives to child?** Infinite constraints na scroll axis!
**Interaction questions:**
- ❓ Mohu v něm mít Expanded? → ❌ NE! Musím přidat mainAxisSize.min na Column
- ❓ Proč se mi text neroluje? → Pravděpodobně nemá omezení výšky
- ❓ Jak fixím Expanded uvnitř? → Column(mainAxisSize: MainAxisSize.min, ...) NEBO Flexible místo Expanded
- ❓ Je to efektivní? → Ne pro dlouhé listy. Použij ListView.builder místo toho

---

### Row / Column
**Expects size from parent?** Loose
**Gives to child?** Loose (aby si mohly zvolit velikost)
**Interaction questions:**
- ❓ Jak distribuuji prostor mezi děti? → Expanded pro pevné, Flexible pro volné
- ❓ Co je mainAxisAlignment? → Umísťuje UŽ ZNÁMÉ velikosti, ne constraints
- ❓ Co je crossAxisAlignment: stretch? → Dává tight constraints v cross-axis
- ❓ Proč mám overflow? → Děti jsou moc velké. Řešení: Expanded/Flexible/SingleChildScrollView

---

### FractionallySizedBox
**Expects size from parent?** Loose (needs bounded parent)
**Gives to child?** Percentage of parent max
**Interaction questions:**
- ❓ Jak se liší od hardcoded velikosti? → Responsive, škáluje se se screenem
- ❓ Funguje s infinite constraints? → Ne, potřebuje bounded rodiče
- ❓ Kde ho používám? → Responsive layouts bez MediaQuery opakování

---

### FittedBox
**Expects size from parent?** Loose + Child MUST be bounded!
**Gives to child?** Tight (scaled)
**Interaction questions:**
- ❓ Proč se mi nepředstírá? → Child nemá bounded constraints. Zabal v Container/SizedBox
- ❓ Funguje s Expanded? → Jen když Expanded má bounded rodiče
- ❓ Proč se text zkresluje? → FittedBox škáluje, může zkreslit

---

### Stack / Positioned
**Expects size from parent?** Loose
**Gives to child?** Varies - Positioned = tight, ostatní = loose
**Interaction questions:**
- ❓ Jaký je rozdíl Positioned vs Align? → Positioned = tight, Align = loose constraints
- ❓ Jak se dítko umísťuje? → Prvně se all child renderují, pak se stackují
- ❓ Proč to nescrolluje? → Stack nepodporuje scroll. Zabal do ScrollView

---

### ListView / ListView.builder
**Expects size from parent?** Tight
**Gives to child?** Tight (přesná velikost pro item)
**Interaction questions:**
- ❓ Kdy ListView místo SingleChildScrollView? → Dlouhé listy, lazy loading
- ❓ Mohu v něm mít Expanded? → ✅ Ano, ListView.builder je safe
- ❓ Jak se liší ListView od ListView.builder? → Builder je lazy, efektivnější

---

### Center / Align
**Expects size from parent?** Loose
**Gives to child?** Loose
**Interaction questions:**
- ❓ Jak se liší? → Center fixní (center), Align měnitelný alignment
- ❓ Proč se expandují? → Oba expandují na rodiče
- ❓ Jak malý má být obsah? → Dítko si zvolí, ne Center/Align

---

### Padding
**Expects size from parent?** Loose
**Gives to child?** Reduced constraints (minus padding)
**Interaction questions:**
- ❓ Je to stejné jako margin? → Není, padding je součást widgetu
- ❓ Jak se constraints změní? → Padding odečte svou velikost z dostupného prostoru
- ❓ Proč se dítko zmešťuje? → Já jsem odečetla padding. Řešení: Vyšší rodič

---

## INTERACTION MATRIX - Kdy co padá

| Kombinace | Funguje? | Co se stane | Řešení |
|-----------|----------|-----------|---------|
| SingleChildScrollView + Column + **Expanded** | ❌ | RenderFlex error | mainAxisSize.min nebo Flexible |
| Row + **Container bez alignment** + Text | ⚠️  | Text se expanduje na Container | Přidej alignment na Container |
| **FittedBox** bez bounded constraints | ❌ | Widget se nerendruje/divně | Zabal v Container/SizedBox |
| **Expanded** v nesprávném kontextu | ❌ | Runtime error | Zkontroluj že je v Row/Column/Flex |
| FractionallySizedBox + **infinite parent** | ⚠️  | Nefunguje správně | Omez rodiče bounded constraints |
| **MainAxisSize.max** + SingleChildScrollView | ❌ | Conflict | Změň na mainAxisSize.min |
| Stack + Positioned bez w/h | ⚠️  | Použije child size | Můžeš specifikovat top/left/width/height |
| ListView bez výšky od rodiče | ❌ | Error | Obalit do Container s height |

---

## QUICK DECISION TREE

```
Začínam layout, co mám v mysli?

├─ Potřebuji scroll?
│  ├─ Dlouhý seznam → ListView.builder ✅
│  ├─ Jednoduchý obsah → SingleChildScrollView + Column(mainAxisSize.min) ✅
│  └─ NOVĚ: Žádný scroll
│
├─ Potřebuji zbývající místo?
│  ├─ Ano → Expanded (pokud v Row/Col) ✅
│  ├─ Volně → Flexible(fit: FlexFit.loose) ✅
│  └─ Přesně? → SizedBox(w, h) ✅
│
├─ Potřebuji responsive (%)
│  ├─ Procento rodiče → FractionallySizedBox ✅
│  ├─ Poměr (16:9) → AspectRatio ✅
│  └─ Dynamické → LayoutBuilder ✅
│
├─ Potřebuji škálovat obsah?
│  ├─ Text/Widget do rodiče → FittedBox (musí být bounded!) ✅
│  └─ Bez fitování → Normální layout
│
├─ Obsah se nezmešťuje?
│  ├─ V Row/Column → Zabal v Expanded/Flexible/SingleChildScrollView ✅
│  └─ Container → Přidej alignment ✅

└─ Hotovo!
```

---

## CRITICAL GOTCHAS - Co NIKDY neděj bez přemýšlení

### ❌ TRAP 1: SingleChildScrollView + Column + Expanded
- **Problém:** Expanded expects finite height, ScrollView dává infinite
- **Symptom:** RenderFlex überflowed error
- **FIX:** mainAxisSize: MainAxisSize.min nebo Flexible

### ❌ TRAP 2: Container bez alignment + dítko
- **Problém:** Container expanduje, dítko s ním (expands too!)
- **Symptom:** Text se rozprostírá na Container
- **FIX:** Přidej alignment: Alignment.topLeft (any)

### ❌ TRAP 3: FittedBox s unbounded dítkem
- **Problém:** FittedBox neví jak velký má být obsah
- **Symptom:** Widget se nerendruje nebo se chová divně
- **FIX:** Zabal v Container/SizedBox s známou velikostí

### ❌ TRAP 4: Expanded mimo Row/Column/Flex
- **Problém:** Expanded očekává Flex widget
- **Symptom:** Runtime error
- **FIX:** Zkontroluj přímého rodiče

### ❌ TRAP 5: Positioning s MainAxisSize.max v ScrollView
- **Problém:** Conflict constraints
- **Symptom:** Layout errors
- **FIX:** mainAxisSize.min

---

## PŘÍKLADY ROZHODOVÁNÍ

**Scénář A:** Mám Text v Rowr, chci aby zbytek obsadila ikonou, zbyvek byl mezera
- Jaký je rodič Row? → Loose constraints
- Jak to udělám? → Text + Spacer + Icon
- Proč Spacer? → Expanduje na zbytek (= Expanded bez obsahu)

**Scénář B:** SingleChildScrollView s dlouhým Columnem, někdy Expanded pro zobrazení
- Proč to padá? → Infinite constraints
- Jak to fixím? → Column(mainAxisSize: MainAxisSize.min) + Flexible místo Expanded
- Alternativa? → Zabal v Container(height: screenHeight)

**Scénář C:** Chci aby se Button vměstnul do 80% screenové šířky
- Jak to udělám? → FractionallySizedBox(widthFactor: 0.8, child: Button)
- Kde je obalit? → V Centru nebo mezi Rows
- Je to responsive? → Ano, změní se podle screenWidth

---

## PERFORMANCE NOTES

| Widget | Performance | Tip |
|--------|-------------|-----|
| IntrinsicHeight/IntrinsicWidth | ❌ Heavy (2 passes) | Vyhnout se, použij Expanded/Flexible |
| shrinkWrap: true na ListView | ❌ Heavy | Používej jen když je potřeba |
| Nested Containers | ⚠️  Medium | Zač nepotřebné vnořování |
| const constructors | ✅ Light | Používej kde možno |
| ListView.builder | ✅ Light | Lazy loading = efektivní |
| RepaintBoundary | ✅ Optimization | Kolem widgets co se často překreslují |

