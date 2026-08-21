# CLAUDE.md

## Project

Cat Breed Explorer — an iOS app (SwiftUI + Combine) built for the Applaudo code challenge. Tuist-managed, Moya for networking. Full challenge spec lives in `CHALLENGE.md`.

## Challenge Context

### Story Map

| Story | Priority | Status |
|-------|----------|--------|
| 1 — Browse Cat Breeds (list with loading/empty/error, tap to detail) | Core | Done |
| 2 — Cat Breed Details (image, description, origin, temperament, life span) | Core | Not started |
| 3 — Register a New Cat (multi-step form, local persistence) | Core | Not started |
| 4 — Pagination (infinite scroll on breed list) | Plus | Not started |
| 5 — Form Validations (inline validation per step) | Plus | Not started |

### Evaluation Criteria

Reviewers score on: project setup (Tuist + API key), code architecture (separation of concerns, DI, scalability), networking (correct use of existing NetworkLayer, model definitions, error handling), UI/UX (use of provided components/theme, state handling, navigation), local storage (appropriate persistence choice), idiomatic Swift & SwiftUI, and bonus items (pagination, validation, unit tests, thoughtful extras).

**A crash in the app means disqualification.** Prioritize defensive error handling — never force-unwrap API data, always handle edge cases gracefully, guard against nil/empty states.

### Technical Constraints (from challenge spec)

- **Combine preferred** for reactive data flow
- **Use existing UI components and theme** — do not reinvent them, extend if needed
- **Use the existing NetworkLayer module** — follow its documented patterns (see `modules/NetworkLayer/README.md`)
- **Code must be readable, testable, and well-structured**
- **Additional libraries** allowed via SPM/Tuist if justified
- **API**: The Cat API (`https://api.thecatapi.com/v1/`), free key required

## Build & Run

```bash
mise exec -- tuist generate --no-open
xcodebuild -workspace ApplaudoChallenge.xcworkspace -scheme ApplaudoChallenge -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Feature Development Workflow

When developing a new feature or story, follow this pipeline in order:

1. `/grill-with-docs` — Discuss and align on every design decision for the story
2. `/to-spec` — Formalize the grilling output into a specification document
3. `/to-tickets` — Break the spec into discrete, implementable tickets
4. `/implement` — Build it ticket by ticket

Do not skip steps or collapse them. Each step produces an artifact that the next step consumes.

## Architecture Decisions

- **MVVM** — ViewModels talk directly to service protocols, no use-case/interactor layer
- **Combine** — Full Combine pipelines from network layer through ViewModels (no async/await bridging)
- **ViewState enum** — Generic `ViewState<T>` with `.idle`, `.loading`, `.loaded(T)`, `.error(String)` for all screens
- **Protocol-based DI** — ViewModels take service protocols in init with default parameters for real implementations
- **Value-based navigation** — `NavigationLink(value:)` + `.navigationDestination(for:)` pattern
- **Pagination-ready** — API targets include page/limit parameters from the start

## Project Structure

- `modules/NetworkLayer/Sources/` — Models, Targets, Services (all networking lives here)
- `ApplaudoChallenge/Sources/Components/` — Reusable UI components (AppCard, AppButton, AppTextField, EmptyStateView, StepperIndicator, SectionHeader)
- `ApplaudoChallenge/Sources/Theme/` — AppTheme design tokens (colors, fonts, spacing, corner radius)
- `ApplaudoChallenge/Sources/Common/` — Shared utilities (ViewState)
- `ApplaudoChallenge/Sources/Features/` — Feature modules organized by screen

## Conventions

- Use existing UI components and theme tokens — extend only if needed, don't reinvent
- Services live inside the NetworkLayer module with a public protocol + two-init pattern (public parameterless init, internal init for testing)
- Fetch data in `.task` modifier, not in ViewModel init
- Use `AppCard` for list items, `EmptyStateView` for loading/empty/error states
