# SUBMISSION.md

## Deliverable 2 — Validation and Architecture Review

Due: end of Session 16 (or start of Session 17). Faculty open this file first — every box below should reflect what's actually in the repo, not what's planned.

**Hard gates (auto-fail if missing): repo link present + `/evidence/model-selection.md` present.**

### Checklist

- [ ] **Validation board** — assumptions tested, how tested, what learned → `VALIDATION-BOARD.md`
  *Status: hypotheses + experiment plan complete; actual results pending real test data.*

- [ ] **User evidence** — interviews, surveys, prototype tests, landing-page signals, or expert feedback → `/evidence/validation/`
  *Status: not yet added — depends on validation test being run.*

- [ ] **Updated `PRD.md`** reflecting what validation taught the team
  *Status: not yet updated — depends on validation results existing first.*

- [x] **`ARCHITECTURE.md`** with diagram covering frontend, backend, database, AI, automation
  *Status: complete.*

- [x] **Data plan** — what data, where it lives, who can read/write → `DATA-PLAN.md`
  *Status: complete. One open decision flagged inside (delete vs. anonymize on cascade) — resolve before final submit.*

- [ ] **GitHub repo** — canonical folders, three-branch model, README §1–8 filled, faculty added as collaborators, commit tagged `d2-ready`
  *Status: repo structure and branching not yet set up; README drafted but needs team info filled in (see `README.md` §2, §6, §7).*

- [x] **`/evidence/model-selection.md`** — Session 3 OpenRouter scan (recommended/cheap/trending, cost, context window, privacy posture)
  *Status: drafted with current model research; live pricing/context-window numbers flagged for verification against openrouter.ai/models before final submit.*

- [ ] **`/evidence/openrouter-verified.png`** — screenshot of successful curl test proving team-scoped key + spend cap
  *Status: not done — requires running the actual curl test from `/templates/openrouter-api-key-setup.md` with the team's real key.*

- [ ] **This file's boxes ticked accurately**
  *Status: in progress — don't check a box above until the thing it describes is actually committed to the repo.*

---

### Remaining work, in order

1. Confirm which repo is the real Session 12 repo (not a stray "untitled project" or test repo).
2. Set up canonical folders + three branches (`main`, `dev`, feature branch) per `/templates/github-repo-template.md`.
3. Run or locate the concierge-test results from the validation board (Session 11 plan) — this unblocks both `VALIDATION-BOARD.md` and the PRD update.
4. Collect the evidence files that back those results into `/evidence/validation/`.
5. Update `PRD.md` with a short section on what changed post-validation.
6. Run the OpenRouter curl test with the team key, screenshot it + the spend cap setting.
7. Fill in README §2 (team), §6 (tech stack), §7 (setup) with real info.
8. Add faculty as GitHub collaborators (Settings → Collaborators and teams).
9. Merge everything to `main`, tag the final commit `d2-ready`.
10. Tick the boxes above to match reality.
