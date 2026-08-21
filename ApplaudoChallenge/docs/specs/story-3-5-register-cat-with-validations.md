# Spec: Story 3 & 5 — Register a New Cat + Form Validations

**Status:** Ready  
**Priority:** Core (Story 3) + Plus (Story 5)

---

## Problem Statement

The app's second tab is a static placeholder with no functionality. Users have no way to register their own cats — the app is read-only, limited to browsing API breeds. Without a registration flow, the app has no user-generated content and no local data persistence, missing a core feature of the challenge.

Additionally, with no input validation, users could submit incomplete or nonsensical data (empty names, negative ages, single-character descriptions), resulting in low-quality entries that undermine the purpose of the registration form.

## Solution

The second tab presents a guided multi-step registration form with three steps: Basic Info (photo, name, breed), Details (age, description), and Review (summary with save). Each step validates its fields before allowing the user to advance, showing inline error messages next to invalid fields. On save, the cat is persisted locally using SwiftData and survives app restarts. The user receives visual confirmation of the successful registration and can register another cat or start fresh.

## User Stories

1. As a user, I want to see a multi-step form on the second tab, so that registering a cat feels guided and organized rather than overwhelming.
2. As a user, I want to see a step indicator at the top of the form, so that I always know which step I'm on and how many remain.
3. As a user, I want to enter my cat's name in the first step, so that I can identify my cat.
4. As a user, I want to select my cat's breed from a searchable list of known breeds, so that I don't have to type or guess the exact breed name.
5. As a user, I want to search within the breed picker by typing, so that I can quickly find the right breed among many options.
6. As a user, I want to see a loading indicator while breeds are being fetched for the picker, so that I know the app is working.
7. As a user, I want to see an error state in the breed picker if breeds fail to load, so that I understand what went wrong and can retry.
8. As a user, I want to optionally add a photo of my cat from my photo library, so that my registered cat has a visual identity.
9. As a user, I want to see a preview of my selected photo in the form, so that I can confirm I picked the right image.
10. As a user, I want to enter my cat's age as a number in the second step, so that the form captures how old my cat is.
11. As a user, I want to write a short description of my cat, so that I can capture what makes my cat special.
12. As a user, I want to review all entered information on the final step before saving, so that I can catch and correct mistakes.
15. As a user, I want to see my selected photo in the review summary, so that I can confirm the complete entry before committing.
16. As a user, I want to tap "Save" to persist my cat locally, so that the entry survives even if I close the app.
17. As a user, I want to see a visual confirmation after saving, so that I know the registration succeeded.
18. As a user, I want a "Register Another" option after saving, so that I can add multiple cats without navigating away.
19. As a user, I want a "Done" option after saving, so that I can reset the form when I'm finished.
20. As a user, I want to navigate back to a previous step, so that I can correct information I entered earlier.
21. As a user, I want my entered data to be preserved when navigating between steps, so that I don't lose progress.
22. As a user, I want to be told when I've left a required field empty before advancing, so that I can fill it in without guessing what's wrong.
23. As a user, I want to see the validation error inline next to the specific field that's invalid, so that I know exactly which field to fix.
24. As a user, I want the error to disappear when I start editing the invalid field, so that I know my correction is being acknowledged.
25. As a user, I want to be told when my cat's name is too short, so that I can provide a meaningful name.
26. As a user, I want to be told when the age I entered is not a valid number, so that I can correct it.
27. As a user, I want to be told when my description is too short, so that I write something meaningful.
28. As a user, I want the "Next" button to always be tappable (not grayed out), so that tapping it tells me what I need to fix rather than leaving me confused about why I can't proceed.

## Implementation Decisions

### Data Model
- A new `RegisteredCat` entity is created, completely separate from `CatBreed`. A registered cat is an individual pet; a `CatBreed` is an encyclopedia entry from the API. They share no inheritance or protocol.
- `RegisteredCat` is a SwiftData `@Model` class with properties: name, breedName, breedId (strings referencing the API breed), age (integer), shortDescription (avoiding the `description` name collision with `CustomStringConvertible`), color, gender (stored as raw string for SwiftData simplicity), optional photo data (with external storage attribute), and a createdAt timestamp. The color and gender stored properties are retained for schema compatibility but are no longer collected in the UI.
- A `CatGender` enum (`male`, `female`, `unknown`) with `CaseIterable` conformance provides type safety; its `rawValue` is what gets stored. Gender is no longer exposed in the registration form.
- Coat color options (`CatColor` enum) are retained in the codebase for schema compatibility but are no longer exposed in the registration form.

### Persistence
- SwiftData is the persistence framework. The model container is initialized at the app entry point on the `WindowGroup` scene.
- Photo data uses SwiftData's `@Attribute(.externalStorage)` to let the framework manage large binary blobs on disk rather than in the database.

### Architecture
- A single `AddCatViewModel` (ObservableObject) owns all form state, validation logic, breed fetching, and save orchestration. Step views are thin UI slices that read and write to this shared ViewModel.
- The ViewModel takes `CatBreedsServiceType` via init injection (same pattern as `CatListViewModel`) to enable testing and breed fetching for the picker.
- The `ModelContext` for SwiftData is passed to the save method from the view's `@Environment(\.modelContext)` — the ViewModel does not own or inject the context.
- Form field values are `@Published` properties on the ViewModel. Validation errors are dictionaries mapping field names to error message strings, one per step.

