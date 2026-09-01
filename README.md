# Hyde Procurement Intelligence

Hyde is a procurement intelligence system for hospitality businesses.

It turns fragmented supplier purchasing data into structured intelligence for:

- ordering
- spend analysis
- supplier and product behaviour
- management decision-support

Users interact with the system through an AI assistant built on governed backend data and tools.

## Why I Built It

I built Hyde after working as a Kitchen Manager in an environment where procurement was largely driven by memory, habit and fragmented supplier information.

The system was designed to organise that operational data into something reliable enough to support better decisions.

## Architecture

```text
Supplier Data
      ↓
Canonical Procurement Data
      ↓
Operational Intelligence
      ↓
Governed System State
      ↓
Hyde Assistant
```
The architecture separates trusted, incomplete, live and simulated states rather than allowing the application or AI layer to silently guess.

## What It Can Do

- generate supplier-specific order recommendations
- analyse spend by department, supplier and product
- identify purchasing and price behaviour
- answer procurement questions in natural language
- surface uncertainty when operational data is incomplete

## Stack

PostgreSQL / Supabase · SQL · dbt · Next.js · OpenAI API

## Scale

4,700+ transactions · £43k+ supplier spend · 400+ canonical products


