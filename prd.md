# App Plan — LifeAdmin AI

## 1. App Overview

LifeAdmin AI helps people deal with hostile paperwork without losing evenings or money to buried clauses. Users upload or forward contracts, subscription terms, landlord emails, insurance documents, and university admin messages. The app extracts obligations, explains them plainly, tracks deadlines, and drafts cancellation or negotiation emails for approval. The first version should prove one thing clearly: a user can add a document and know what they need to do next.

Assumption for this deliverable: the first build is a responsive web app prototype for an AI-enabled builder such as Lovable, v0, Cursor, or Bolt.

## 2. Key Components

- Document intake: upload PDF/image/text or paste email content.
- Document parser: extracts dates, notice periods, renewal terms, fees, required actions, and contact details.
- Evidence viewer: shows the source clause or email line behind each finding.
- Plain-language explainer: translates admin language into short user-facing summaries.
- Deadline tracker: records renewal dates, cancellation windows, response dates, and missing-document reminders.
- Draft generator: creates formal cancellation, negotiation, clarification, or follow-up emails.
- Approval flow: separates AI draft, user edits, user approval, and sent status.
- User account: stores documents, deadlines, drafts, and action history.

## 3. App Structure

Main screens:

- Inbox: queue of uploaded documents, forwarded emails, detected deadlines, and unfinished actions.
- Add Document: upload, paste, or forward admin content.
- Document Detail: side-by-side source text, plain explanation, deadlines, and suggested next action.
- Deadlines: calendar/list of notice periods, renewals, payments, and response windows.
- Drafts: email drafts waiting for review, edit, approval, or send.
- Sent History: completed user-approved actions with timestamps and recipients.
- Settings: account, connected inbox, notification preferences, and data deletion.

Navigation flow: users start in Inbox, add a document, land in Document Detail after analysis, save or edit detected deadlines, generate a draft when action is needed, approve from Drafts, then see the completed item in Sent History.

## 4. User Interface

Inbox: compact list grouped by urgency. Each row shows item type, source, deadline, financial risk, and status. Top action button: "Add document."

Add Document: drag-and-drop upload area, paste box for email text, optional sender/recipient fields, and a clear note that the app explains documents but does not give legal advice.

Document Detail: split layout. Left side shows the original document with highlighted clauses. Right side shows "What it means," "What could cost you," "Deadline," and "Suggested next move." Each claim links to evidence.

Deadlines: list-first calendar. Items show due date, notice date, confidence level, source, and whether a reminder is active.

Drafts: formal email preview with editable recipient, subject, body, attachment list, source evidence, and a final approval button.

## 5. Backend Requirements

A backend is needed.

Entities:

- User: id, email, name, locale, created_at.
- Document: id, user_id, file_url, source_type, title, uploaded_at, extracted_text, processing_status.
- Finding: id, document_id, type, summary, evidence_text, page_or_line, confidence, due_date, money_amount.
- Deadline: id, user_id, finding_id, title, due_date, reminder_at, status.
- Draft: id, user_id, document_id, recipient, subject, body, status, approved_at, sent_at.
- ActionLog: id, user_id, action_type, related_entity_id, timestamp.

Storage: encrypted file storage for uploads, database rows for extracted findings and drafts. Authentication should use email magic link for low-friction access. Users need delete controls for documents and account data.

## 6. APIs and Libraries

- OCR/document extraction: read PDFs, scanned images, and pasted text.
- AI model: classify document type, extract obligations, explain clauses, and draft formal emails.
- Email provider: optional v1 connection for sending user-approved emails; otherwise export draft text.
- Notification service: email reminders for deadlines and missing actions.
- UI library: component system with tables, tabs, dialogs, calendar/list view, file upload, and toast states.

## 7. Testing Strategy

Unit tests:

- Date extraction from common contract phrases.
- Deadline creation from notice periods.
- Draft status changes from AI-drafted to user-approved to sent.
- Banned language checks for in-app copy.

Integration tests:

- Upload document, extract findings, save deadline, generate draft.
- Edit draft, approve draft, mark as sent.
- Delete document and confirm linked findings/drafts are removed or anonymized.

User acceptance tests:

- A user uploads a gym contract and sees the renewal deadline, notice period, source clause, and cancellation draft.
- A user pastes a landlord email and gets a formal reply draft without jokes.
- A user can tell exactly what the AI found, what it drafted, and what has not been sent yet.

## 8. Platform-Specific Considerations

For Lovable or Bolt: start with Supabase auth, database, and file storage. Use row-level security so users only see their own documents.

For v0 or Cursor: build a Next.js app with server actions or API routes for document processing, AI calls, and draft generation.

For any AI builder: lock the IA early. Do not let the app collapse into a generic chat screen. The product is a work queue with evidence, deadlines, and approval states.

## 9. Out of Scope for v1

- Full legal advice or legal-risk scoring.
- Automatic sending without user approval.
- Bank account connections.
- Multi-user household or team accounts.
- Native mobile apps.
- Support for every document type and country from day one.
- Negotiation success prediction.

## 10. Definition of Done

- User can create an account and add one document or pasted email.
- App extracts at least one deadline, fee, obligation, or missing action from the document.
- User can see the exact source evidence behind the extracted finding.
- App explains the finding in plain language without legal-advice claims.
- User can generate and edit a formal outbound email draft.
- App clearly labels the draft as not sent until the user approves it.
- User can view all deadlines in one list.
- Banned LifeAdmin AI words do not appear in user-facing copy.