### Form Steps
- **Step 1 — Basic Info**: Photo picker (optional, using PhotosUI `PhotosPicker`), cat name (text field), breed (tappable field that opens a searchable sheet).
- **Step 2 — Details**: Age (number pad text field, validated as integer), short description (text field).
- **Step 3 — Review**: Read-only summary of all entered data with section headers. Photo preview if provided. A single "Save" action button.

### Breed Picker
- Presented as a `.sheet` containing a search bar and scrollable list of `CatBreed` entries fetched via the existing `CatBreedsService`.
- Breeds are fetched once when the ViewModel loads (via `.task` in the stepper view). The picker sheet reads from the already-loaded list and filters locally by search query.
- Loading and error states are handled inside the sheet using the existing `ViewState` and `EmptyStateView` patterns.
- On selection, the ViewModel stores `breedName` and `breedId` as strings — not the full `CatBreed` object — to decouple the registered cat from the API model.

### Photo Picker
- Uses `PhotosUI.PhotosPicker` (iOS 16+). Selected item is loaded as JPEG data at reasonable compression quality.
- A circular image preview is shown in Step 1 and in the Review step.

### Validation (Story 5)
- Validation fires only when the user taps "Next" (or "Save" on the review step). Errors are not shown while the user is still typing.
- Each field clears its own error message when the user edits it, providing immediate feedback that the correction is being registered.
- Validation rules: name must be at least 2 characters; breed must be selected (non-empty); age must be an integer between 1 and 30; short description must be at least 10 characters. Photo is optional.
- The "Next" button remains enabled at all times. Tapping it with invalid fields shows errors inline but does not advance.

### Post-Save Flow
- After a successful save, the review step transitions to a success state: a checkmark visual and "Cat Registered!" confirmation text.
- Two buttons appear: "Register Another" (resets all fields and returns to step 1) and "Done" (also resets the form).
- This follows Apple's HIG pattern for multi-step form completion — inline success feedback without navigation disruption.

### UI Components Reused
- `StepperIndicator` for the step progress bar (3 steps: "Basic Info", "Details", "Review").
- `AppTextField` for all text inputs, leveraging its built-in `errorMessage` parameter for inline validation display.
- `AppButton` for Next, Back, and Save actions, using its `isEnabled` and `isLoading` states.
- `SectionHeader` for labeled sections in the Review step.
- `AppTheme` tokens for all visual styling.
- `ViewState<T>` for breed loading state in the picker.

## Testing Decisions

### What makes a good test
Tests should verify external behavior — the ViewModel's published state given specific inputs and actions — not implementation details like which Combine operators are used or how many times a publisher fires. Validation logic is the richest testable surface here: given specific field values, does `validateAndAdvance()` produce the correct errors or advance the step?

### Primary seam: `AddCatViewModel` via `CatBreedsServiceType`
- Mock `CatBreedsServiceType` using the same closure-based mock pattern from `CatListViewModelTests` to control breed fetching.
- **Validation tests**: verify that each validation rule produces the correct error message for invalid input and no error for valid input. Test boundary cases (name exactly 2 chars, age exactly 1 and 30, description exactly 10 chars).
- **Step navigation tests**: verify that `validateAndAdvance()` increments `currentStep` only when the current step is valid. Verify that `goBack()` decrements without validation.
- **Breed loading tests**: verify that `fetchBreeds()` transitions through loading → loaded/error states, same pattern as the existing `CatListViewModelTests`.
- **Error clearing tests**: verify that editing a field with an error clears that field's error message.
- **Save tests**: use an in-memory `ModelContainer` to verify that `save(context:)` inserts a `RegisteredCat` with the correct field values and sets `isSaved` to true.
- **Reset tests**: verify that `reset()` clears all fields and sets `currentStep` back to 0.
- This seam lives in the `ApplaudoChallengeTests` target.

### Prior art
- `CatListViewModelTests.swift` — demonstrates the mock service pattern, async Combine testing with `Task.sleep`, and `ViewState` assertion helpers.
- `CatBreedsServiceTests.swift` — demonstrates the mock requester pattern and JSON decoding verification.

## Out of Scope

- **Displaying saved cats in a list** — no saved-cats list view is built. Cats are persisted but surfacing them is a potential future enhancement.
- **Editing or deleting registered cats** — the spec covers creation only.
- **Syncing registered cats to the API** — cats are local-only; no POST endpoint is used.
- **Camera capture** — only photo library selection is supported, not live camera.
- **Multi-photo support** — one optional photo per cat.
- **Offline breed picker** — the picker requires an API connection to load breeds. If breeds fail to load, the error state offers retry.
- **Pagination in the breed picker** — all breeds are fetched in one request. The list is small enough (~60 breeds) that pagination adds no value in the picker context.
- **Form draft auto-save** — if the user leaves the tab mid-form, the in-memory state is lost. Persisting partial drafts is unnecessary for this challenge scope.

## Further Notes

- Stories 3 and 5 are specced together because validation is intrinsic to the multi-step form — building the form without validation and retrofitting it later would mean restructuring the ViewModel's advance logic. Designing them as one unit produces a single, coherent validation architecture.
- The `RegisteredCat` model lives in the app target (not NetworkLayer) because persistence is an app-layer concern. The NetworkLayer module stays focused on API communication.
- The breed picker fetches breeds independently from the breed list on Tab 1. This keeps the two features decoupled — the picker works even if the user hasn't visited the breed list, and they don't share ViewModel state.
