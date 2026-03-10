-- ============================================
-- VIEW: v_monthly_spend_certified
-- Layer: ANALYSIS
-- Purpose: Monthly spend aggregation built on canonical truth.
--
-- Derives executive reporting metrics from v_truth_canonical.
-- All figures are certification-gated — only verified spend
-- enters these aggregations.
--
-- Produces:
--   total_spend     — sum of certified spend per month
--   order_count     — distinct order events (date + supplier)
--   supplier_count  — distinct suppliers active per month
--
-- Note: order_count uses a composite key (date|supplier)
-- to count distinct delivery events rather than line items.
-- ============================================

SELECT
    EXTRACT(year  FROM order_date)::integer                          AS year,
    EXTRACT(month FROM order_date)::integer                          AS month,
    date_trunc('month', order_date::timestamp with time zone)::date  AS month_start,

    SUM(total_cost)::numeric(14,2)                                   AS total_spend,

    COUNT(DISTINCT order_date || '|' || supplier::text)              AS order_count,
    COUNT(DISTINCT supplier)                                         AS supplier_count

FROM v_truth_canonical

GROUP BY
    EXTRACT(year  FROM order_date)::integer,
    EXTRACT(month FROM order_date)::integer,
    date_trunc('month', order_date::timestamp with time zone)::date;
```
