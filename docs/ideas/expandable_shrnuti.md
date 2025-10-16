# Expandable "Shrnutí" pattern (CsvReviewTableOverviewScreen)

## Context
The original table overview screen presented the file summary via an `ExpansionTile` inside `_buildSummaryPanel()`. The component exposed high-level counts (rejected, warning, info, ok) in the subtitle and revealed the full `SummarySection` widget once the user expanded the tile. The relevant implementation (commit prior to the progressive-disclosure experiment) looked like this:

```dart
final Map<CsvRowReviewStatus, List<CsvReviewRow>> grouped = _controller.groupedRows;
final int rejected = grouped[CsvRowReviewStatus.rejected]?.length ?? 0;
final int warn = grouped[CsvRowReviewStatus.warn]?.length ?? 0;
final int info = grouped[CsvRowReviewStatus.info]?.length ?? 0;
final int ok = grouped[CsvRowReviewStatus.ok]?.length ?? 0;
final String subtitle =
    'Zamítnuto $rejected • Varování $warn • Informace $info • Platné $ok';

return Card(
  elevation: 0,
  clipBehavior: Clip.antiAlias,
  child: ExpansionTile(
    key: const Key('CsvTableOverview_summaryTile'),
    initiallyExpanded: false,
    title: const Text('Shrnutí souboru'),
    subtitle: Text(subtitle),
    childrenPadding: const EdgeInsets.only(bottom: 16),
    children: <Widget>[
      SummarySection(
        review: _controller.session!.review,
        groupedRows: grouped,
      ),
    ],
  ),
);
```

### Why it worked
- **Familiar interaction**: Accordions/expansion tiles are a well-known mechanism for progressive disclosure in data-heavy screens.
- **Information scent**: The subtitle line (`Zamítnuto…`) gave immediate context for the detailed metrics hidden below.
- **Keeps layout stable**: Collapsed state occupies minimal vertical space while still conveying critical status counts.

### Limitations prompting the experiment
- **Duplicate content**: The same `SummarySection` appears elsewhere in some CSV review variants, increasing cognitive load.
- **Discoverability**: Some test users overlooked the expand affordance, missing deeper summary insights.
- **Visual emphasis**: The accordion looked similar to surrounding cards, so the hierarchy between quick stats and detailed insights was unclear.

## Reverting
To restore the legacy behaviour, swap the new progressive disclosure UI in `_buildSummaryPanel()` for the code snippet above. No additional dependencies were involved, so reverting is a straight drop-in replacement.

## Current iteration snapshot (Oct 2025)
- The header keeps the insights icon beside the "Shrnutí souboru" title, but the textual subtitle has been removed to avoid duplicating metrics.
- Aggregated counts are now displayed via the colourful `SummaryBadge` tiles inline with the header using a responsive `Wrap`, so the quick stats sit on the same visual tier as the title on wide layouts.
- A compact "Celkem řádků" chip complements the badges, and the entire summary remains always-on without an expansion affordance, continuing to satisfy the progressive-disclosure experiment goals.

## Follow-up ideas
- Reinstate the expansion tile but augment the header with a visual cue (e.g., iconography or colour coding for critical states).
- Alternatively, convert the detail section to a separate route or modal with breadcrumbs if future iterations make the summary much richer.
