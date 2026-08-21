# Spec: Story 6 — View Registered Cats

**Status:** Ready  
**Priority:** Plus

---

## Problem Statement

Users can register cats through the multi-step form (Story 3), but after saving, there is no way to view, verify, or revisit those cats anywhere in the app. The data is persisted with SwiftData but completely invisible — a write-only flow. From a user perspective, saving something you can never see again feels broken. From a reviewer perspective, there is no way to confirm that persistence actually works without inspecting the device's file system.

## Solution

A new "My Cats" tab is added between the existing "Cats" (breed list) and "Add Cat" tabs. It displays all locally registered cats in a list, sorted newest-first. Tapping a cat navigates to a detail screen showing every field the user entered during registration: photo, name, breed, age, gender, color, description, and the date it was registered. The "Done" button on the registration success screen now switches to the "My Cats" tab so the user immediately sees their new cat in the list. When no cats have been registered yet, the list shows an informational empty state.

## User Stories

1. As a user, I want to see a "My Cats" tab in the tab bar, so that I have a dedicated place to find cats I've registered.
2. As a user, I want the "My Cats" tab to use a pawprint icon, so that it's visually distinct from the breed catalog tab.
3. As a user, I want the tab bar to read "Cats | My Cats | Add Cat" left to right, so that the progression from browsing to collecting to creating feels natural.
4. As a user, I want to see a list of all cats I've registered, so that I can revisit them after saving.
5. As a user, I want my most recently registered cat to appear at the top of the list, so that I can find it immediately after registering.
6. As a user, I want each cat in the list to show its name, breed, and age, so that I can distinguish between cats at a glance.
7. As a user, I want to see a small thumbnail of my cat's photo in the list card if I provided one, so that I can visually identify each cat.
8. As a user, I want to see a pawprint icon as a fallback when a cat has no photo, so that the card still looks complete.
9. As a user, I want to tap a cat in the list to see its full detail screen, so that I can review everything I entered.
10. As a user, I want the detail screen to show my cat's photo prominently at the top, so that it mirrors the visual hierarchy of the breed detail screen.
11. As a user, I want the detail screen to show a placeholder image when no photo was provided, so that the layout doesn't break.
12. As a user, I want to see my cat's name as the screen title, so that I always know which cat I'm viewing.
13. As a user, I want to see my cat's breed, age, gender, and color in an info section, so that I can review the basic facts.
14. As a user, I want to see my cat's description on the detail screen, so that I can read what I wrote about my cat.
15. As a user, I want to see the date my cat was registered, so that I have a reference for when the entry was created.
16. As a user, I want to see an empty state when I haven't registered any cats yet, so that I understand the list is empty on purpose and know where to go to add one.
17. As a user, I want the empty state to mention the "Add Cat" tab, so that I'm guided toward registering my first cat.
18. As a user, I want the "Done" button after registration to take me to the "My Cats" tab, so that I can immediately see my new cat in the list.
19. As a user, I want the "Register Another" button to stay on the "Add Cat" tab and reset the form, so that I can keep adding cats without interruption.
20. As a user, I want cats I registered in previous app sessions to still appear in the list, so that I can trust that persistence works across restarts.

## Implementation Decisions

### Navigation and Tab Bar
- `ContentView` gains a `@State` property for the selected tab index. The tab bar renders three tabs: "Cats" (index 0, `cat` icon), "My Cats" (index 1, `pawprint` icon), "Add Cat" (index 2, `plus.circle` icon).
- The selected tab state is passed as a `@Binding` to the `AddCatStepperView` so that the "Done" button can programmatically switch to the "My Cats" tab.

### My Cats List (MyCatsView)
- Uses the existing `AppCard` component for list items. Title is the cat's name. Subtitle is "{breedName} · {age} years old". When the cat has photo data, the card displays a small circular thumbnail; otherwise it falls back to the `pawprint` SF Symbol. Chevron is shown to indicate tappable navigation.
- Wraps each card in a `NavigationLink(value:)` using the same value-based navigation pattern as the breed list.
- The list is a `ScrollView` with a `LazyVStack`, consistent with `CatListView`.
- Empty state uses `EmptyStateView` with the `pawprint` system image, title "No Cats Yet", and a message directing the user to the "Add Cat" tab. No action button — the tab bar provides the navigation.

