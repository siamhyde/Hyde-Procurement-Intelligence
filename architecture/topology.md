# SUPABASE BACKEND TOPOLOGY MANIFEST — v2.3

**Production Locked — Behavioural Ordering + Pricing Intelligence Engine**

**System:** Hyde Procurement Intelligence

**Status:** Production Stabilised

**Architecture Type:** Deterministic behavioural procurement engine with invoice-derived pricing intelligence

**Pricing Advisory:** Active — invoice-derived, regime-aware, deterministically rebuildable

---

## 1. Authoritative Tables

### `public.financial_historical_imports`

**Layer:** RAW
**Purpose:** Immutable supplier transaction log. Represents literal supplier reality.

**Core Fields:**

* `id`
* `order_date`
* `supplier`
* `sku`
* `item_name`
* `unit_size`
* `quantity`
* `unit_cost`
* `total_cost`
* `product_code` *(nullable until hydration)*
* `lead_time_override_days` *(nullable)*

**Constraints:**

* No transformation
* No canonical quantities
* No behavioural or pricing logic

---

### `public.product_master`

**Layer:** MASTER (Identity + Taxonomy)
Canonical product identity authority.

**Fields:**

* `code` *(product_code — immutable)*
* `product_name`
* `category`
* `subcategory`
* `department`
* `base_unit`
* `is_active`
* `description`
* `notes`
* `timestamps`

**Excludes:**

* Supplier mappings
* Packaging conversions
* Behavioural logic

---

### `public.unit_mappings`

**Layer:** NORMALISATION
Deterministic packaging → canonical conversion layer.

**Key:** `(product_code, supplier, sku, unit_size)`

**Fields:**

* `product_code`
* `supplier`
* `sku`
* `unit_size`
* `multiplier`
* `base_unit`
* `verified`
* `notes`
* `timestamps`

**Note:** All physical modelling lives here exclusively.

---

### `public.supplier_settings`

**Layer:** Behavioural Metadata

**Fields:**

* `client_id`
* `supplier`
* `lead_time_days`
* `timestamps`

Used for:

* Default lead-time offsets
* Cadence modelling adjustments

Never mutates RAW data.

---

### `public.product_consumption_state`

**Layer:** Behavioural Memory

Tracks adaptive consumption baseline per product.

**Rebuild:** `fn_rebuild_product_consumption_state()`

**Fields:**

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
* `regime_change_detected_at`
* `baseline_version`
* `last_processed_order_date`
* `updated_at`

**Notes:**

* Fully deterministic
* No manual edits required
* Reads from `v_truth_canonical`

---

### `public.product_pricing_state` *(NEW — v2.3)*

**Layer:** Pricing Memory

Adaptive pricing baseline per product + supplier.

**Key:** `(client_id, product_code, supplier)`

**Rebuild:** `fn_rebuild_product_pricing_state()`

**Fields:**

* `id`
* `client_id`
* `product_code`
* `supplier`
* `baseline_unit_cost`
* `last_observed_cost`
* `last_order_date`
* `last_anomaly_ratio`
* `consecutive_elevated_prices`
* `consecutive_low_prices`
* `regime_change_detected_at`
* `baseline_price_version`
* `last_processed_order_date`
* `updated_at`

**Source:** `financial_historical_imports.unit_cost`

---

### `public.ordering_system_snapshots` *(NEW — v2.3)*

**Layer:** System Assertion Log

Append-only record of system decisions.

**Fields:**

* `id`
* `client_id`
* `snapshot_date`
* `period_week_start`
* `product_code`
* `supplier`
* `sku`
* `suggested_order_packs`
* `estimated_line_cost`
* `baseline_qty`
* `baseline_cadence_days`
* `baseline_version`
* `baseline_unit_cost`
* `baseline_price_version`
* `regime_change_flag`
* `price_regime_flag`
* `created_at`

**Filter Conditions:**

```sql
order_lines_365d >= 12
AND days_since_last_order / median_cadence <= 2.5
```

---

### `public.supplier_current_prices`

**Layer:** Dormant Infrastructure

* Not used in production
* Superseded by `product_pricing_state`
* Safe to ignore

