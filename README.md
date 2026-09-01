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

<img width="785" height="954" alt="e3bb9d7b8542e402f9a8243c4651ed7d" src="https://github.com/user-attachments/assets/a0720e1e-0b8a-4e4a-871a-fd24b9c7f01e" />

<img width="788" height="855" alt="e09e4d7fb90d48be73044867167e8686" src="https://github.com/user-attachments/assets/70b2652d-f626-4f3c-ac5b-005a14aa38a3" />


## Stack

PostgreSQL / Supabase · SQL · dbt · Next.js · OpenAI API

## Scale

4,700+ transactions · £43k+ supplier spend · 400+ canonical products