### My Cats ViewModel (MyCatsViewModel)
- A `final class` conforming to `ObservableObject`, following the existing ViewModel conventions.
- Queries `RegisteredCat` entities from SwiftData's `ModelContext`, sorted by `createdAt` descending (newest first).
- Exposes a `@Published` array of `RegisteredCat` for the view to render.
- Takes `ModelContext` as a dependency to enable testing with in-memory containers.
- Provides a `fetchCats()` method called from the view's `.task` modifier, consistent with how `CatListView` triggers data loading.

### Registered Cat Detail (RegisteredCatDetailView)
- Accepts a `RegisteredCat` value and renders it read-only.
- Layout from top to bottom: hero photo (or placeholder), name as navigation title, info section (breed, age, gender, color), description section, registered date as a subtle footer.
- The hero image area follows the same 4:3 aspect ratio pattern as `CatDetailView`. When photo data exists, it renders as a `UIImage` from `Data`. When absent, shows a placeholder with the `pawprint` SF Symbol on a surface-colored background, mirroring the breed detail placeholder pattern.
- Info fields use a key-value layout with `SectionHeader` for section titles, reusing the same component pattern from `CatDetailView`.
- Gender displays the `CatGender` enum's `displayName` (capitalized).
- Date is formatted with a medium date style.

### "Done" Button Tab Switch
- The success view's "Done" button sets the bound `selectedTab` to the "My Cats" tab index, then calls `viewModel.reset()`. This switches the user to the "My Cats" tab where their new cat appears at the top of the list.
- "Register Another" continues to only call `viewModel.reset()` and stays on the "Add Cat" tab, preserving its current behavior.

### RegisteredCat Conformances
- `RegisteredCat` needs `Hashable` conformance to work with `NavigationLink(value:)` and `.navigationDestination(for:)`. SwiftData `@Model` classes are reference types, so identity-based hashing (using `persistentModelID`) is appropriate.

### No New Networking or Services
- This feature is entirely local. No new service protocols, no API calls, no NetworkLayer changes.

## Testing Decisions

### What makes a good test
Tests verify the ViewModel's published state given specific SwiftData contents — not view rendering, not SwiftData internals. The interesting behavior is: given N registered cats in the store, does the ViewModel expose them in the correct order? Given zero cats, is the list empty?

### Primary seam: MyCatsViewModel via in-memory ModelContainer
- Create an in-memory `ModelContainer` for `RegisteredCat` (same technique used in `AddCatViewModelTests` for the save test).
- Insert test `RegisteredCat` entities with known `createdAt` timestamps.
- Verify that `fetchCats()` populates the published array in newest-first order.
- Verify that an empty container results in an empty array.
- Verify that a newly inserted cat appears after re-fetching.

### Prior art
- `AddCatViewModelTests.swift` — demonstrates in-memory `ModelContainer` creation and `RegisteredCat` insertion for testing SwiftData behavior.
- `CatListViewModelTests.swift` — demonstrates the ViewModel testing pattern with published state assertions and async settling.

## Out of Scope

- **Editing registered cats** — the list and detail are read-only. No edit flow.
- **Deleting registered cats** — no swipe-to-delete or delete action. Read-only list.
- **Searching or filtering registered cats** — the list shows all cats, unfiltered.
- **Syncing registered cats to the API** — cats remain local-only.
- **Sharing or exporting cat data** — no share sheet or export functionality.

## Further Notes

- This spec closes the gap identified in the Story 3 & 5 out-of-scope section: "Displaying saved cats in a list — no saved-cats list view is built." It is the natural completion of the registration flow.
- The `RegisteredCat` model already exists and requires no schema changes — only a `Hashable` conformance addition for navigation support.
- The feature reuses existing components (`AppCard`, `EmptyStateView`, `SectionHeader`) and follows the established visual patterns from `CatListView` and `CatDetailView`, keeping the codebase consistent.
- The domain distinction between Breed (API category) and Registered Cat (user's individual pet) is documented in `CONTEXT.md` and ADR `0001-separate-breed-and-registered-cat-models-and-screens.md`.
