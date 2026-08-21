# Solution Notes

A quick write-up of how I put the challenge together, what I traded off, and what I'd still like to fix.

## Architecture decisions

I stayed with MVVM and Combine since the scaffolding was already pointing that way. Each screen has its own `ObservableObject` view model with a small surface: usually a `@Published` state and one or two action methods. Combine only shows up inside the view models (`CatListViewModel` and `AddCatViewModel`), so the SwiftUI views can stay dumb and previewable. I like keeping the reactive plumbing in one place; it's easier to read a month later.

Breeds and Registered Cats are modelled as two different things, with two different screens. A Breed is an encyclopedia entry from the API (description, origin, temperament, life span). A Registered Cat is an actual animal the user created, with a name, age, gender and photo. I did think about merging them into one list, but the two shapes barely overlap and the "Cats" tab name would get confusing fast. There's a short ADR about this at `ApplaudoChallenge/docs/adr/0001-separate-breed-and-registered-cat-models-and-screens.md`.

The folder layout is by feature, not by type. Under `Sources/Modules/` each module (Breeds, My Cats) owns its own Views, ViewModels and Models. The shared stuff sits in `Sources/Components/`, `Sources/Common/` and `Sources/Theme/`. Not a strict rule, just what felt right for two features.

For persistence I went with SwiftData. Registered cats have to survive restarts, and `RegisteredCat` is a `@Model` with a `modelContainer(for:)` injected at the app root. Core Data would've been overkill: the model is tiny, the deployment target is recent, and SwiftData is a lot less code. Photos use `@Attribute(.externalStorage)` so the store stays light, and I downscale images before saving them.

The multi-step registration flow (`AddCatStepperView`) is three step views (identity, details, photo) plus a success screen. All the shared state and validation lives in `AddCatViewModel`. It exposes two error dictionaries (`step1Errors`, `step2Errors`) that each step reads to draw inline messages, and it refuses to advance if the current step is invalid. That's basically Story 5 for free.

Reusing the existing design system. Everything is built on the components that were already there (`AppCard`, `AppButton`, `AppTextField`, `FloatingLabelField`, `EmptyStateView`, `SectionHeader`, `ChipView`, `StepDashesIndicator`, `CachedAsyncImage`) and the tokens in `AppTheme`. I only added new pieces when I really had to; the temperament chips in the breed detail needed a tiny `FlowLayout`, for example.

Loading, empty and error states are treated as real states, not as flags. The list screens use a `ViewState<T>` enum (`idle`, `loading`, `loaded`, `error`) and a single `switch` in the view. Errors show a "Try Again" button that just re-fires the request.

Tests focus on the view models and the service. `CatListViewModelTests`, `AddCatViewModelTests`, `MyCatsViewModelTests` and `CatBreedsServiceTests` (plus `CatBreedTests` for decoding) cover the happy paths, the validation rules and the error mapping. The view models take their service through the initializer, which makes them easy to fake.

## Trade-offs and assumptions

I read "the second tab presents the multi-step form" a bit loosely. The second tab shows the "My Cats" list, and the stepper is one tap away (a `+` in the toolbar, plus a CTA on the empty state). To me a tab is where content lives, and creation actions belong on buttons inside a screen. It also means the user can actually see the cats they've registered instead of them being hidden behind a form. If a stricter reading is preferred, swapping the tab body for `AddCatStepperView` in `ContentView` is a one-liner.

**Photos are optional and get compressed.** The photo step can be skipped. When there is a photo, it gets downscaled and re-encoded as JPEG before being persisted. It keeps the store small and avoids weird surprises with 12 MP camera-roll images.

The breed picker inside the stepper asks for up to 100 breeds in a single call. It's a searchable sheet, so a single bigger batch keeps the UX simple. A proper version would search server-side, but that felt out of scope for a picker.

Confirmation is a dedicated success screen, not a toast. After a save the stepper swaps its content for `AddCatSuccessView`. Clearer than a banner, and it stops the user from accidentally editing something they just submitted.

The API key is committed to the repo. That's how the scaffolding was set up (inside `NetworkingTargetType.swift`), so I left it there to make the reviewer's life easier. In a real project it would live outside the source tree (Arkana, an xcconfig, or a git-ignored secrets file).

Interactive dismissal of the form is disabled once there's data in it. Try to swipe it away and you get a discard confirmation. Slightly more friction, but no accidental data loss.

## What I would improve given more time

- Localisation. All the strings are English literals right now. Moving them into a `Localizable.strings` catalog would open the door to other languages and just make copy changes easier.
- A coordinator or router layer. For two tabs a `NavigationStack` with typed destinations is fine. If the app grew I'd pull navigation out into coordinators so views don't have to know about routing.
- CI. A small GitHub Actions workflow that runs `tuist generate` and the test suite on every PR would catch regressions and, honestly, also serve as living documentation for the build steps.
- Analytics and error reporting. A thin protocol around a logger would make it easy to plug something real in later without touching feature code.
