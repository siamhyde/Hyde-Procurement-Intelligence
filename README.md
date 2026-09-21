# Hyde Procurement Intelligence

Hyde is a procurement intelligence system for hospitality businesses.

It turns fragmented supplier purchasing data into structured intelligence for ordering, spend analysis and management decision-support.

Users interact with the system through an AI assistant built on governed backend data and tools.

## Why I Built It

I built Hyde after working as a Kitchen Manager in an environment where procurement was largely driven by memory, habit and fragmented supplier information.

## Demo

<table>
  <tr>
    <td width="65%">
      <img width="755"
        alt="Hyde ordering recommendation"
        src="https://github.com/user-attachments/assets/aab21554-d243-4d12-985d-88dd56e9f35c" />
    </td>
    <td width="35%" valign="top">
      <h3>Shareable order</h3>
      <pre>
Hyde production order
1 Sept 2026

2 packs × Falafel — 117x17g
2 packs × Gyros Flatbread — 1x60

2 products · Confirm quantities before ordering.
      </pre>
    </td>
  </tr>

  <tr>
    <td width="65%">
      <img width="724"
        alt="Hyde executive spend analysis"
        src="https://github.com/user-attachments/assets/8f3283b9-e8d5-41f9-85ab-de1fe7be0f6a" />
    </td>
    <td width="35%" valign="top">
      <h3>Shareable analysis</h3>
      <pre>
FOH VS KITCHEN SPEND
1 September 2025 – 31 August 2026

FOH: £11,151.61
Kitchen: £15,486.90

Combined charged spend: £26,638.51
Previous 12 months: £25,423.25
Change: +£1,215.26 (+4.8%)

Main categories:
1. Produce — £3,386.89
2. Cakes — £2,353.42
3. Cheese — £2,308.46
Other categories — £18,589.74

Based on 2,696 recorded financial events.
      </pre>
    </td>
  </tr>
</table>

## Architecture

```text
Supplier purchasing records
    ├── Recorded charged spend → Management reporting
    │
    └── Canonical product identities + certified unit mappings
            ├── Purchase cadence → Replenishment + supplier-pack translation
            └── Paid-cost evidence → Pricing comparisons
                            ↓
                 Rebuildable serving state

Reporting + serving interfaces
    → Allowlisted application tools
    → Hyde assistant
```

SQL defines quantities, comparison baselines and ordering rules. Hyde retrieves and explains those results through scoped tools. Supplier-specific live recommendations require checks on availability, observation coverage, reliability and freshness; simulations and historical reconstructions retain their own labels.

Recorded spend and certified physical quantities have separate coverage measures. Paid-cost comparison is currently governed for Brakes; it does not establish the cheapest supplier.

## Ordering Automation

The Ocado integration implements user-approved basket preparation:

```text
Historical basket reconstruction (90 or 180 days)
    → User selects Create Ocado basket
    → Client-scoped execution job
    → Enrolled local Windows helper
    → Basket approval, manual login + empty-trolley confirmation
    → Exact supplier SKUs + backend pack quantities
    → Verified basket additions + progress returned to Hyde
    → Trolley opened for human review
```

The helper preserves the historical source label and stops on an uncertain basket change. Checkout, payment and order placement remain manual. The integration is implemented in the application and helper code; deployment and supervised operation on the target device require separate acceptance.

## Stack

PostgreSQL / Supabase · SQL · Next.js · TypeScript · OpenAI API · Playwright

## Scale

**6,093 recorded purchasing line items · £58,280.36 historical charged spend**

Verified in the 27 August 2026 audit snapshot. These are line items, not distinct orders. The certified canonical subset contains 5,964 lines and £56,995.24 of spend. [Metric definitions and verification notes](METRICS.md).
