# AGENTS.md

This file provides guidance to AI tools such as Claude Code (claude.ai/code), Google Gemini CLI, OpenAI Codex CLI, and Cursor when working with code in this project.

iBanker is being rewritten in SwiftUI and adopts Fast Five Products LLC's public AGPL template for Apple development. The reference template lives at `../template/template.ios` — see [Template Relationship](#template-relationship).


## Build Command
```bash
xcodebuild build -project iBanker.xcodeproj -scheme "iBanker" -destination 'platform=iOS Simulator,name=iPhone 17' -sdk iphonesimulator ONLY_ACTIVE_ARCH=YES -quiet
```
- The active (and only) Xcode project is `iBanker.xcodeproj` (target/scheme `iBanker`, bundle id `com.maiser.ibanker`). Passing `-project iBanker.xcodeproj` is not strictly required now that the repo has a single project, but keep it explicit for clarity.


## What This App Is

iBanker replaces paper money and the "banker" role in board games (Monopoly®, The Game of Life®, etc.). Players send money to/from "the bank" and to each other; everything persists across app launches. It is iOS-only (iPhone/iPad), SwiftUI, iOS 18+. First released on the App Store in 2016 and originally open-sourced under MIT in 2017; as of v2.0.0 it is licensed AGPL-3.0 with the Fast Five Products LLC author exception (see `LICENSE` and `LICENSE-EXCEPTIONS.md`). This branch is a SwiftUI rewrite.


## Architecture

The app is **local-only and event-sourced** — there is no backend, networking, or Firebase. State is derived by replaying a transaction log.

### The central pattern: derived game state
`GameSession` is the single source of truth — created once as a `@StateObject` in `iBankerApp` and injected everywhere as an `@EnvironmentObject`. It stores **two arrays only**:
- `players: [Player]`
- `transactions: [GameTransaction]`

Player **balances and salaries are never stored directly**. `gameSession.currentState` is computed on demand by `GameStateReducer.reduce(players:transactions:)`, which starts every player at 0 and replays each transaction's `GameAction` (`collectSalary`, `payPlayer`, `addMoney`, `subtractMoney`, `updateSalary`, `resetPlayer`, `custom`) to produce a `GameState` (dictionaries `playerBalances` and `playerSalaries`, keyed by player id).

**Consequence for any money/salary change:** append a transaction via `gameSession.perform(action, by: playerID)` — never mutate a balance directly. Views read balances through `gameSession.currentState.playerBalances[player.id]`. `PlayerView` is where all the user-facing `GameAction`s originate.

### Persistence
- `GameSession` JSON-encodes `players` and `transactions` into `@AppStorage` (UserDefaults keys `gamePlayers` / `gameTransactions`). It is saved on the root view's `onDisappear` and decoded in `GameSession.init()` (direct `UserDefaults` access, to satisfy two-phase init).
- `SettingsStore` persists individual settings via `@AppStorage` (`selectedGameMode`, `customInitialBalance`, `customInitialSalary`, `soundEffects`).
- `GameMode` defines preset starting balances/salaries per popular game; `SettingsStore.effectiveDefaultBalance/Salary` resolve the active mode (or custom values).

### Activity Log — a derived SwiftData store
`ActivityLogView` reads `ActivityLogEntry` (a SwiftData `@Model`) via `@Query`, using `@Environment(\.modelContext)`. The log is **fed by the transaction log as a derived side effect**: every `gameSession.perform(...)` also inserts a human-readable `ActivityLogEntry` (the container is attached in `iBankerApp`; the context is handed to `GameSession` in `MainTabView`). The transaction log remains the single source of truth — the Activity Log is presentation history, never a second source of state (note: `undoLastTransaction()`/"Clear All Logs" do not reconcile the two stores).

### Navigation & layers
- `MainTabView` → Home / Activity / Settings tabs.
- `HomeView` lists/edits players (add, delete, reorder) and shows live balances.
- `PlayerView` is the per-player banking screen (collect salary, add/subtract, send to another player).
- `ViewSupport/` holds presentation config: `AppColor` (palette), `ViewConfiguration` (`dynamicSizeMax`, `isPreview`), `CustomLabeledContentStyle`.
- `Utilities/DebugPrintable` — protocol giving `debugprint(_:)` that is a no-op in release builds.


## Template Relationship

This project is a child of `../template/template.ios` (Fast Five Products LLC's public AGPL template, currently around v0.3.x — see that repo's `TEMPLATE.md`). **Prefer taking files from the template wholesale** when adopting functionality, rather than reinventing it.

