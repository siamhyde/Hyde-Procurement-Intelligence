The following document defines the exact production schema of the system described in the constitutional doctrine.

---

# SUPABASE BACKEND TOPOLOGY MANIFEST — v2.2

## (Production Locked — Behavioural Ordering Engine)

**System:** Hyde Procurement Intelligence
**Status:** Production Stabilised
**Architecture Type:** Deterministic behavioural procurement engine
**Pricing advisory:** Deferred (not part of production topology)

---

# 1️⃣ Authoritative Tables

---

## `public.financial_historical_imports`

### Layer: RAW

**Purpose:** Immutable supplier transaction log.

Represents literal supplier reality. No transformation occurs here.

**Core fields**

* `id`
* `order_date`
* `supplier`
* `sku`
* `item_name`
* `unit_size`
* `quantity`
* `unit_cost`
* `total_cost`
* `product_code` (nullable until hydration)

**RAW explicitly does NOT contain**

* canonical quantities
* conversion logic
* behavioural logic
* category modelling
* consumption modelling

RAW must remain a literal supplier event log.

---

## `public.product_master`

### Layer: MASTER (Identity + Taxonomy)

Canonical product identity authority.

Defines the permanent product identity used across all suppliers.

**Fields**

* `code` (product_code — immutable)
* `product_name`
* `category`
* `subcategory`
* `department`
* `base_unit`
* `is_active`
* `description`
* `notes`
* timestamps

**Does NOT contain**

* supplier mappings
* packaging conversions
* behavioural logic

Identity lives only here.

---

## `public.unit_mappings`

### Layer: NORMALISATION

Deterministic packaging → canonical conversion layer.

Defines how supplier packaging translates to canonical units.

**Binding key**

```
product_code + supplier + sku + unit_size
```

**Fields**

* `product_code`
* `supplier`
* `sku`
* `unit_size`
* `multiplier`
* `base_unit`
* `verified`
* `notes`
* timestamps

All physical modelling exists here.

Conversion logic does not exist anywhere else.

---

## `public.supplier_settings`

### Layer: Behavioural Metadata

Stores supplier operational metadata.

Currently used for:

* lead-time offsets
* cadence modelling adjustments

**Fields**

* `client_id`
* `supplier`
* `lead_time_days`
* timestamps

Never mutates RAW data.

---

## `public.product_consumption_state`

### Layer: Behavioural Memory

Adaptive behavioural baseline state per product.

Tracks regime shifts, anomalies, and cadence adaptation.

Fully rebuildable deterministically.

**Fields**

* `client_id`
* `product_code`
* `baseline_qty`
* `baseline_cadence_days`
* `last_order_date`
* `last_order_qty`
* `last_anomaly_ratio`
* `consecutive_elevated_orders`
* `consecutive_low_orders`
* `adjusted_next_order_days`
* `anomaly_adjusted_until_date`
* `is_anomaly_adjusted`
* `effective_cadence_days`
* `regime_change_detected_at`
* `baseline_version`
* `updated_at`

Rebuildable via function.

No manual edits required.

---

## `public.supplier_current_prices`

### Layer: Dormant Infrastructure

Currently **not used by any production views**.

Retained for a future **certified pricing intelligence pipeline**.

Pricing advisory was intentionally removed from production due to drift risk from manual price snapshots.

Future pricing pipeline will rely on:

* invoice-derived baselines
* automatic price drift detection
* deterministic rebuildability

Until that system exists, this table remains dormant.

---

# 2️⃣ Authoritative Views

---

## `public.v_canonical_imports`

### Normalised Event Layer

Applies deterministic packaging conversion to RAW rows using `unit_mappings`.

Produces:

* `canonical_quantity`
* `canonical_unit`

Not certification gated.

Purpose: structural normalisation only.

---

## `public.v_certified_mappings`

### Certification Gate

Defines which mappings are **production-safe**.

Prevents uncertified mappings from entering production analytics.

Used by the canonical truth layer.

---

## `public.v_truth_canonical`

### Certified Canonical Truth

Certified consumption and spend layer.

Includes only rows with verified mappings.

Produces:

* canonical_quantity
* canonical_unit
* supplier
* sku
* unit_cost
* total_cost

Category-scoped using `product_master`.

This is the authoritative consumption and spend dataset.

---

## `public.v_consumption_metrics_365d`

### Behavioural Aggregation Layer

Lead-time adjusted rolling behavioural metrics.

Uses:

```
order_date - lead_time_days
```

Produces:

