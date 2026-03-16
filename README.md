# Hyde Procurement Intelligence

I was the Kitchen Manager. I lived the friction firsthand.

Operating under uncertainty is the norm: 
trying to make sure the kitchen has enough for the week, avoiding under-ordering, avoiding over-ordering, 
and making decisions fast in an environment that rarely gives you clean signals.

In hospitality SMBs, you are focused on surviving, not optimising.

> Systems substituted with intuition.  
> Decisions made from memory, habit and experience.

The data to do better already exists. 
It is buried across supplier invoices, fragmented by product naming, pack sizes, and supplier-specific formats.

Hyde is the system I built to turn that fragmented purchasing data into a deterministic procurement baseline.

---

## The Problem

In a kitchen, the absence of a system is felt every week:

- Working out whether you have enough for Saturday service. 
- Whether this week's order should look like last week's.
- Suppliers who sell the same product in different formats.

Something as arbitrary as cheddar cheese becomes harder to reason about than it should be:

One supplier sells 450g, 500g, or 750g packs. Another sells a 4.5kg block. 
Without a baseline, every change forces the operator to recalculate quantities in their head.

That does not just create stress, It prevents the business from accumulating reliable purchasing intelligence. 
Decisions stay trapped in memory, habit, and whoever happens to know the operation best.

In an industry with high staff churn, that becomes a structural vulnerability. 
When knowledge lives inside people instead of systems, each handover risks resetting the kitchen back to intuition.

Now multiply that across 400 products, 3 suppliers, and 4,700 transactions.

---

## What Hyde Does

I built this not to replace the operator — but to replace the void.

The head chef knows more than any system — the regulars 
who order the special, the event next Saturday, the 
supplier whose quality has been slipping. That knowledge 
is irreplaceable.

But ask him how many units of tofu he consumes on average 
per week. His exact reorder cadence mathematically. Whether 
consumption has been trending upward. Whether three 
consecutive elevated orders represent a new baseline or 
just a noisy month.

He can't answer that. Not precisely. Not consistently.
Hyde can.

I deliberately built this to not step on experience —
instead, it boringly hides underneath it.
A deterministic baseline built from math.

When he leaves — which in hospitality, he will —
the system doesn't leave with him. The next person 
inherits a foundation instead of starting from zero.

> That's the actual boring problem Hyde solves.

---

## The Build

Hyde started on Google Sheets, then Coda, then Bubble.
Each rebuilt from scratch when the foundation proved wrong.
Permissions, legal constraints, architectural limits.
Each pivot felt like a step backwards.

The final stack — PostgreSQL, Supabase, Next.js —
is a culmination of those failures.

---

## Scale

Built on real business data from a live hospitality operation.

| Metric | Value |
|--------|-------|
| Supplier spend processed | £43,000+ |
| Real procurement transactions | 4,700+ |
| Canonical product entities | 400+ |
| Packaging-to-canonical unit mappings | 1,134 |
| Normalisation coverage | 97% |

---

## Architecture

The system is built on a strict layered pipeline:
```
RAW → MASTER → NORMALIZED → CERTIFICATION → TRUTH → 
TEMPORAL MODEL → BEHAVIOURAL STATE → BEHAVIOURAL MODELLING → 
BLUEPRINT → EXECUTION → ANALYSIS
```

Each layer has a single responsibility. No layer contaminates 
another. The entire behavioural state is deterministically 
rebuildable from canonical truth.

Full architectural doctrine → [architecture/constitution.md](architecture/constitution.md)

Full topology manifest → [architecture/topology.md](architecture/topology.md)

---

## Stack

| Layer | Technology |
|-------|------------|
| Data layer | PostgreSQL / Supabase |
| Analytical logic | SQL views |
| Operational frontend | Next.js |
| Stakeholder reporting | Power BI |

---

## Key Technical Decisions

**Canonical identity over supplier SKUs** — suppliers assign 
arbitrary SKUs to the same physical product. Hyde consolidates 
these into stable product identities, enabling consistent 
tracking across suppliers and over time.

**Physical unit normalisation** — all quantities resolve to 
physical base units (kg, L, units, m, m²). Pack abstractions 
are forbidden in canonical truth. This prevents silent 
comparison errors when supplier packaging changes.

**Behavioural ordering over static reorder points** — the 
replenishment engine uses rolling consumption metrics and 
anomaly detection to distinguish temporary bulk purchases 
from genuine demand shifts, avoiding false baseline 
recalibration.

**Certification gate** — only verified unit mappings enter 
canonical truth. Unverified mappings are excluded from all 
production analytics, preventing silent data quality drift.

---

*Built by a Kitchen Manager who experienced the problem 
firsthand — and couldn't find a system that solved it, 
so built one from scratch.*
