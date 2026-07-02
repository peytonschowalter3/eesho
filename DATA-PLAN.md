# Data Plan — LifeAdmin AI

## What data we collect

Per PRD §5, the system stores:

| Entity | Fields | Contains sensitive data? |
|---|---|---|
| `User` | id, email, name, locale, created_at | Yes — PII (email, name) |
| `Document` | id, user_id, file_url, source_type, title, uploaded_at, extracted_text, processing_status | Yes — raw uploaded contracts/emails, often highly sensitive (landlord, insurer, university correspondence) |
| `Finding` | id, document_id, type, summary, evidence_text, page_or_line, confidence, due_date, money_amount | Yes — derived from Document, inherits sensitivity |
| `Deadline` | id, user_id, finding_id, title, due_date, reminder_at, status | Low — dates/status only |
| `Draft` | id, user_id, document_id, recipient, subject, body, status, approved_at, sent_at | Yes — recipient contact info, drafted correspondence |
| `ActionLog` | id, user_id, action_type, related_entity_id, timestamp | Low — audit trail |

## Where it lives

- **Uploaded files** (`Document.file_url`): encrypted object storage (e.g., Supabase Storage or equivalent), not the database itself. Files are never stored in plaintext at rest.
- **Structured data** (`User`, `Document` metadata, `Finding`, `Deadline`, `Draft`, `ActionLog`): Postgres, row-level security enabled so every query is scoped to `user_id`.
- **No local/browser storage** for any of the above — session state only, per standard web-app practice; nothing sensitive persists client-side.

## Who can read/write

| Actor | Read | Write |
|---|---|---|
| Owning user | Own rows only (all tables) | Own `Document` (create), own `Draft` (edit/approve), own `Deadline` (edit reminder) |
| AI pipeline (service role) | `Document.extracted_text` for processing | Creates `Finding`, `Deadline`, `Draft` rows; never creates `ActionLog` entries that mark something "sent" |
| Approval & Send service | `Draft` (status = `user_approved`) | Updates `Draft.status → sent`, `Draft.sent_at`; only fires after explicit user approval event |
| Faculty / course reviewers | Repo-level access to code and docs only | No access to any real user data — this is a prototype; no production user data should exist in the repo or in any shared environment |

## Retention & deletion

- Per PRD §5, users need explicit delete controls for documents and account data.
- On document deletion: linked `Finding` and `Draft` rows are either deleted or anonymized (per PRD §7 integration test requirement) — decide and state which, since "or" isn't a spec.
- No `Draft` is ever auto-sent; `sent_at` is only ever set by the Approval & Send service after a logged user-approval action.

## Open decision to flag before submission
The team should explicitly pick delete-vs-anonymize for cascading deletes (PRD §7 currently says "removed or anonymized" — pick one for the data plan to be complete) and state it here.
