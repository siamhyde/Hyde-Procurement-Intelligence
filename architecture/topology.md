SUPABASE BACKEND TOPOLOGY MANIFEST — v2.3
Production Locked — Behavioural Ordering + Pricing Intelligence Engine

System: Hyde Procurement Intelligence
Status: Production Stabilised
Architecture Type: Deterministic behavioural procurement engine with invoice-derived pricing intelligence
Pricing advisory: Active — invoice-derived, regime-aware, deterministically rebuildable

1. Authoritative Tables

public.financial_historical_imports
Layer: RAW
Purpose: Immutable supplier transaction log. Represents literal supplier reality. No transformation occurs here.

Core fields:
•	id
•	order_date
•	supplier
•	sku
•	item_name
•	unit_size
•	quantity
•	unit_cost
•	total_cost
•	product_code (nullable until hydration)
•	lead_time_override_days (nullable)

RAW explicitly does NOT contain: canonical quantities, conversion logic, behavioural logic, category modelling, consumption modelling.
RAW must remain a literal supplier event log.

public.product_master
Layer: MASTER (Identity + Taxonomy)
Canonical product identity authority. Defines the permanent product identity used across all suppliers.

Fields: code (product_code — immutable), product_name, category, subcategory, department, base_unit, is_active, description, notes, timestamps.
Does NOT contain: supplier mappings, packaging conversions, behavioural logic.

public.unit_mappings
Layer: NORMALISATION
Deterministic packaging → canonical conversion layer.
Binding key: product_code + supplier + sku + unit_size
Fields: product_code, supplier, sku, unit_size, multiplier, base_unit, verified, notes, timestamps.
All physical modelling exists here. Conversion logic does not exist anywhere else.

public.supplier_settings
Layer: Behavioural Metadata
Stores supplier default operational metadata. Used for: default lead-time offsets, cadence modelling adjustments.
Fields: client_id, supplier, lead_time_days, timestamps.
Never mutates RAW data.

public.product_consumption_state
Layer: Behavioural Memory
Adaptive behavioural baseline state per product. Tracks regime shifts, anomalies, and cadence adaptation. Fully rebuildable deterministically.

Fields: client_id, product_code, baseline_qty, baseline_cadence_days, last_order_date, last_order_qty, last_anomaly_ratio, consecutive_elevated_orders, consecutive_low_orders, adjusted_next_order_days, anomaly_adjusted_until_date, regime_change_detected_at, baseline_version, last_processed_order_date, updated_at.

Rebuildable via fn_rebuild_product_consumption_state(). No manual edits required.

Note: fn_bootstrap_product_consumption_state() and fn_apply_adaptive_baseline() read directly from v_truth_canonical. Hardcoded thresholds are the authoritative config — no external config table exists.

public.product_pricing_state
Layer: Pricing Memory (NEW — v2.3)
Adaptive pricing baseline state per product per supplier. Mirrors the consumption state architecture applied to unit cost. Fully rebuildable deterministically.

Keyed on: client_id + product_code + supplier

Fields: id, client_id, product_code, supplier, baseline_unit_cost, last_observed_cost, last_order_date, last_anomaly_ratio, consecutive_elevated_prices, consecutive_low_prices, regime_change_detected_at, baseline_price_version, last_processed_order_date, updated_at.

Rebuildable via fn_rebuild_product_pricing_state(). No manual edits required.
Reads directly from financial_historical_imports.unit_cost — not from v_truth_canonical.

public.ordering_system_snapshots
Layer: System Assertion Log (NEW — v2.3)
Permanent append-only record of the ordering system's assertions. Written manually at end of each import cycle. Never truncated outside a full system reset.

Fields: id, client_id, snapshot_date, period_week_start, product_code, supplier, sku, suggested_order_packs, estimated_line_cost, baseline_qty, baseline_cadence_days, baseline_version, baseline_unit_cost, baseline_price_version, regime_change_flag, price_regime_flag, created_at.