- Template source of truth: `../template/template.ios/` — read its `AGENTS.md`, `CONTRIBUTING.md`, and `README.md` for the full conventions.
- The template is a Firebase/Data Connect app; **iBanker does not (yet) use Firebase**, so the template's Cloud/Repository/Store layers are not present here. Pull in template files selectively.
- When copying a template file, keep its structured file header and update the "Modified by" line (see below).

### File headers & licensing
All Swift files carry the FFP AGPL header (standardized for v2.0.0). The project is licensed AGPL-3.0 with the Fast Five Products LLC author exception — see `LICENSE` and `LICENSE-EXCEPTIONS.md` (both bundled as app Resources).

Use the FFP AGPL header format documented in `../template/template.ios/CONTRIBUTING.md`:
- **Modifying** an existing file: maintain a single `Modified by <name>, <date>` line (replace it — never stack a second) and add an "(updated)" suffix to the template version line; never advance the template version number itself.
- **Creating** a new file: start with the current template version header, preserving the layout used across this repo's headers.

### App-Specific MARK convention
Template "merge" files mark customizable regions with `// MARK: - App-Specific`. Content above the MARK can generally be refreshed from the template; content at/below is app-specific and must be preserved or carefully merged. Treat the MARK as a hint, and always review the full diff.


## Key Patterns

- **Status text vs alerts**: use inline `statusText` only for instant client-side validation (empty fields, mismatches); present anything the user waited on for a server/async result as an alert. (Carried over from the template; relevant as the rewrite adds validation.)
- **Single shared session**: do not create new `GameSession` instances in app code — read the injected `@EnvironmentObject`. (Previews intentionally build their own throwaway session.)


## Code Review

When asked to "do a code review", follow this process:

### Categories to Evaluate
1. **Bugs** — logic errors, copy-paste mistakes, typos
2. **Security** — auth gaps, data exposure, input validation, secrets in source control
3. **Error Handling** — unhandled throws, force unwraps, silent failures, missing edge cases
4. **Deprecated APIs**
5. **Performance** — redundant computation, missing caching, expensive operations
6. **Style** — inconsistencies with the rest of the existing codebase
7. **Licensing** — attribution, copyright headers, commercial risks

### Output Format
Present findings as a numbered table with columns: ID, Category, Priority, Summary, File(s). Use short IDs by category (B1, S1, E1, D1, P1, C1, L1). Prioritize bugs and security first.

### Cross-Referencing
Before reporting a finding, cross-reference it against existing GitHub issues (open and closed) and prior code-review dispositions; omit anything already tracked or dispositioned won't-fix unless circumstances materially changed. Focus on genuinely new findings.

### Workflow
1. Explore the repo, cross-reference, then present the filtered findings table.
2. Discuss each finding with the user — they decide fix/close/defer.
3. For each fix: edit → build → commit → push.
4. After each commit, regenerate the table with an added Status column (keep all original columns — the table must be self-contained).


## Testing
- Manual testing only (no automated test suite). Build with the command above, then run on a simulator from Xcode.


## Git Workflow

iBanker follows the FFP template's git-flow model:

- **`develop`** — the default working/integration branch. All feature work branches off `develop` and squash-merges back into it.
- **`main`** — the release/production branch: a clean linear history with one commit per release (`Release vX.Y.Z`). Cut a release by squashing all of `develop` since the last release onto `main`.
- **`objective-c`** — a frozen snapshot of the final Objective-C release (v1.3.0), kept for reference; not a working branch.

The SwiftUI rewrite (issue #11, targeting v2.0.0) lives on `develop`; it is not yet released, so `main` still points at the last shipped version, v1.3.0.

**Feature flow** (off `develop`):
1. Branch from a GitHub issue: `git checkout develop` → `git pull origin develop` → `gh issue develop <issue-number> --base develop --checkout`.
2. Make changes → build → fix → user reviews/tests on a simulator.
3. On the user's request, commit and push the feature branch.
4. Open a PR targeting `develop`: `gh pr create --base develop`.
5. User squash-merges the PR on GitHub; then refresh: `git checkout develop` → `git pull origin develop`.

**Release flow** (`develop` → `main`): squash all of `develop` since the last release into a single `Release vX.Y.Z` commit on `main`. See the template's `AGENTS.md` "Release Process" for the exact steps.

- Commit/push only when the user asks.


## Common Issues
- **Using the wrong build command**: always use the command above. Agents that invent their own often name an uninstalled simulator; the build then hangs until timeout instead of failing fast.
- **Running commands in the wrong directory**: `cd` into `ibanker` before any git or build operation.
- **Chaining shell commands obscures permission mapping**: run `cd` as its own separate Bash call — never chain with `&&`, `;`, or `|`, and never use `-C`-style flags to avoid `cd`. This keeps the permission prompt mapped to the real operation.
