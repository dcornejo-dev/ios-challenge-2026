# Spec: Story 4 — Pagination for the Breed List

**Status:** Ready for implementation
**Priority:** Plus (bonus)

---

## Problem Statement

The Breed List currently fetches a single fixed page (10 breeds) from The Cat API and stops there. Users see the same first 10 breeds every time and have no way to reach the rest of the ~67-breed catalog. The data layer was intentionally built pagination-ready during Story 1, but the UI never learned to ask for more.

## Solution

The Breed List loads breeds in pages as the user scrolls. When the user approaches the end of the visible list, the next page fetches automatically and the new items append to the bottom without disturbing the rows already on screen. A small spinner shows at the bottom while a page is loading. If a page fails to load, the existing breeds stay visible and a small "Failed to load more — Retry" footer appears in place of the spinner.

## User Stories

1. As a user, I want the Breed List to load a first small page immediately, so that I can start browsing without waiting for the whole catalog.
2. As a user, I want more breeds to load automatically as I scroll toward the bottom, so that I never have to tap a "load more" button.
3. As a user, I want new breeds to slot in seamlessly at the bottom of the list, so that my scroll position and the breeds I was reading stay put.
4. As a user, I want a small spinner at the bottom of the list while more breeds are loading, so that I know the app is working and more items are on the way.
5. As a user, I want the previously loaded breeds to stay visible while the next page is loading, so that I never lose what I was looking at.
6. As a user, I want the app to stop trying to load more breeds once I've reached the end of the catalog, so that I don't see an endless spinner at the bottom.
7. As a user, I want to be told when the next page fails to load, so that I understand why more breeds aren't appearing.
8. As a user, I want a Retry button on that failure footer, so that I can recover from a transient network error without leaving the screen.
9. As a user, I want a pagination failure to leave my already-loaded breeds intact, so that I don't lose progress because of one bad request.
10. As a user, I want the app to *not* auto-retry a failed page each time I scroll, so that a persistent network problem doesn't hammer the server or my battery.
11. As a user, I want the "Try Again" flow on the full-screen initial-load error to reset pagination cleanly, so that pressing it starts a fresh browse from page 0.
12. As a user, I want tapping a breed and returning to keep the paginated list intact, so that navigation into Detail doesn't reset my scroll or reload from scratch.
13. As a user, I want the loading spinner in the pagination footer to match the visual language of the rest of the app, so that the screen feels coherent.

## Implementation Decisions

### State model in the ViewModel

- `CatListViewModel` keeps the existing `ViewState<[CatBreed]>` for the primary "whole screen" state (idle / loading / loaded / error). Pagination does not add a new case to `ViewState` — the shared generic enum stays untouched.
- Two new `@Published` properties on the ViewModel represent pagination:
  - `isLoadingMore: Bool` — true while a next-page request is in flight.
  - `paginationError: String?` — nil when there's no pending failure; a user-readable message when the last next-page fetch failed.
- One private property tracks end-of-data: `hasMorePages: Bool`, initialised to `true` and set to `false` once the API returns a page with fewer items than `pageSize`.
- `currentPage` and `pageSize` (already present) continue to drive the request; `pageSize` stays at 10.

### ViewModel API — two distinct methods

- `fetchBreeds()` — the initial load and the full-screen Retry entry point. Resets `currentPage = 0`, `hasMorePages = true`, `paginationError = nil`, `isLoadingMore = false`. Drives the primary `ViewState` (loading → loaded/error). On success, **replaces** the loaded array and sets `hasMorePages` from the response count.
- `loadNextPage()` — the scroll-driven append. Guarded by `!isLoadingMore && hasMorePages && paginationError == nil`. Increments `currentPage`, sets `isLoadingMore = true`, calls the service, and on success **appends** to the current `.loaded` array. On failure, sets `paginationError` and decrements `currentPage` so a subsequent Retry re-requests the same page.

### Scroll trigger

- `.onAppear` fires on the item at index `breeds.count - 2` in the `ForEach` inside `CatListView`. That one-item lead time lets the next page start fetching before the user is staring at the last row. Guarded for `breeds.count >= 2`.
- No sentinel-view trigger and no threshold in points. Trigger and visual are separated: the ForEach item triggers; the footer view renders the spinner/error.

### End-of-data signal

- After each successful response, `hasMorePages = (response.count == pageSize)`. Short page → we're done. This accepts a single wasted empty request when the total count is an exact multiple of `pageSize`; the resulting brief spinner flash is deemed acceptable and matches how iOS users experience most paginated lists.

### Pagination error UX

