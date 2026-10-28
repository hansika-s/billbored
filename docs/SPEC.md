# billbored: Spec

A shared tracker for subscriptions, installments and invoices, so a payment or a cancellation deadline is never missed.

## Scope

**In scope**
- One shared list per household of subscriptions, installment plans and open invoices
- Due dates, cancellation deadlines, and reminders before each one, set per entry
- A "Due in 30 days" view on the home screen
- An owner per entry: the household (shared) or a specific member

**Out of scope (first versions)**
- Bank connections, account balances, marking payments as paid
- Budgets, category totals, spending analysis
- Reading invoices or receipts from email

Analysis features may come later. Entries store amount and date from the start, so no data migration is needed.

## Households and members

- A household is the unit of data. Each household has its own list, and nothing is shared between households.
- A household has one or more members. Members are invited by email and can be added or removed by any member.
- Every member can view and edit all entries in their household.
- Each entry has an owner: **Household** (shared costs such as rent, utilities, internet, shared streaming) or a **specific member** (personal costs, visible to everyone in the household).
- The design supports any number of members per household.

## Home screen

- A "Due in 30 days" list, sorted by date. It combines payments, installment dates, invoice due dates, and cancellation deadlines from all three tabs, each labelled with its owner.
- If nothing is due in 30 days, the screen says so.

## Tabs and fields

Three tabs: Subscriptions, Installments and Invoices. Each has an owner filter at the top.

### Subscriptions

| Field | Notes |
| --- | --- |
| Name | e.g. bank card, streaming, phone plan |
| Provider | |
| Amount | EUR |
| Billing rhythm | monthly, quarterly, yearly |
| Owner | Household or a member |
| Payment method | direct debit, card, invoice, cash |
| Contract start | |
| Term end | when it ends or next renews |
| Notice period | e.g. 1 month, 6 weeks, 3 months |
| Auto-renews | yes or no |
| Cancellation deadline | calculated: term end minus notice period |
| Status | active, cancelled, ended |
| Notes | free text |

**Auto-renewal:** when the term end passes and the contract renews, the term end moves forward by one term length, so the next cancellation deadline stays current.

**Cancelled:** when a subscription is cancelled, its status changes to cancelled. It is removed from the active list and the home screen, and its reminders stop. The entry is kept for reference.

### Installments

| Field | Notes |
| --- | --- |
| Item | e.g. laptop, sofa |
| Total price | EUR, the amount actually paid, including any fee or interest |
| Installment amount | EUR |
| Number of installments | |
| First installment date | |
| Next due date | calculated |
| Last installment date | calculated |
| Installments remaining | calculated |
| Owner | Household or a member |
| Lender | optional |
| Status | active or ended |
| Notes | free text |

**Ending early:** mark the status as ended, and the entry leaves the active totals.

### Invoices

| Field | Notes |
| --- | --- |
| Item | one-time purchase |
| Amount | EUR |
| Purchase date | |
| Due date | |
| Owner | Household or a member |
| Invoice number | optional |
| Status | open or paid |
| Notes | free text |

**Paid:** marking an invoice as paid moves it out of the open list. This is the only payment-related status in the app.

## Reminders

- **Per-entry reminders:** each entry has its own reminder timing. Defaults are 7 days and 1 day before each payment due date, and 30 days and 7 days before each cancellation deadline. Each entry can change these.
- **Delivery:** through calendar events generated from each entry (ICS feed). Reminders arrive even when the app is closed. Each member subscribes to the household feed once in their calendar app.

## Technical approach

- **Front end:** React and TypeScript, built with Vite. Responsive layout that works on phones.
- **Installable app:** a web app manifest and service worker, so members can add billbored to their home screen and open it full-screen.
- **Data and login:** Supabase (Postgres database, email login, row-level security so each member can only read and write their own household's data).
- **Hosting:** Vercel, deployed from GitHub.
- **Date logic:** one shared module for calculated fields (next due date, installments remaining, cancellation deadline, roll-forward on auto-renewal), with unit tests.
- **Calendar feed:** an ICS endpoint per household that generates events from stored entries and their reminder timings. Access is protected by a private, revocable token.

## Phases

1. **Phase 1, Core app:** accounts and households with member invitations, three-tab layout, add and edit forms with notes, date logic, per-entry reminders through the calendar feed, installable home-screen app.
2. **Phase 2, Improvements:**
   - Push notifications as a complement to calendar reminders
   - Multiple currencies
   - Analysis features if still wanted (monthly totals, fixed versus variable spending)
