# Hyde Procurement Intelligence

A production-grade, scalable procurement intelligence system built to solve 
a real operational problem - a hospitality kitchen with no reliable 
system for tracking supplier spend, product consumption, or ordering 
decisions.

Built entirely from scratch. Running on live business data.

> Built by a Kitchen Manager who experienced the operational 
> friction directly — and couldn't find a system that solved it 
> properly, so built one from scratch.

## The Problem

Independent SMB restaurants operate with significant information 
asymmetry but it tends to stay fragmented. 

Supplier invoices contain rich data - spend patterns, 
price drift, consumption velocity, supplier dependency - but no 
system surfaces it. Ordering decisions are made from memory and 
habit rather than evidence and math.

Hyde was built to close that gap.

## What Hyde Does

- Processes and normalises supplier invoice data into a canonical 
  data model
- Tracks 400+ product identities across multiple suppliers and 
  1,050+ supplier SKUs
- Surfaces executive spend analytics - monthly trends, supplier 
  distribution, category seasonality, YoY comparisons
- Generates behavioural replenishment recommendations using rolling 
  365-day consumption modelling and anomaly detection
- Detects structural demand shifts vs temporary purchasing anomalies

## Scale

- £43,000+ supplier spend processed
- 4,700+ real procurement transactions
- 400+ canonical product entities
- 1,134 packaging-to-canonical unit mappings
- 97% normalisation coverage

## Architecture

The system is built on a strict layered pipeline:

RAW → MASTER → NORMALIZED → CERTIFICATION → TRUTH → 
TEMPORAL MODEL → BEHAVIOURAL STATE → BEHAVIOURAL MODELLING → 
BLUEPRINT → EXECUTION → ANALYSIS

Each layer has a single responsibility. No layer contaminates 
another. The entire behavioural state is deterministically 
rebuildable from canonical truth.

## Stack

- PostgreSQL / Supabase — data layer
- SQL views — all analytical and behavioural logic
- Next.js — operational frontend
- Power BI — executive reporting layer

## Key Technical Decisions

**Canonical identity over supplier SKUs** — suppliers assign 
arbitrary SKUs to the same physical product. Hyde consolidates 
these into stable product identities, enabling consistent tracking 
across suppliers and over time.

**Physical unit normalisation** — all quantities resolve to 
physical base units (kg, L, units, m, m2). Pack abstractions are forbidden 
in canonical truth. This prevents silent comparison errors when 
supplier packaging changes.

**Behavioural ordering over static reorder points** — the 
replenishment engine uses rolling consumption metrics and anomaly 
detection to distinguish temporary bulk purchases from genuine 
demand shifts, avoiding false baseline recalibration.

**Certification gate** — only verified unit mappings enter 
canonical truth. Unverified mappings are excluded from all 
production analytics, preventing silent data quality drift.
