# Story 3 — Rebuild Registration Flow (UI + flow only)

## Problem Statement

As a user of Cat Breed Explorer, when I open the My Cats tab for the first time and decide to register my first Registered Cat, the current registration flow does not feel like a first-class iOS form. The multi-step form's step distribution, field controls, validation feedback, and confirmation moment are inconsistent with modern iOS design patterns, and the in-progress visual reskin has added complexity without arriving at a polished result. As a challenge reviewer, this hurts my scoring under "UI/UX", "state handling", "navigation", and "idiomatic Swift & SwiftUI".

Additionally, the current implementation collects only a subset of the fields defined on the `RegisteredCat` model — `color` and `gender` were retired during the reskin, leaving them stubbed with placeholder values ("" and `.unknown`). This creates dead data that never surfaces in the UI.

## Solution

Throw away all Story 3 UI and flows and rebuild from scratch. Present the registration flow as a modal sheet launched from the My Cats tab (empty-state CTA and `+` button in the navigation bar), with three fixed steps that follow the modern iOS form pattern: progress dashes at the top, a prominent header + subtitle per step, floating-label fields with persistent helper text, and a single pinned bottom CTA. Re-introduce `color` and `gender` to the form (with `CatGender` reduced to `male | female`), collect them in step 2, and surface them in the Registered Cat detail view. On successful save, present an in-sheet confirmation screen with a success haptic and auto-dismiss, then reveal the Registered Cat in the My Cats list.

Preserve as-is: the `RegisteredCat` SwiftData schema (fields already exist), the persistence path (`AddCatViewModel.save(context:)`), the entire My Cats list, and the tab structure of `ContentView` (already down to two tabs: Cats + My Cats).

## User Stories

1. As a first-time user, I want to see a clear "Register a Cat" call to action in the empty state of My Cats, so I know how to add my first Registered Cat.
2. As a returning user with cats already registered, I want a `+` button in the navigation bar of My Cats, so I can quickly start registering another cat without leaving the list.
3. As a user starting the registration flow, I want it to open as a modal sheet, so I understand it is a focused sub-task that will return me to My Cats when I'm done.
4. As a user in the middle of any step, I want to see three progress dashes at the top with the current step highlighted, so I know how far along I am in the flow.
5. As a user entering each step, I want a prominent bold header and a clear subtitle telling me what to do, so I can act without hunting for context.
6. As a user typing into a field, I want the label to float above the field once I start typing and to see persistent helper text below the field, so I always know what each field expects.
7. As a user in step 1, I want to enter my cat's name and pick their breed from the API list, so I associate my Registered Cat with a known Breed.
8. As a user picking a breed, I want to see all available breeds fetched from the API in a searchable modal, so I can quickly find the right one.
9. As a user in step 2, I want to enter the cat's age as an integer between 0 and 30, so kittens under a year old (age 0) and elderly cats up to 30 years are both supported.
10. As a user in step 2, I want to write a short description of 10–200 characters in a multi-line field that grows as I type, with a running character counter, so I can express personality without hitting arbitrary limits.
11. As a user in step 2, I want to select the cat's coat color or pattern from a list, so I can capture their appearance.
12. As a user in step 2, I want to select the cat's gender (male or female) via a segmented control, so the choice is a single tap.
13. As a user in step 3, I want to see a read-only summary of everything I entered in steps 1 and 2, so I can visually confirm before saving.
14. As a user in step 3, I want to optionally add a photo of my cat via the system photo picker, so my Registered Cat gets a personal image.
15. As a user who does not want to add a photo, I want to register anyway without being blocked, because photo is optional.
16. As a user who taps "Continue" with invalid or missing data, I want each offending field's helper text to turn into an error message in place (no layout jump), so I know exactly what to fix without losing my scroll position.
17. As a user who is correcting a field that had an error, I want the error to clear the moment my input becomes valid, so I get immediate feedback that I fixed the problem.
18. As a user at any step, I never want the primary CTA at the bottom to be disabled, so I always know I can advance the flow by tapping it — even if only to see what's wrong.
19. As a user on step 1, I want to close the sheet using an `X` in the top-leading corner, so exit is one obvious tap away.
20. As a user on step 1 who has entered any data and taps `X`, I want a confirmation dialog before losing my work, so I don't accidentally discard my progress.
21. As a user on steps 2 or 3, I want a `‹ Back` button in the top-leading corner, so I can go back to correct earlier steps without losing what I've entered.
22. As a user, I want the transition between steps to slide horizontally in the direction of travel (forward slides in from the right, back from the left), so I feel a sense of progression.
23. As a user with data in the form, I want the swipe-to-dismiss gesture on the sheet to be blocked, so I don't lose my work by accidentally swiping down.
24. As a user with an empty form, I want swipe-to-dismiss to still work, so I can close the sheet quickly if I opened it by mistake.
25. As a user who successfully registers a cat, I want to see an in-sheet confirmation screen with a green checkmark, my cat's name, and a success haptic, so I know the save worked.
26. As a user on the success screen, I want it to auto-dismiss after a couple of seconds, so I don't have to tap anything to move on — but I also want a "Done" button in case I want to close it immediately.
27. As a user returning to My Cats after registration, I want to see my new Registered Cat in the list, so the outcome of the flow is visible without any extra navigation.
28. As a user tapping a Registered Cat in the list, I want the detail view to include the gender and color I entered, so all the data I provided is visible somewhere.
29. As a user with an older Registered Cat saved before this rebuild (whose gender was persisted as "unknown"), I want the detail view to still open without crashing, silently hiding the Gender row rather than showing a broken value.
30. As a challenge reviewer, I want to see a rebuild that uses the project's existing theme tokens, components, `NetworkLayer` service, and `ViewState<T>` pattern, so the change demonstrates fluency with the codebase rather than ad-hoc reinvention.