Filters at snapshot time: order_lines_365d >= 12 AND days_since_last_order / median_cadence <= 2.5. Mirrors ordering frontend exactly.

public.supplier_current_prices
Layer: Dormant Infrastructure
Not used by any production views. Retained for historical reference. The pricing intelligence pipeline originally deferred to this table has now been delivered via product_pricing_state — using invoice-derived baselines rather than manual price snapshots.
This table may be safely ignored.

2. Authoritative Views

public.v_canonical_imports
Normalised Event Layer
Applies deterministic packaging conversion to RAW rows using unit_mappings. Produces: canonical_quantity, canonical_unit, lead_time_override_days (passthrough). Not certification gated. Structural normalisation only.

public.v_certified_mappings
Certification Gate
Defines which mappings are production-safe. Prevents uncertified mappings from entering production analytics. Used by the canonical truth layer.

public.v_truth_canonical
Certified Canonical Truth
Certified consumption and spend layer. Includes only rows with verified mappings. Carries row-level temporal override metadata forward.
Produces: canonical_quantity, canonical_unit, supplier, sku, unit_cost, total_cost, lead_time_override_days.
This is the authoritative consumption and spend dataset.

public.v_consumption_metrics_365d
Behavioural Aggregation Layer
Lead-time adjusted rolling behavioural metrics.
Produces: total_consumption_365d, avg_monthly_consumption, avg_weekly_consumption, order_lines_365d, total_orders, avg_days_between_orders, median_days_between_orders.

public.v_supplier_preference_365d
Habit Inference Layer
Determines preferred supplier behaviourally. Produces: preferred_supplier, preference_confidence, preferred_supplier_order_share, preferred_supplier_last_order_date.

public.v_product_consumption_state_effective
Behavioural State Adapter
Combines behavioural baseline memory with rolling consumption metrics. Provides: effective cadence, anomaly-adjusted cadence, behavioural overrides. Used by the blueprint layer.

public.v_unit_mapping_preferred
Packaging Selector
Selects preferred packaging mapping per supplier/product. Used during execution translation. Ensures deterministic pack conversion.

public.v_order_blueprint_behavioural
Behavioural Ordering Intelligence
Core intelligence layer. Calculates canonical reorder quantity based on rolling consumption metrics, adaptive behavioural baseline, and cadence modelling.
Explicitly excludes: pricing comparison, supplier optimisation, savings modelling, optimal supplier ranking.

public.v_order_execution_plan
Execution Translation Layer (Updated — v2.3)
Bridges behavioural blueprint to supplier execution logic.
Responsibilities:
•	attach supplier preference
•	attach SKU metadata
•	attach invoice-derived pricing from product_pricing_state
•	produce primary_unit_cost and estimated_order_cost

primary_unit_cost = product_pricing_state.baseline_unit_cost for preferred supplier.
estimated_order_cost = CEILING(suggested_qty / units_per_pack) × baseline_unit_cost.
LEFT JOIN to product_pricing_state — rows without pricing state return null costs rather than erroring.

public.v_order_execution_plan_habit
Execution Layer (Frontend Source)
Primary ordering view consumed by the ordering frontend. Passthrough from v_order_execution_plan. Now produces real primary_unit_cost and estimated_order_cost.

public.v_snapshot_monthly_suggested
System Assertion Aggregation (NEW — v2.3)
Aggregates ordering_system_snapshots to monthly suggested spend totals. Consumed by the executive dashboard as the system assertion line on the Spend Rhythm chart.
Produces: month, suggested_spend, snapshot_count, any_consumption_regime_change, any_price_regime_change.

3. Executive Reporting Views

public.v_monthly_spend_certified
Monthly spend aggregation built on canonical truth. Produces: total_spend, order_count, supplier_count. Used by executive dashboard.

public.v_month_projection_v2
Current month projection. Produces: spend_to_date, avg_daily_spend, projected_month_spend, same_month_last_year, days_elapsed, days_in_month.

