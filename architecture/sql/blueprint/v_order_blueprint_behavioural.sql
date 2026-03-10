-- ============================================
-- VIEW: v_order_blueprint_behavioural
-- Layer: BLUEPRINT
-- Purpose: Behavioural replenishment intelligence.
--
-- Calculates canonical reorder quantity per product using
-- rolling consumption metrics and adaptive cadence state.
--
-- Core calculation:
--   suggested_order_qty = avg_weekly_consumption
--                         × (effective_cadence_days / 7)
--
-- effective_cadence_days comes from v_product_consumption_state_effective
-- which applies anomaly-adjusted cadence where active,
-- falling back to baseline cadence otherwise.
--
-- This means a temporary bulk purchase extends the suggested
-- reorder window without permanently recalibrating the baseline.
-- Regime change requires 3 consecutive elevated orders.
--
-- Joins:
--   product_master                        — canonical identity
--   v_consumption_metrics_365d            — rolling behavioural metrics
--   v_product_consumption_state_effective — adaptive cadence state
--
-- Excludes:
--   inactive products (is_active = false)
--   products without consumption metrics
--   pricing optimisation (intentionally deferred)
--
-- Note: primary_supplier, primary_unit_cost, monthly_savings_potential
-- are NULL placeholders — pricing advisory is deferred pending
-- a certified invoice-derived pricing pipeline.
-- ============================================

SELECT
    pm.code            AS product_code,
    pm.product_name,
    pm.category,
    pm.subcategory,
    pm.department,

    cm.canonical_unit,
    cm.total_consumption_365d,
    cm.avg_monthly_consumption,
    cm.avg_weekly_consumption,
    cm.order_lines_365d,
    cm.total_orders,
    cm.avg_days_between_orders,
    cm.median_days_between_orders,

    st.effective_cadence_days,

    CASE
        WHEN cm.avg_weekly_consumption IS NOT NULL
         AND st.effective_cadence_days IS NOT NULL
        THEN (
            cm.avg_weekly_consumption
            * (st.effective_cadence_days / 7.0)
        )::numeric(12,3)
        ELSE NULL
    END                AS suggested_order_qty,

    -- Pricing advisory deferred — awaiting certified pipeline
    NULL::text         AS primary_supplier,
    NULL::numeric      AS primary_unit_cost,
    NULL::numeric      AS monthly_savings_potential

FROM product_master pm

JOIN v_consumption_metrics_365d cm
    ON cm.product_code::text = pm.code::text

JOIN v_product_consumption_state_effective st
    ON st.product_code = pm.code::text

WHERE pm.is_active = true

ORDER BY cm.avg_monthly_consumption DESC;
```
