# Metric definitions and verification

The README figures come from the recorded database audit of **27 August 2026**, reviewed on **21 September 2026**. They are a dated evidence snapshot, not a claim that the database was successfully queried again on the review date.

| Measure | Verified snapshot | Meaning |
| --- | ---: | --- |
| Recorded purchasing line items | 6,093 | Rows in the historical financial import source; not distinct supplier orders or payments |
| Historical charged spend | £58,280.36 | Sum of recorded charged line totals; not quantity multiplied by stored unit cost |
| Certified canonical line items | 5,964 | Historical rows admitted through certified physical-unit mappings |
| Certified canonical spend | £56,995.24 | Charged spend represented by that certified subset |
| Outside the certified subset | 129 lines / £1,285.12 | Included in recorded financial totals, but not in certified physical-quantity analysis |

Source evidence is retained in the implementation repository's `docs/executive/phase0/PHASE_0_VALIDATOR_RAW_RESULTS_2026-08-27.json` (`reconciliation`) and its accompanying `PHASE_0_AUDIT.md`. Customer-level source records are not reproduced here.

The audit identified 17 duplicate-signature candidate groups. These were investigation candidates, not confirmed duplicates, so the figures preserve recorded rows without automatic deduplication. They describe imported purchasing history rather than independently reconciled payments. GBP is the project's configured currency basis.

The earlier claim of **440 active canonical products** was removed because an active-product count could not be independently revalidated. A total product-master count is not evidence of active status, recent purchasing activity or recommendation eligibility.

## Revalidation status

On 21 September 2026, the connected database inspection tool exposed a different project's schema. The implementation repository's configured Hyde database hostname then failed DNS resolution. Neither route established current Hyde totals, and no database changes were attempted.

To refresh the figures, run these read-only queries against the confirmed Hyde database. Return only the aggregate results, then update the snapshot date and this note together:

```sql
SELECT
    COUNT(*) AS recorded_purchasing_line_items,
    SUM(total_cost) AS recorded_charged_spend_gbp,
    COUNT(*) FILTER (WHERE total_cost IS NULL) AS missing_charged_totals,
    MIN(order_date) AS first_recorded_event_date,
    MAX(order_date) AS latest_recorded_event_date
FROM public.financial_historical_imports;

SELECT
    COUNT(*) AS certified_line_items,
    SUM(total_cost) AS certified_charged_spend_gbp
FROM public.v_truth_canonical;

SELECT COUNT(*) AS active_product_master_entries
FROM public.product_master
WHERE is_active IS TRUE;
```

`is_active` measures a catalogue flag. If published, label it as active product-master entries rather than products purchased recently or products eligible for automated ordering.

## Architecture evidence

The README summarises the versioned backend and Hyde governance documents, the application's governed tool interfaces and the Ocado local execution implementation. It is not a claim that every deployment or target-device acceptance check was rerun during this documentation review.

The earlier core governance describes certified spend-reporting views. The later executive contract and current application integration separate recorded charged spend from physical-certification coverage. The README makes those branches explicit; live deployment parity could not be checked during this review.

The local execution extension permits both historical and simulation source classifications. The current connected job-creation path inspected for this review builds historical reconstruction jobs, so the README shows that narrower implemented path.
