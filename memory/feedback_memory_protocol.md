# Memory Protocol

Date: 2026-06-29

When the user corrects Codex or asks Codex to remember something about this project, save it as its own Markdown file inside the root `memory/` folder.

Use one of these filename prefixes:

- `user_` for how the user personally works
- `project_` for facts or rules about this specific project
- `feedback_` for corrections to Codex behavior
- `reference_` for links, facts, or external context to remember

Maintain `memory/MEMORY.md` as an index of every saved rule with a one-line summary so the right context loads next session.

Maintain `memory/lessons.md` as a narrative log of strategic learnings. Append an entry when the user says something is a "lesson" or a "pattern we should remember", or when repeated corrections reveal a recurring pattern. Each entry should include what happened, why it was wrong, what changed, and the deeper principle.

Maintain `tasks/todo.md` for the user's active sprint work. Plan there before building and mark items complete as they ship.

At the start of every new session, read `memory/MEMORY.md`, `memory/lessons.md`, and `tasks/todo.md`, then confirm setup before continuing normal work.