- Errors during `loadNextPage()` never blow away the loaded breeds. The `.loaded` state is preserved and `paginationError` carries a user-readable message.
- A dedicated `PaginationFooter` view renders under the `ForEach` and switches on `(isLoadingMore, paginationError)`:
  - loading → centred `ProgressView`.
  - error → row with the error message and a Retry button whose action is `viewModel.loadNextPage()`.
  - otherwise → `EmptyView`.
- After a pagination error, scroll re-entries do **not** auto-retry. The user must tap Retry. This is enforced by `paginationError == nil` in the `loadNextPage()` guard.

### Modules touched

- `CatListViewModel` — new published properties, new `loadNextPage()`, `fetchBreeds()` updated to reset pagination state.
- `CatListView` — trigger `.onAppear` on the second-to-last row; render `PaginationFooter` under the `ForEach`.
- `PaginationFooter` — new small view colocated with `CatListView` in `Sources/Modules/Breeds/Views/`. Not promoted to the shared component set until a second paginated screen exists.
- `NetworkLayer` — no changes. `CatBreedsTarget` and `CatBreedsService` already accept `page` and `limit`.
- `ViewState` — no changes.

## Testing Decisions

### What makes a good test

Tests verify externally observable ViewModel behaviour — what it publishes given specific service responses, and which pages it asks for — not the Combine operator graph or the specific closure names. A test should still pass if `loadNextPage` is refactored internally as long as the requested pages, appended results, error message, and end-of-data behaviour are unchanged.

### Primary seam: `CatBreedsServiceType`

The same protocol used by Story 1's tests. Continue mocking it. The pagination tests specifically need to observe *which* pages were requested, so `MockCatBreedsService` gains:

- A page-keyed result map: `[Int: Result<[CatBreed], NetworkError>]`. Unmapped pages default to `.success([])`.
- A `requestedPages: [Int]` log recording each call. To keep mutations visible across the Combine hop, the mock uses a reference type (or wraps the log in a class-backed box).

### Tests to add against that seam

- `loadNextPage appends the second page to the loaded list` — page 0 returns 10 items, page 1 returns 10 items; final `.loaded` count is 20 and the order is preserved.
- `loadNextPage does not fire while a previous loadNextPage is in flight` — two rapid calls result in only one page-1 request in `requestedPages`.
- `loadNextPage does not fire once hasMorePages is false` — after receiving a short page, subsequent calls are no-ops.
- `loadNextPage sets paginationError on failure and keeps loaded breeds visible` — `.loaded` value is unchanged; `paginationError` is a non-empty string.
- `loadNextPage after error retries the same page number` — assert `requestedPages` equals `[0, 1, 1]` (not `[0, 1, 2]`).
- `fetchBreeds resets pagination state` — after a paginated session, calling `fetchBreeds()` again requests page 0 first, clears `paginationError`, and restores `hasMorePages`.

Existing `CatListViewModelTests` cases are updated to the new mock initialiser but their observable behaviour is unchanged.

### Prior art

- Swift Testing (`import Testing`, `@Test`, `@Suite`) is the convention; follow it.
- Existing mock helpers (`isIdle`, `isLoading`, `loadedValue`, `errorMessage`) are reused as-is.

## Out of Scope

- **Pull-to-refresh** on the Breed List — not in the acceptance criteria for Story 4. If added later, it would call `fetchBreeds()`, which already resets pagination.
- **Prefetching images** for next-page items — the current per-row `AsyncImage` handles image loading; no proactive prefetch.
- **Cursor-based pagination** — The Cat API uses offset-based (`page` + `limit`) pagination; no change to that contract.
- **Caching or persistence of paginated results** across app launches — each launch starts at page 0.
- **Pagination for the "My Cats" (registered cats) screen** — that list is local storage and not currently large enough to warrant pagination.
- **Search or filter** interacting with pagination — no search exists yet.
- **Animated insertion of newly appended rows** — `LazyVStack`'s default rendering is deemed sufficient.

## Further Notes

- The Cat API returns no total-count field in the response body, so end-of-data is inferred from short pages. On exact-multiple totals (e.g. 20 breeds with `pageSize = 10`) one empty request is issued before `hasMorePages` flips off. This is an accepted tradeoff for a simple, self-correcting termination signal.
- `pageSize = 10` matches Story 1's existing constant and yields ~7 pages against the current ~67-breed catalog. No reason to change it as part of this story.
- The `AppCard` component is unchanged; new pages simply produce more instances rendered by `LazyVStack`.
- `PaginationFooter` colocates with `CatListView` intentionally — YAGNI. If a second paginated screen appears (e.g. Registered Cats grows), the footer is trivially lifted into the shared components folder at that point.
