# Hyde Procurement Intelligence

A dbt-based data pipeline built on PostgreSQL (Supabase) that transforms fragmented supplier invoice data into a tested, deterministic dataset for procurement analysis, with explicit handling of unresolved records.

I was a Kitchen Manager in a hospitality environment where procurement decisions were made from memory and habit. This project was built from that environment to replace intuition with a deterministic, rebuildable analytical foundation.

Built on real operational data, the system standardises product identity, normalises units, and enforces a clear boundary between **trusted data and excluded data**.

The focus of the project is not just data transformation, but defining what data is trustworthy and why.

---

## What This Project Does

Procurement data in small businesses is typically fragmented:

* inconsistent product naming across suppliers
* varying pack sizes and units
* missing or unreliable mappings

This project builds a structured pipeline that:

* consolidates supplier data into **canonical product identities**
* converts all quantities into **standard physical units (kg, L, units, etc.)**
* enforces **data quality rules before data is considered “truth”**
* surfaces **why records fail to meet those rules**

The result is a dataset that can be safely used for analysis, forecasting, and decision-making.

---

## Pipeline Overview

The system is built as a layered dbt pipeline:

```
RAW → NORMALIZED → CERTIFIED → TRUTH
```

**RAW**
Stores supplier data exactly as received (no transformation, full fidelity).

**NORMALIZED**
Applies deterministic mappings to:

* resolve product identity
* convert quantities into canonical units

**CERTIFIED**
Filters to **only mappings explicitly marked as verified.**
This acts as a **data quality gate** before anything reaches production use.

**TRUTH**
Final, trusted dataset:

* fully resolved product identity
* canonical quantities and units
* safe for downstream analysis

Any row that does not meet these conditions is excluded from this layer.

---

## Key Technical Features

### Deterministic Transformations

All transformations are implemented as explicit dbt models:

* no hidden logic
* no manual overrides in downstream layers
* fully reproducible from raw inputs

---

### Data Quality Enforcement (dbt tests)

The truth layer enforces strict guarantees:

* `not_null` constraints on key fields
* referential integrity between products and transactions
* (optional) controlled unit domains

Only data that passes these checks is exposed as “truth”.

---

### Certification Gate

A key design decision:

> **Unverified mappings are not allowed into the truth layer**

Even if a conversion *could* be inferred, it is excluded unless explicitly verified.

This prevents silent data corruption and ensures:

* consistency over time
* trust in downstream metrics

---

### Separation of Truth vs Unresolved Data

Instead of forcing all data into a “clean” dataset, the system explicitly separates:

* **Trusted data** → `mart_truth_canonical`
* **Unresolved data** → `mart_unresolved_imports`

This avoids hidden data loss and makes data quality issues visible.

---

## Diagnostic Layer: Unresolved Imports

The model `mart_unresolved_imports` captures all rows that fail to reach the truth layer and assigns a clear exclusion reason.

Example categories:

* `NO_PRODUCT_CODE`
* `NO_CANONICAL_RECORD`
* `UNVERIFIED_MAPPING`
* `NO_CANONICAL_QUANTITY`
* `NO_CANONICAL_UNIT`

This turns data quality from a hidden problem into a **queryable dataset**.

This model ensures that excluded data is not lost, but instead becomes part of the system’s observability.

---

## Repository Guide

Key dbt models:

- `int_canonical_imports` — deterministic unit normalisation  
- `int_certified_canonical` — certification gate (verified mappings only)  
- `mart_truth_canonical` — final trusted dataset  
- `mart_unresolved_imports` — diagnostic layer for excluded rows  

Documentation and tests:

- `schema.yml` — model documentation and data quality tests (`not_null`, `relationships`)

---

## Evidence: dbt Models and Data Quality

These snippets illustrate how data quality rules and failure modes are explicitly modelled within the pipeline.

Example diagnostic logic from `mart_unresolved_imports`:

```sql
case
    when r.product_code is null then 'NO_PRODUCT_CODE'
    when c.id is null then 'NO_CANONICAL_RECORD'
    when c.verified is distinct from true then 'UNVERIFIED_MAPPING'
    when c.canonical_quantity is null then 'NO_CANONICAL_QUANTITY'
    when c.canonical_unit is null then 'NO_CANONICAL_UNIT'
    else 'UNKNOWN_EXCLUSION'
end as exclusion_reason
```
Example truth-layer tests from `schema.yml`:

```sql

- name: product_code
  tests:
    - not_null
    - relationships:
        to: ref('stg_product_master')
        field: product_code

- name: canonical_quantity
  tests:
    - not_null

```
---

## Example Insight

The unresolved layer revealed that most failures were not caused by pipeline errors, but by:

> **missing or unverified unit mappings**

This reflects a common real-world issue:

* data pipelines often fail due to **incomplete domain knowledge**, not technical faults

By separating these cases, the system makes it clear where:

* engineering fixes are needed
* operational/data governance work is required

---

## Scale

Built on real operational data:

| Metric                     | Value    |
| -------------------------- | -------- |
| Supplier spend processed   | £43,000+ |
| Procurement transactions   | 4,700+   |
| Canonical product entities | 400+     |
| Packaging-to-unit mappings | 1,134    |
| Normalisation coverage     | 97%      |

---

## Context

This project originated from a real hospitality environment where procurement decisions were made using fragmented supplier data and manual processes.

The goal was to replace intuition-driven ordering with a reliable, system-generated baseline, built from historical purchasing data.

As the system evolved, it moved from spreadsheet-based tooling to a structured backend built on PostgreSQL (Supabase), with dbt used to formalise the transformation pipeline and enforce data quality.

---

## Stack

| Layer          | Technology            |
| -------------- | --------------------- |
| Data warehouse | PostgreSQL (Supabase) |
| Transformation | dbt                   |
| Query layer    | SQL                   |
| Frontend       | Next.js               |
| Reporting      | Power BI              |

---

## Example Output

Example interface built on the truth-layer dataset, showing canonicalised procurement data across categories and time:

![Category Mix]<img width="1789" height="819" alt="1f9be50be16d5a3ec350ead717d4fd51" src="https://github.com/user-attachments/assets/36d1005c-5d62-422f-b8b5-14ac11d287d2" />