* `total_consumption_365d`
* `avg_monthly_consumption`
* `avg_weekly_consumption`
* `order_lines_365d`
* `total_orders`
* `avg_days_between_orders`
* `median_days_between_orders`

Supplier-agnostic modelling.

---

## `public.v_supplier_preference_365d`

### Habit Inference Layer

Determines preferred supplier behaviourally.

Produces:

* `preferred_supplier`
* `preference_confidence`
* `preferred_supplier_order_share`
* `preferred_supplier_last_order_date`

Derived purely from historical behaviour.

---

## `public.v_product_consumption_state_effective`

### Behavioural State Adapter

Combines behavioural baseline memory with rolling consumption metrics.

Provides:

* effective cadence
* anomaly-adjusted cadence
* behavioural overrides

Used by the blueprint layer.

---

## `public.v_unit_mapping_preferred`

### Packaging Selector

Selects preferred packaging mapping per supplier/product.

Used during execution translation.

Ensures deterministic pack conversion.

---

## `public.v_order_blueprint_behavioural`

### Behavioural Ordering Intelligence

Core intelligence layer.

Calculates canonical reorder quantity based on:

* rolling consumption metrics
* adaptive behavioural baseline
* cadence modelling

Produces:

* `suggested_order_qty` (canonical)
* behavioural context fields
* cadence fields

Explicitly excludes:

* pricing comparison
* supplier optimisation
* savings modelling
* optimal supplier ranking

Behavioural ordering only.

---

## `public.v_order_execution_plan`

### Execution Translation Layer

Bridges behavioural blueprint to supplier execution logic.

Responsibilities:

* attach supplier preference
* attach SKU metadata
* prepare execution fields

Feeds execution view.

---

## `public.v_order_execution_plan_habit`

### Execution Layer (Frontend Source)

Primary ordering view consumed by the frontend.

Translates canonical quantities into supplier pack quantities.

Uses:

* behavioural supplier preference
* SKU metadata
* unit_mappings

Produces:

* `supplier`
* `sku`
* `unit_size`
* `suggested_canonical_qty`
* `suggested_order_packs`
* `execution_canonical_qty`

This is the production ordering output.

---

# 3️⃣ Executive Reporting Views

---

## `public.v_monthly_spend_certified`

Monthly spend aggregation built on canonical truth.

Produces:

* `total_spend`
* `order_count`
* `supplier_count`

Used by executive dashboard.

---

## `public.v_month_projection_v2`

Current month projection.

Produces:

* `spend_to_date`
* `avg_daily_spend`
* `projected_month_spend`
* `same_month_last_year`
* `days_elapsed`
* `days_in_month`

Pure descriptive analytics.

---

## `public.v_monthly_spend_comparison_v2`

Year-over-year monthly comparison.

Produces:

* `spend_this_year`
* `spend_last_year`
* `delta`
* `delta_pct`
* `order_count`
* `supplier_count`

---

# 4️⃣ Authoritative Functions

---

## `public.fn_rebuild_product_consumption_state()`

Rebuilds behavioural memory deterministically from canonical truth.

Used for:

* bootstrap
* structural changes
* anomaly reset
* recovery

---

# 5️⃣ Deferred Architecture: Pricing Intelligence

Pricing advisory is intentionally excluded from the production topology.

Manual price snapshots introduce silent drift and unreliable optimisation signals.

Future pricing pipeline will require:

* invoice-derived price baselines
* automated price drift detection
* deterministic rebuildability
* regime-aware pricing state

Until that system exists, pricing advisory is not part of production logic.

---

# 6️⃣ Production Execution Spine

```
financial_historical_imports
→ v_canonical_imports
→ v_certified_mappings
→ v_truth_canonical
→ v_consumption_metrics_365d
→ v_supplier_preference_365d
→ v_product_consumption_state_effective
→ v_order_blueprint_behavioural
→ v_order_execution_plan
→ v_order_execution_plan_habit
```

This chain is:

* deterministic
* behavioural
* rebuildable
* supplier-agnostic at modelling layer
* supplier-aware at execution layer

---

# 7️⃣ Executive Reporting Spine

```
v_truth_canonical
→ v_monthly_spend_certified
→ v_month_projection_v2
→ v_monthly_spend_comparison_v2
```

Provides accurate spend reporting without optimisation assumptions.

---

# 8️⃣ Topology Rule

Any object not listed in this document:

* is experimental
* is deprecated
* is not guaranteed stable
* may be safely considered removable

This document defines the locked production architecture.

---

