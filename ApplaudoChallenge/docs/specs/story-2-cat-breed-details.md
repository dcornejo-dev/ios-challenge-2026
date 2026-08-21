# Spec: Story 2 — Cat Breed Details

**Status:** Ready  
**Priority:** Core

---

## Problem Statement

Users can browse a list of cat breeds, but tapping a breed leads to a placeholder screen. There is no way to learn more about a specific breed — its appearance, origin, temperament, or life span. The list alone doesn't give enough context to make the app useful as a breed explorer.

## Solution

Tapping any breed in the list navigates to a detail screen that shows a hero image of the breed, its full description, origin, temperament (as visual trait chips), and life span. When no image is available, a themed placeholder keeps the layout consistent. The user can navigate back to the list at any time.

## User Stories

1. As a user, I want to see a large photo of the breed at the top of the detail screen, so that I can immediately recognize what the breed looks like.
2. As a user, I want to see a placeholder image when no breed photo is available, so that the screen doesn't look broken or empty.
3. As a user, I want to see a loading indicator while the breed image is being fetched, so that I know the image is on its way.
4. As a user, I want to see the breed's full description, so that I can understand its personality and characteristics.
5. As a user, I want to see the breed's country of origin, so that I know where the breed comes from.
6. As a user, I want to see the breed's temperament traits displayed as individual chips, so that I can quickly scan what the breed is like.
7. As a user, I want to see the breed's life span, so that I can understand how long the breed typically lives.
8. As a user, I want the detail screen to scroll when the content exceeds the screen height, so that I can see everything on smaller devices.
9. As a user, I want to navigate back to the breed list from the detail screen, so that I can continue browsing other breeds.
10. As a user, I want the breed's name displayed as the navigation title, so that I always know which breed I'm looking at.
11. As a user, I want the detail screen to feel visually consistent with the rest of the app, so that the experience feels polished and cohesive.
12. As a user, I want the image to maintain a consistent aspect ratio regardless of the source photo, so that the layout doesn't shift or look distorted.

## Implementation Decisions

### Data Flow
- The detail screen is a **pure View** — no ViewModel, no additional API call. The `CatBreed` model passed from the list already contains all required fields (description, origin, temperament, life span).
- AsyncImage handles its own loading/error states internally, so no `ViewState` management is needed.

### Image Loading
- **SwiftUI `AsyncImage`** is used directly — no custom caching layer or reusable image component. URLSession's default caching is sufficient for this use case.
- The breed image URL is constructed from the model's `referenceImageId` field using The Cat API's CDN pattern.
- A **computed `imageURL: URL?` property** is added to `CatBreed` via an extension. This keeps the URL construction logic with the model (it derives from the model's own data) and makes it reusable from any screen.
- When `referenceImageId` is nil, `imageURL` returns nil and the view shows an **SF Symbol placeholder** (cat icon on a themed background), keeping the layout structurally consistent.

### Image Sizing
- The hero image uses a **4:3 aspect ratio** (`.aspectRatio(4/3, contentMode: .fill)`) with clipping. This provides consistent visual weight across different breed photos and device sizes.

### Layout
- **Hero image at the top** followed by **scrollable sections** below — the standard iOS detail pattern.
- Each data section (Description, Origin, Temperament, Life Span) uses the existing **`SectionHeader` component** with contextual SF Symbol icons to maintain design system consistency.

### Temperament Display
- The comma-separated temperament string is split and rendered as **individual chip/tag pills** in a flowing grid.
- A new **`ChipView` component** is created in `Components/` — a small, themed pill displaying a single trait label. This component is reusable for any tag/chip UI that may appear in future stories.
- Chips are laid out using **`LazyVGrid` with `.adaptive(minimum:)`** columns for natural wrapping behavior.

### Navigation
- Already wired in Story 1 via `NavigationLink(value: breed)` and `.navigationDestination(for: CatBreed.self)`. Implementation replaces the placeholder `Text` with the new `CatDetailView`.
- The breed name is set as the `.navigationTitle`. Standard NavigationStack back button handles return navigation.

### Weight Field
- The `CatBreed` model has weight data (imperial/metric), but it is **not displayed** on the detail screen. The acceptance criteria call for image, description, origin, temperament, and life span — weight is excluded to keep the screen focused on required fields.

## Testing Decisions

### What makes a good test
Tests should verify external behavior — computed outputs given specific inputs — not implementation details. For a pure View feature with minimal logic, the testable surface is small and focused on the model extension.

### Primary seam: `CatBreed.imageURL` computed property
- Test URL construction: given a breed with a known `referenceImageId`, verify the computed URL matches the expected CDN pattern.
- Test nil handling: given a breed where `referenceImageId` is nil, verify `imageURL` returns nil.
- This seam lives in the `NetworkLayerTests` target since `CatBreed` is defined in the NetworkLayer module.

### No ViewModel seam
- There is no ViewModel to test. The detail View is a stateless rendering of the passed `CatBreed` — its correctness is verified by visual inspection (running the app), not unit tests.

### Prior art
- `CatBreedsServiceTests.swift` in the NetworkLayer test target — tests model behavior and decoding at the same level where the `imageURL` tests would live.
- `CatListViewModelTests.swift` — demonstrates the mock/protocol pattern, though not directly applicable here (no ViewModel).

## Out of Scope

- **Custom image caching** — AsyncImage with URLSession defaults is sufficient; no NSCache wrapper or third-party image library.
- **Weight display** — data is available in the model but excluded from the detail screen per design decision.
- **Image gallery or multiple images** — only the single reference image is shown.
- **Favorite/bookmark functionality** — not part of the challenge requirements.
- **Share or export** — not required.
- **Breed comparison** — not required.
- **Offline detail view** — breed data comes from the list (already in memory), but the image requires a network connection.

## Further Notes

- The Cat API CDN URL pattern is `https://cdn2.thecatapi.com/images/{referenceImageId}.jpg`. This is a well-known, stable pattern for this API. If it changes, only the `imageURL` computed property needs updating.
- `ChipView` is intentionally minimal — a styled text label in a pill shape using theme tokens. It does not support icons, actions, or dismissal. It can be extended for Story 3 (form) if needed.
- The 4:3 aspect ratio was chosen to balance visual impact with content visibility on smaller screens. Most cat breed reference images are landscape-oriented, so this ratio avoids excessive letterboxing.
