# Repository Guidelines

## Project Structure & Module Organization
Smaug is a Node.js CLI. Core logic lives in `src/` (CLI entrypoints in `src/cli.js`, config in `src/config.js`, processing in `src/processor.js`). Example integrations are in `examples/`. Runtime outputs are stored at the repo root: `bookmarks.md` (archive), `knowledge/` (filed markdown by category), and `.state/` (pending/state JSON). Local configuration is read from `smaug.config.json`.

## Build, Test, and Development Commands
- `npm install`: install dependencies (Node >= 20).
- `npm start`: run the CLI (same as `node src/cli.js`).
- `npm run fetch`: fetch bookmarks into `.state/pending-bookmarks.json`.
- `npm run process`: process pending bookmarks into `bookmarks.md` and `knowledge/`.
- `npx smaug run`: run fetch + process in one step.
- `npx smaug fetch --folder-id <id>`: fetch bookmarks from specific bookmark folders (repeat `--folder-id`).
- `npm test`: run Node's built-in test runner (`node --test`).

## Coding Style & Naming Conventions
Use ESM syntax (`import`/`export`), 2-space indentation, single quotes, and semicolons, matching the existing `src/*.js` files. Prefer lowercase file names like `cli.js` and `processor.js`. No formatter or linter is configured, so keep changes consistent with surrounding code.

## Testing Guidelines
There is no dedicated test suite yet. If you add tests, follow Node's `--test` conventions (for example, `*.test.js`) so `npm test` discovers them. Keep tests small and colocated with the modules they cover if that helps readability.

## Commit & Pull Request Guidelines
Commit subjects are short and imperative; history shows both plain verbs ("Add", "Fix", "Document") and Conventional prefixes like `feat:` or `docs:`. For bookmark-processing runs, the repo often uses messages like "Process N Twitter bookmarks from Jan 2". PRs should describe behavior changes, link relevant issues, and call out any generated updates to `bookmarks.md` or `knowledge/`.

## Security, Configuration, and Agent Notes
Do not commit live credentials. Use environment variables or a local `smaug.config.json` that is excluded from sharing. For bookmark-processing workflow details (date headers, templates, parallel subagents), follow `.claude/commands/process-bookmarks.md`.