---

## 2. Authoritative Views

### `v_canonical_imports`

Normalised event layer
→ Applies unit conversions

---

### `v_certified_mappings`

Certification gate
→ Filters verified mappings only

---

### `v_truth_canonical`

Certified consumption + spend dataset

Produces:

* `canonical_quantity`
* `canonical_unit`
* `supplier`
* `sku`
* `unit_cost`
* `total_cost`
* `lead_time_override_days`

---

### `v_consumption_metrics_365d`

Behavioural aggregation layer

Outputs:

* `total_consumption_365d`
* `avg_monthly_consumption`
* `avg_weekly_consumption`
* `order_lines_365d`
* `total_orders`
* `avg_days_between_orders`
* `median_days_between_orders`

---

### `v_supplier_preference_365d`

Habit inference

Outputs:

* `preferred_supplier`
* `preference_confidence`
* `preferred_supplier_order_share`
* `preferred_supplier_last_order_date`

---

### `v_product_consumption_state_effective`

Behavioural state adapter

Combines:

* consumption metrics
* behavioural state

---

### `v_unit_mapping_preferred`

Packaging selector

---

### `v_order_blueprint_behavioural`

Core ordering intelligence

**Excludes:**

* Pricing comparison
* Supplier optimisation
* Savings modelling

---

### `v_order_execution_plan` *(Updated — v2.3)*

Execution translation layer

**Adds:**

* Supplier preference
* SKU metadata
* Pricing from `product_pricing_state`

**Key Logic:**

```sql
primary_unit_cost = baseline_unit_cost
estimated_order_cost = CEILING(qty / units_per_pack) * baseline_unit_cost
```

---

### `v_order_execution_plan_habit`

Frontend source view

---

### `v_snapshot_monthly_suggested` *(NEW — v2.3)*

Aggregated system assertions

Outputs:

* `month`
* `suggested_spend`
* `snapshot_count`
* `any_consumption_regime_change`
* `any_price_regime_change`

---

## 3. Executive Reporting Views

* `v_monthly_spend_certified`
* `v_month_projection_v2`
* `v_monthly_spend_comparison_v2`

---

## 4. Authoritative Functions

### `fn_rebuild_product_consumption_state()`

Hardcoded thresholds:

* `min_orders_for_baseline = 12`
* `elevated_ratio = 2.0`
* `low_ratio = 0.5`
* `regime_confirm_n = 3`

---

### `fn_rebuild_product_pricing_state()` *(NEW — v2.3)*

Hardcoded thresholds:

* `min_orders_for_baseline = 12`
* `elevated_ratio = 1.5`
* `low_ratio = 0.7`
* `regime_confirm_n = 3`

---

## 5. Production Execution Spine

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

---

## 6. Pricing Intelligence Spine *(NEW — v2.3)*

```
financial_historical_imports (unit_cost)
→ fn_bootstrap_product_pricing_state
→ fn_apply_adaptive_pricing
→ product_pricing_state
→ v_order_execution_plan
```

---

## 7. System Assertion Spine *(NEW — v2.3)*

```
v_order_execution_plan_habit
+ product_consumption_state
+ product_pricing_state
+ v_consumption_metrics_365d
→ ordering_system_snapshots
→ v_snapshot_monthly_suggested
```

---

## 8. Executive Reporting Spine

```
v_truth_canonical
→ v_monthly_spend_certified
→ v_month_projection_v2
→ v_monthly_spend_comparison_v2
→ v_snapshot_monthly_suggested
```

---

## 9. Import Cycle Workflow

Run in order after every import:

1. Import RAW → `financial_historical_imports`
2. Product code propagation
3. Attribute hydration
4. `SELECT fn_rebuild_product_consumption_state();`
5. `SELECT fn_rebuild_product_pricing_state();`
6. Run snapshot SQL

**Critical:**
Skipping steps 4–5 freezes system intelligence.

---

## 10. Topology Rule

Any object not listed:

* Experimental
* Deprecated
* Not guaranteed stable
* Removable

**Special Rule:**

* `ordering_system_snapshots` is **append-only**
* Never truncate outside full system reset

---
