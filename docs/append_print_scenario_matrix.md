# Append Print Scenario Matrix

Test matrix for append printing functionality.

---

## Scenarios

| ID | Baseline Pages | New Content Location | `reusedLastPage` | `finalPages` | User Loads |
|----|----------------|---------------------|------------------|--------------|------------|
| S1 | 0 | First print | n/a | N | N blank |
| S2 | 1 | Fits on page 1 | true | 1 | Page 1 |
| S3 | 1 | Overflows to page 2 | true | 2 | Page 1 + 1 blank |
| S4 | 1 | Page 1 full, new page 2 | false | 2 | Page 1* + 1 blank |
| S5 | 2 | Fits on page 2 | true | 2 | Page 1* + Page 2 |
| S6 | 2 | Overflows to page 3 | true | 3 | Page 1* + Page 2 + 1 blank |
| S7 | 2 | Page 2 full, new page 3 | false | 3 | Page 1* + Page 2* + 1 blank |

*\* = transparent content only (user can substitute blank paper)*

---

## Detection Logic

```dart
enum AppendScenario { firstPrint, fitsOnLast, overflowsNewPages, allNewPages }

AppendScenario detect(AppendAnalysis a) {
  if (a.baselinePages == 0) return AppendScenario.firstPrint;
  if (a.reusedLastPage && a.finalPages == a.baselinePages) return AppendScenario.fitsOnLast;
  if (a.reusedLastPage && a.finalPages > a.baselinePages) return AppendScenario.overflowsNewPages;
  return AppendScenario.allNewPages;
}
```

---

## Paper Loading by Printer Type

| Scenario | `page1OnTop = true` | `page1OnTop = false` |
|----------|---------------------|----------------------|
| S2 | [P1] | [P1] |
| S3 | [P1, blank] | [blank, P1] |
| S4 | [*, blank] | [blank, *] |
| S5 | [*, P2] | [P2, *] |
| S6 | [*, P2, blank] | [blank, P2, *] |
| S7 | [*, *, blank] | [blank, *, *] |

*Stack notation: [top, ..., bottom]*

---

## User Instruction Template

```
"Vložte do zásobníku:"
- [Seznam stránek s pořadím]
- [Prázdné listy pokud potřeba]

"Stránky označené * obsahují pouze transparentní obsah - 
můžete použít existující nebo prázdný papír."
```

---

## Test Cases

### Unit Tests (AppendAnalysis)
- [ ] S1: `baselinePages=0` → `firstPrint`
- [ ] S2: `reused=true, final==base` → `fitsOnLast`
- [ ] S3: `reused=true, final>base` → `overflowsNewPages`
- [ ] S4-S7: `reused=false` → `allNewPages`

### Integration Tests
- [ ] Verify `getPrinterPage1OnTop()` is called before print
- [ ] Verify dialog shows correct page count
- [ ] Verify paper order matches printer type

### E2E Tests
- [ ] S2: Single page append, verify transparency
- [ ] S3: Overflow append, verify page break handling
- [ ] S6: Multi-page with overflow
