# Spec: Story 1 — Browse Cat Breeds

**Status:** Implemented  
**Priority:** Core

---

## Problem Statement

The app launches with an empty placeholder on the first tab. Users have no way to discover or browse the cat breeds available in The Cat API. Without a breed list, the app has no primary content and the detail screen (Story 2) has no entry point.

## Solution

The first tab displays a scrollable list of cat breeds fetched from The Cat API. Each item shows the breed's name and a brief description. The list handles loading, empty, and error states gracefully, giving the user clear feedback at every stage. Tapping a breed navigates to a detail screen where the user can learn more.

## User Stories

1. As a user, I want to see a list of cat breeds when I open the app, so that I can explore what's available without any extra steps.
2. As a user, I want to see each breed's name prominently displayed, so that I can quickly scan the list and find breeds I'm interested in.
3. As a user, I want to see a brief description of each breed in the list, so that I get a preview of what makes each breed unique without tapping into it.
4. As a user, I want to see a loading indicator while breeds are being fetched, so that I know the app is working and not frozen.
5. As a user, I want to see a friendly message when no breeds are available, so that I understand the list is empty rather than broken.
6. As a user, I want to see a clear error message when the breed list fails to load, so that I understand what went wrong.
7. As a user, I want a "Try Again" button on the error screen, so that I can retry fetching breeds without restarting the app.
8. As a user, I want to tap a breed to navigate to its detail screen, so that I can learn more about it.
9. As a user, I want to navigate back from the detail screen to the breed list, so that I can continue browsing.
10. As a user, I want the breed list to maintain its scroll position when I return from a detail screen, so that I don't lose my place.
11. As a user, I want the list to scroll smoothly even with many breeds, so that the browsing experience feels responsive.
12. As a user, I want each list item to look visually consistent with the app's design, so that the interface feels polished and cohesive.

## Implementation Decisions

### Data Model
- A single `CatBreed` struct serves both the list and detail screens. It decodes only the fields the app uses: id, name, description, origin, temperament, life span, weight, and reference image ID. Additional API fields are ignored.
- `CatBreed` conforms to `Decodable`, `Hashable` (for navigation), and `Identifiable` (for SwiftUI lists).
- Explicit `CodingKeys` map the API's snake_case fields (`life_span`, `reference_image_id`) to Swift's camelCase.

### Networking
- A new `CatBreedsTarget` enum in the NetworkLayer module defines the `/breeds` endpoint, separate from the existing `CatInformationTarget`. Each target enum represents one API domain.
- The target accepts `page` and `limit` parameters from the start, making it pagination-ready for Story 4.
- A `CatBreedsService` (protocol + concrete implementation) lives in the NetworkLayer module, following the module's documented pattern. The service uses the two-init pattern: a public parameterless init for the app, and an internal init accepting a `NetworkingRequesterType` for testing.

### Architecture
- MVVM: `CatListViewModel` is an `ObservableObject` that owns a `@Published` state property and talks directly to the service protocol.
- View state is represented by a generic `ViewState<T>` enum with cases `.idle`, `.loading`, `.loaded(T)`, `.error(String)`. This makes illegal states unrepresentable — the view can never simultaneously show loading and an error.
- The ViewModel takes `CatBreedsServiceProtocol` via init injection with a default parameter providing the real implementation. This enables testing without SwiftUI environment setup.

### Data Flow
- Full Combine pipeline: the service returns `AnyPublisher<[CatBreed], NetworkError>`, the ViewModel subscribes with `.receive(on: DispatchQueue.main).sink`, and stores cancellables in a `Set<AnyCancellable>`.
- Data fetching is triggered by the view's `.task` modifier (not in ViewModel init), keeping initialization side-effect-free and testable.

### UI
- The breed list uses the existing `AppCard` component with the breed name as title, description as subtitle, a cat SF Symbol as icon, and a chevron indicating tappability.
- No images in the list — breed images are deferred to the detail screen (Story 2) to avoid per-row async image loading complexity.
- Error and empty states use the existing `EmptyStateView` component. The error state includes a "Try Again" action button.
- `LazyVStack` inside `ScrollView` for efficient rendering and future pagination support.
- `.buttonStyle(.plain)` on `NavigationLink` to prevent default blue tinting of card content.

### Navigation
- Value-based `NavigationLink(value:)` with `.navigationDestination(for: CatBreed.self)` — the modern SwiftUI pattern.
- `NavigationStack` lives in `ContentView`, not inside `CatListView`. The list view registers its navigation destinations on the enclosing stack.

## Testing Decisions

### What makes a good test
Tests should verify external behavior — what the ViewModel publishes given specific service responses — not implementation details like which Combine operators were used or how many times a publisher emitted. A test that breaks when you refactor internals without changing behavior is a bad test.

### Primary seam: `CatBreedsServiceProtocol`
- Mock the service protocol to return controlled publishers (success with breeds, success with empty array, failure with specific errors).
- Test that `CatListViewModel` transitions through the correct `ViewState` cases: idle → loading → loaded/error.
- Test that the error state contains a user-readable message.
- Test that calling `fetchBreeds()` again after an error resets to loading.
- This seam lives in the `ApplaudoChallengeTests` target.

### Secondary seam: `NetworkingRequesterType`
- Mock the requester to return raw JSON data.
- Test that `CatBreedsService` correctly constructs the request (path, parameters) and decodes the response into `[CatBreed]`.
- Test decoding edge cases: missing optional fields (`reference_image_id` being null), snake_case mapping.
- This seam lives in the `NetworkLayerTests` target.

### Prior art
- The existing test targets use Swift Testing (`import Testing`, `@Test` macro) — follow this convention.
- Both test files are currently empty placeholders.

## Out of Scope

- **Breed images in the list** — deferred to Story 2 (detail screen).
- **Pagination / infinite scroll** — the data layer is pagination-ready (page/limit params), but the scroll trigger and "load more" UI are Story 4.
- **Search or filtering** — not part of the challenge requirements.
- **Offline caching** — breeds are fetched fresh on each app launch.
- **Detail screen content** — Story 2. The current implementation shows a text placeholder.
- **Unit tests** — test implementation is tracked separately; this spec covers the feature behavior.

## Further Notes

- The API key is configured directly in `NetworkingTargetType.swift` as a default header. This is per the challenge's scaffolding pattern — not how a production app would handle secrets, but appropriate for this context.
- The `AppCard` subtitle shows the full breed description, which can be 2-3 sentences. SwiftUI's text layout handles this naturally without explicit line limits, but this should be monitored for visual consistency as more breeds load.
- The list currently fetches 10 breeds (page 0, limit 10). When Story 4 (pagination) is implemented, the ViewModel already tracks `currentPage` and `pageSize` — only the scroll trigger and append logic need to be added.