## Implementation Decisions

### Presentation and entry points
- The registration flow is presented as a modal sheet from `MyCatsView` with `.presentationDetents([.large])`. There are two entry points: the empty-state CTA (`EmptyStateView` with `buttonTitle: "Register a Cat"`) and a `+` button in the top-trailing position of the My Cats navigation bar when the list is non-empty.
- `ContentView` remains a two-tab `TabView` (Cats + My Cats). No "Add Cat" tab is added back.
- **Conscious deviation** from the literal wording of the Story 3 acceptance criterion *"The second tab presents a multi-step form"*: the second tab (My Cats) is the trigger, but the form itself is a sheet launched from it. This is a UX tradeoff that matches modern iOS conventions (Contacts, Reminders, Notes new-item flows).

### Step structure
- **Step 1 — Identity**: `name` + `breed`. Header "Name and breed" / subtitle "Give your cat a name and pick their breed."
- **Step 2 — Details**: `age` + `shortDescription` + `color` + `gender`. Header "Tell us more" / subtitle "Add age, appearance, and a short description of your cat."
- **Step 3 — Photo**: inline read-only review card of all fields from steps 1–2, plus optional photo picker. Header "Add a photo" / subtitle "Optional — you can skip this and register anyway." Primary CTA changes from "Continue" to "Register".

### Progress indicator
- A new `StepDashesIndicator` component renders three horizontal dashes (24pt × 3pt, corner radius 1.5pt, 6pt gap). Active dash uses `AppTheme.Colors.textPrimary`; inactive dashes use `.gray.opacity(0.25)`. Completed vs pending dashes are visually identical — only the active one differs. Animates on step change.

### Field component
- A new `FloatingLabelField` component in `Sources/Components/` is the visual foundation of the flow. Modes: `.singleLine`, `.multiline(maxChars:)`, and `.wrapping<Content>` for embedding non-textual controls (breed picker button, color menu, gender segmented control) inside the same visual frame. The label animates from placeholder position to floating position on focus or when the field has content. Helper text sits below the field in a fixed-height slot that transitions to error text without shifting layout. Border state reacts to default / focused / error.
- The existing `AppTextField` component is untouched to avoid regressing other screens.

### Non-textual controls in step 2
- `gender`: a `Picker` with `.segmented` style, options `Male` and `Female`, wrapped by `FloatingLabelField.wrapping`.
- `color`: a `Menu` presenting the `CatColor` cases, showing the selected value (or a placeholder) in the field, wrapped by `FloatingLabelField.wrapping`.