public.v_monthly_spend_comparison_v2
Year-over-year monthly comparison. Produces: spend_this_year, spend_last_year, delta, delta_pct, order_count, supplier_count.

4. Authoritative Functions

public.fn_rebuild_product_consumption_state()
Rebuilds consumption behavioural memory deterministically. Calls fn_bootstrap_product_consumption_state() then fn_apply_adaptive_baseline().
Both sub-functions read directly from v_truth_canonical — no external dependencies.
Behavioural thresholds hardcoded in fn_apply_adaptive_baseline():
•	min_orders_for_baseline = 12
•	elevated_ratio = 2.0
•	low_ratio = 0.5
•	anomaly_high_ratio = 2.0
•	cadence_within_mult = 1.5
•	regime_confirm_n = 3
•	recent_event_count = 5
•	max_extension_days_cap = 180

public.fn_rebuild_product_pricing_state()
NEW — v2.3
Rebuilds pricing state deterministically. Calls fn_bootstrap_product_pricing_state() then fn_apply_adaptive_pricing().
Both sub-functions read directly from financial_historical_imports.unit_cost.
Pricing thresholds hardcoded in fn_apply_adaptive_pricing():
•	min_orders_for_baseline = 12
•	elevated_ratio = 1.5
•	low_ratio = 0.7
•	regime_confirm_n = 3
•	recent_event_count = 5

5. Production Execution Spine

financial_historical_imports
→ v_canonical_imports
→ v_certified_mappings
→ v_truth_canonical
→ v_consumption_metrics_365d
→ v_supplier_preference_365d
→ v_product_consumption_state_effective
→ v_order_blueprint_behavioural
→ v_order_execution_plan  (+ product_pricing_state)
→ v_order_execution_plan_habit

This chain is: deterministic, behavioural, rebuildable, supplier-agnostic at modelling layer, supplier-aware at execution layer.

6. Pricing Intelligence Spine
NEW — v2.3

financial_historical_imports (unit_cost)
→ fn_bootstrap_product_pricing_state
→ fn_apply_adaptive_pricing
→ product_pricing_state
→ v_order_execution_plan (primary_unit_cost, estimated_order_cost)

Fully rebuildable. Regime-aware. Invoice-derived. No manual price inputs.

7. System Assertion Spine
NEW — v2.3

v_order_execution_plan_habit
+ product_consumption_state
+ product_pricing_state
+ v_consumption_metrics_365d
→ ordering_system_snapshots  (manual, per import cycle)
→ v_snapshot_monthly_suggested

The snapshot SQL is run manually at the end of each import cycle. It captures the system's assertion at that moment — what it suggested, at what cost, in what behavioural and pricing state.

8. Executive Reporting Spine

v_truth_canonical
→ v_monthly_spend_certified          (actual spend bars)
→ v_month_projection_v2
→ v_monthly_spend_comparison_v2
→ v_snapshot_monthly_suggested       (system assertion line)

Provides accurate spend reporting alongside system assertion intelligence.

9. Import Cycle Workflow
Authoritative sequence — run in order after every import

Step 1 — Import raw data into financial_historical_imports
Step 2 — Run product_code propagation (hydration block 1)
Step 3 — Run attribute hydration (hydration block 2)
Step 4 — SELECT fn_rebuild_product_consumption_state();
Step 5 — SELECT fn_rebuild_product_pricing_state();
Step 6 — Run snapshot SQL (at end of weekly import cycle)

Steps 4 and 5 are mandatory after every import. Without them, behavioural and pricing state will not reflect new data. The ordering system runs on frozen state if these are skipped.

10. Topology Rule

Any object not listed in this document:
•	is experimental
•	is deprecated
•	is not guaranteed stable
•	may be safely considered removable

ordering_system_snapshots is append-only. It must never be truncated outside of a full system reset.

This document defines the locked production architecture.
