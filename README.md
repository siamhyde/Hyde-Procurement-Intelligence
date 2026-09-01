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

- generate supplier and department specific order recommendations
- analyse spend by department, supplier and product
- identify purchasing and price behaviour
- answer procurement questions in natural language
- surface uncertainty when operational data is incomplete

<img width="755" height="436" alt="01763cc223a42db905759e6ec1b2d8ed" src="https://github.com/user-attachments/assets/aab21554-d243-4d12-985d-88dd56e9f35c" />


<img width="724" height="603" alt="4c4641f9bd27366081ce5bf6acb18abf" src="https://github.com/user-attachments/assets/8f3283b9-e8d5-41f9-85ab-de1fe7be0f6a" />



## Stack

PostgreSQL / Supabase · SQL · dbt · Next.js · OpenAI API

## Scale

4,700+ transactions · £43k+ supplier spend · 400+ canonical products