### Description field
- `shortDescription` uses `TextField(axis: .vertical)` with `lineLimit(3...6)` — the field grows from 3 lines up to 6 before scrolling internally. A live `N/200` character counter appears in the helper-text slot.

### Sheet chrome and navigation
- Step 1: `X` button (SF `xmark`) in top-leading of the sheet's navigation bar. If `hasUnsavedData` is true, tapping `X` shows a destructive confirmation alert (`"Discard registration?"` / `Discard` / `Keep Editing`); if the form is empty, `X` dismisses immediately.
- Steps 2 and 3: replace the `X` with a `‹ Back` button (SF `chevron.left` + "Back" label) in top-leading. Tapping it calls `viewModel.goBack()`.
- The bottom pinned area contains a single button — `Continue` on steps 1 and 2, `Register` on step 3 — using the existing `AppButton` primary style.
- `.interactiveDismissDisabled(viewModel.hasUnsavedData)` mirrors the `X` logic for the native swipe-down gesture.

### Validation
- Progressive validation: the CTA is always enabled. Tapping it invokes `viewModel.validateAndAdvance()`. If any field fails, the offending field's helper text is replaced by its error text (fixed-height slot, no layout jump) and the step does not advance.
- Once a field has been marked invalid, subsequent typing in that field calls `clearStep{1,2}Error(for:)` (already the pattern in the current view model), which re-runs the field's rule and clears the error the moment it becomes valid.

### Validation rules

| Field | Rule | Neutral helper text | Error text |
|---|---|---|---|
| `name` | 2–30 characters (trimmed) | `Your cat's name.` | `Name must be 2–30 characters.` |
| `breed` | required | `Pick a breed from the list.` | `Please select a breed.` |
| `age` | integer 0–30 | `In years. Kittens under 1 year → 0.` | `Age must be a whole number between 0 and 30.` |
| `shortDescription` | 10–200 characters (trimmed) | `10–200 characters.` (with `N/200` counter) | `Description must be 10–200 characters.` |
| `color` | required | `Main coat color or pattern.` | `Please select a color.` |
| `gender` | required (male or female) | `Male or Female.` | `Please select a gender.` |
| `photo` | optional | `Optional — you can skip this.` | — |

### Transitions
- Step content uses `.transition(.asymmetric(insertion: .move(edge:), removal: .move(edge:)))` with `.animation(.easeInOut(duration: 0.3), value: currentStep)`. The direction is derived from whether the step increased or decreased. The dashes animate their active-color change in the same window.

### Success confirmation
- On successful `save(context:)`, the sheet cross-dissolves to a success screen containing `checkmark.circle.fill` (`AppTheme.Colors.success`), title "Cat Registered", subtitle `"{cat.name} is now in My Cats."`, and a single "Done" button. A `UINotificationFeedbackGenerator.notificationOccurred(.success)` fires on appearance. After ~2.5 seconds without interaction, the sheet auto-dismisses; tapping "Done" dismisses immediately. My Cats reappears with the new Registered Cat visible in the list (list order is `createdAt` descending, already in place).

### View model changes
- `AddCatViewModel` gains `@Published var color: String = ""` and `@Published var gender: CatGender? = nil`, plus a computed `hasUnsavedData: Bool` that returns true when any user-editable field is non-empty (or the photo is set).
- `validateStep1` enforces the new name range (2–30).
- `validateStep2` enforces the new age range (0–30), description range (10–200), and adds required checks for `color` and `gender`.
- `save(context:)` uses the real `color` and `gender` (both are required at validation, so unwrapping is safe by contract).
- `reset()` clears `color` and `gender` in addition to existing fields.
- The static `stepTitles` array is removed; per-step copy now lives inline in each step view.

### Model changes
- `CatGender` becomes `enum CatGender: String, CaseIterable, Codable { case male, female }` — `.unknown` is removed.
- `RegisteredCat` schema is unchanged (both `color` and `gender` fields already exist as `String` and were merely unused).
- Legacy records with `gender == "unknown"` remain readable (the field is a plain `String` in SwiftData). At the display layer, `CatGender(rawValue:)` returning `nil` causes the Gender row to be hidden.

