# Hyde Procurement Intelligence

I was the Kitchen Manager, responsible for ordering in an environment 
where good decisions were expected without good systems underneath them.

In hospitality SMBs, that often means operating under uncertainty: 
trying to make sure the kitchen has enough for the week, avoiding 
under-ordering, over-ordering, and making fast decisions in an 
environment that rarely gives you clean signals.

You are focused on surviving, not optimising.

> Systems are substituted with intuition.
> Decisions are made from memory, habit, and experience.

The data to do better already exists. It is buried across supplier 
invoices, fragmented by product naming, pack sizes, and 
supplier-specific formats.

Hyde is the system I built to turn that fragmented purchasing data 
into a deterministic procurement baseline.

---

## The Problem

In a kitchen, the absence of a system is felt every week.

Something as ordinary as cheddar cheese becomes harder to reason 
about than it should be. One supplier sells 450g, 500g, or 750g 
packs. Another sells a 4.5kg block. Which one? How many?

You are not thinking about optimisation yet — you are trying not 
to run out. How long will it last? What if you buy too much? 
What if you run out on a Saturday service?

With experience, you develop intuition. But intuition is not 
a system — it is a person.

> In a high-churn industry, that becomes a structural vulnerability.

Each handover risks resetting the kitchen back to intuition. 
The knowledge does not transfer because it was never captured — 
it lived in someone's head.

Now multiply that across 400 products, 3 suppliers, 
and 4,700 transactions.

---

## What Hyde Does

Hyde was not built to replace the operator. 
It was built to replace the void beneath them.

An experienced head chef knows things no system can fully capture: 
the regulars who order the special, the event next Saturday, the 
supplier whose quality has been slipping. That judgment matters.

What Hyde provides is the part that intuition cannot do reliably: 
exact consumption baselines, reorder cadence, trend visibility, 
and a consistent way to tell whether elevated purchasing reflects 
genuine demand change or short-term noise.

It does not compete with experience. It gives experience something 
stable to stand on — a deterministic procurement baseline built 
from accumulated purchasing data.

When people leave, that baseline does not leave with them. 
The next operator inherits a foundation instead of starting 
from zero.

---

## The Build

Hyde began in Google Sheets, moved to Coda, then Bubble — each 
version rebuilt from scratch as the limitations of the previous 
one became clear.

- **Google Sheets** — made collaboration easy, but did not scale.
- **Coda** — improved the interface, but exposed governance risks: 
  too easy to accidentally edit, break, or delete.
- **Bubble** — offered more flexibility, but introduced platform 
  and legal constraints that made it the wrong long-term foundation.

Those pivots clarified what Hyde actually required: stable data 
governance, deterministic backend logic, and full control over 
the application layer.

The final stack — PostgreSQL, Supabase, and Next.js — was the 
result of that convergence. Hyde needed a proper relational 
backend, SQL-driven transformation logic, and a frontend built 
on a stable operational model rather than low-code compromise.

---

## Scale

Built on real business data from a live hospitality operation.

| Metric | Value |
|---|---|
| Supplier spend processed | £43,000+ |
| Procurement transactions | 4,700+ |
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

- Full architectural doctrine → [architecture/constitution.md](architecture/constitution.md)
- Full topology manifest → [architecture/topology.md](architecture/topology.md)

---

## Key Technical Decisions

**Canonical identity over supplier SKUs**
Suppliers assign different SKUs to the same physical product. 
Hyde consolidates these into stable product identities, enabling 
consistent tracking across suppliers and over time.

**Physical unit normalisation**
All quantities resolve to physical base units (kg, L, units, m, m²). 
Pack abstractions are excluded from canonical truth, preventing 
silent comparison errors when supplier packaging changes.

**Behavioural ordering over static reorder points**
The replenishment layer uses rolling consumption metrics and anomaly 
detection to distinguish temporary bulk purchases from genuine demand 
shifts, reducing false baseline recalibration.

**Certification gate**
Only verified unit mappings enter canonical truth. Unverified 
mappings are excluded from production analytics, preventing 
silent data quality drift.

---

## Stack

| Layer | Technology |
|---|---|
| Data layer | PostgreSQL / Supabase |
| Analytical logic | SQL views |
| Operational frontend | Next.js |
| Stakeholder reporting | Power BI |

---

*Built by a Kitchen Manager who experienced the problem firsthand — 
and couldn't find a system that solved it, so built one from scratch.*
