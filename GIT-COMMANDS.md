# Git commands for D2 setup

Run these from your terminal, inside the cloned repo. Adjust the repo URL and branch names if your team's template specifies different ones.

## 1. Get the repo locally (skip if already cloned)

```bash
git clone <your-repo-url>
cd <repo-name>
```

## 2. Create the branch structure

```bash
git checkout main
git pull origin main

git checkout -b dev
git push -u origin dev

git checkout -b d2/validation-architecture dev
git push -u origin d2/validation-architecture
```

## 3. Create canonical folders

```bash
mkdir -p evidence/validation
```

## 4. Add the files
Copy in: `README.md`, `SUBMISSION.md`, `ARCHITECTURE.md`, `DATA-PLAN.md`, `VALIDATION-BOARD.md` at the locations your template specifies (root unless stated otherwise), and `model-selection.md` + `openrouter-verified.png` into `evidence/`.

```bash
git add .
git commit -m "D2: architecture, data plan, model selection draft, README/SUBMISSION scaffolding"
git push origin d2/validation-architecture
```

## 5. Open a PR and merge
On GitHub.com: open a pull request from `d2/validation-architecture` → `dev`, review, merge. Then `dev` → `main` once the whole team's work is in.

```bash
git checkout main
git pull origin main
```

## 6. Tag the final submission (only once everything is actually merged)

```bash
git tag d2-ready
git push origin d2-ready
```

## 7. Add faculty as collaborators
Not a git command — do this on GitHub.com: **Settings → Collaborators and teams → Add people**.

---

**Do not run step 6 until every box in `SUBMISSION.md` that should be checked actually is.** The tag is what tells faculty "this is final" — tagging early means they may grade an incomplete state.