### Detail view
- `RegisteredCatDetailView.infoSection` gains two rows after `Age`: `Gender` (only rendered if `CatGender(rawValue: cat.gender) != nil`, displayed as `.displayName`) and `Color` (only rendered if `cat.color.isEmpty == false`).
- `MyCatsView` list card is untouched.

### Cleanup
- Delete `docs/specs/story-3-5-register-cat-with-validations.md` and `docs/specs/story-3-5-visual-reskin-registration-flow.md` — both superseded by this spec.
- Close the following GitHub issues as `not planned` with a superseded comment: #10, #11, #12, #13, #14, #15, #24, #25, #26, #27, #28, #29, #30, #31.

## Testing Decisions

- A good test here exercises the external behavior of `AddCatViewModel`: given inputs and interactions, does the correct step advance, error dictionary, saved model, and reset state result? Tests must not depend on internal implementation details (private methods, published property emission order) and must not touch SwiftUI views. The prior art in `ApplaudoChallenge/ApplaudoChallenge/Tests/AddCatViewModelTests.swift` already follows this rule with the `@Suite("AddCatViewModel")` structure using Swift Testing (`@Test`, `#expect`).

- **Primary seam**: `AddCatViewModel`. All validation, state transitions, save, and reset logic is exercised through direct property manipulation and public method calls, with `MockCatBreedsService` supplying breeds and an in-memory `ModelContainer` (`ModelConfiguration(isStoredInMemoryOnly: true)`) receiving saves. No new seams are introduced.

- **Modules tested**:
  - `AddCatViewModel` — the existing test suite is extended and updated:
    - Adjust `name` boundary tests for the new 2–30 range (add "31 chars fails", keep "2 chars passes", add "30 chars passes").
    - Adjust `age` tests for the new 0–30 range (change "age 0 fails" to "age 0 passes", keep "age 31 fails", keep "age 30 passes").
    - Update `shortDescription` tests for the new 10–200 range (add "201 chars fails", keep "10 chars passes").
    - Add tests for `color` validation (empty fails on step 2, non-empty passes).
    - Add tests for `gender` validation (`nil` fails on step 2, `.male` / `.female` passes).
    - Add tests for `hasUnsavedData` (empty VM returns false; any field or photo set returns true).
    - Update the `saveCreatesCorrectCat` test to assert on real `color` and `gender` values from the form, and remove the `CatGender.unknown` reference.
    - Update `resetClearsEverything` to also assert `color` and `gender` are reset.
  - `RegisteredCat` / `CatGender` — no dedicated test file needed; the enum change is covered indirectly by the view-model tests.

- **UI verification**: the `FloatingLabelField`, `StepDashesIndicator`, step views, sheet chrome, transitions, and success screen are verified manually against the "Verification" checklist in the plan (build, live simulator screenshots, golden path, edge cases). Snapshot / UI-test infra is out of scope for the deadline.

## Out of Scope

- Snapshot or SwiftUI UI tests for the new components — no snapshot infra exists in the repo and adding it under the deadline is not justified.
- Editing an existing Registered Cat after registration — the flow is create-only.
- A "Register another" shortcut from the success screen — with a single entry point, the user opens the sheet again from My Cats via the `+` button.
- Trimming the `CatColor` enum's 13 values to a shorter list — kept as-is; may be reconsidered later.
- Pagination on the breed picker sheet — the picker keeps fetching `limit: 100` as it does today (Story 4 is untouched).
- Persistent per-cat metadata beyond what `RegisteredCat` already stores (favorites, tags, etc.).

## Further Notes

- The reference screenshot the user shared was for visual pattern only (dashes + prominent header + floating-label fields + pinned CTA), not for content. The "I confirm..." checkbox from the reference is legal consent for an identity-verification flow and is intentionally omitted here.
- The `EmptyStateView` component already exposes `buttonTitle` and `buttonAction`, so no changes to it are needed to add the empty-state CTA in My Cats.
- Success haptic uses `UINotificationFeedbackGenerator` — the only new Apple API touched by the rebuild; everything else stays within SwiftUI, SwiftData, Combine, and the existing `NetworkLayer`.
- After implementation, close the 14 superseded issues and create an umbrella issue plus per-ticket sub-issues via `/to-tickets`. The umbrella issue references this spec.
