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

## What It Can Do

- generate supplier and department-specific order recommendations
- analyse spend by department, supplier and products
- identify purchasing and price behaviour
- answer procurement questions in natural language
- surface uncertainty when data is incomplete

<table>
  <tr>
    <td width="60%">
      <img width="755" src="img width="755" height="436" alt="01763cc223a42db905759e6ec1b2d8ed" src="https://github.com/user-attachments/assets/aab21554-d243-4d12-985d-88dd56e9f35c" />" />
      <br><br>
      <img width="724" src="img width="724" height="603" alt="4c4641f9bd27366081ce5bf6acb18abf" src="https://github.com/user-attachments/assets/8f3283b9-e8d5-41f9-85ab-de1fe7be0f6a" />" />
    </td>
    <td width="40%" valign="top">
      <h3>Shareable outputs</h3>
      <pre>
Hyde production order
1 Sept 2026

2 packs × Falafel — 117x17g
2 packs × Gyros Flatbread — 1x60

2 products · Confirm quantities before ordering.
      </pre>

      <pre>
FOH VS KITCHEN SPEND
1 September 2025 – 31 August 2026

FOH: £11,151.61
Kitchen: £15,486.90

Combined charged spend: £26,638.51
Previous 12 months: £25,423.25
Change: +£1,215.26 (+4.8%)
      </pre>
    </td>
  </tr>
</table>

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

## Stack

PostgreSQL / Supabase · SQL · dbt · Next.js · OpenAI API

## Scale

4,700+ transactions · £43k+ supplier spend · 400+ canonical products


