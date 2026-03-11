# Hyde Procurement Intelligence

Entropy is rife in hospitality SMBs — high staff churn, 
ad-hoc orders, no infrastructure, no data accumulation, 
no analysis.

I was the Kitchen Manager. I experienced the friction 
firsthand. The stress of under-ordering, over-ordering, 
no deterministic way to know what to order or how much.

> Systems substituted with intuition.
> Decisions made from memory, habit and experience.

The data to do it better already exists.
It's just fragmented inside supplier invoices.

So I built the system to surface it.

---

## The Problem

The absence of systems is hard to quantify — but 
operationally, it's felt.

You would be surprised how much entropy cheddar cheese 
carries when you actually live it.

The mental arithmetic on a busy morning trying to figure 
out if you have enough for Saturday service. After a long 
shift: do I buy 4kg from this supplier or 500g from this 
one? How many quantities? Which is cheaper per kg?

These questions don't just affect operations — the absence 
of systems affects the bottom line silently, because 
operators are focused on surviving, not optimising.

Now multiply that across 400 products, 3 suppliers, 
and 4,700 transactions.

> That's what Hyde solves.

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
