# Hyde Procurement Intelligence

I was the Kitchen Manager. I lived the friction firsthand.

Operating under uncertainty is the norm: 
Trying to make sure the kitchen has enough for the week, avoiding under-ordering, avoiding over-ordering, 
and making decisions fast in an environment that rarely gives you clean signals.

In hospitality SMBs, you are focused on surviving, not optimising.

> Systems substituted with intuition.  
> Decisions made from memory, habit and experience.

The data to do better already exists. 
It is buried across supplier invoices, fragmented by product naming, pack sizes, and supplier-specific formats.

Hyde is the system I built to turn that fragmented purchasing data into a deterministic procurement baseline.

---

## The Problem

In a kitchen, the absence of a system is felt every week: working out what to order, how much to order, and how to translate that judgment across suppliers who sell the same product in different formats.

Something as ordinary as cheddar cheese becomes harder to reason about than it should be. One supplier sells 450g, 500g, or 750g packs. Another sells a 4.5kg block. Without a baseline, every change forces the operator to recalculate quantities in their head.

That burden does not just create stress. It prevents the business from accumulating reliable purchasing intelligence, leaving decisions trapped in memory, habit, and whoever happens to know the operation best.

> In a high-churn industry, that becomes a structural vulnerability.

Each handover risks resetting the kitchen back to intuition.

Now multiply that across 400 products, 3 suppliers, and 4,700 transactions.

---

## What Hyde Does

Hyde was not built to replace the operator. It was built to replace the void beneath them.

An experienced head chef knows things no system can fully capture: the regulars who order the special, the event next Saturday, the supplier whose quality has been slipping. That judgment matters.

What Hyde provides is the part that intuition cannot do reliably: exact consumption baselines, reorder cadence, trend visibility, and a consistent view of whether elevated purchasing reflects genuine demand change or just short-term noise.

It does not compete with experience. It gives experience something stable to stand on: a deterministic procurement baseline built from accumulated purchasing data.

When people leave, that baseline does not leave with them. The next operator inherits a foundation instead of starting from zero.

---

## The Build

Hyde began in Google Sheets, moved to Coda, then Bubble, with each version rebuilt from scratch as the limitations of the previous one became clear.

- Google Sheets made collaboration easy, but it did not scale. 
- Coda improved the interface, but exposed governance risks: the system was too easy to accidentally edit, break, or delete.
- Bubble offered more flexibility, but introduced platform and legal constraints that made it the wrong long-term foundation.

Those pivots clarified what Hyde actually required: 

A system with stable data governance, deterministic backend logic, and full control over the application layer.

The final stack - PostgreSQL, Supabase, and Next.js - was the result of that convergence. 

Hyde needed a proper relational backend, SQL-driven transformation logic, and a frontend built on top of a stable operational model rather than low-code compromise.

---

## Scale

Built on real business data from a live hospitality operation.

| Metric | Value |
|--------|-------|
| Supplier spend processed | £43,000+ |
| Procurement transactions processed | 4,700+ |
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

**Canonical identity over supplier SKUs**  
Suppliers assign different SKUs to the same physical product. Hyde consolidates these into stable product identities, enabling consistent tracking across suppliers and over time.

**Physical unit normalisation**  
All quantities resolve to physical base units (kg, L, units, m, m²). Pack abstractions are excluded from canonical truth, preventing silent comparison errors when supplier packaging changes.

**Behavioural ordering over static reorder points**  
The replenishment layer uses rolling consumption metrics and anomaly detection to distinguish temporary bulk purchases from genuine demand shifts, reducing false baseline recalibration.

**Certification gate**  
Only verified unit mappings enter canonical truth. Unverified mappings are excluded from production analytics, preventing silent data-quality drift.

---
