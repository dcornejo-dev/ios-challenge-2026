# Spec: Story 3 & 5 — Visual Reskin of the Registered Cat Registration Flow

**Status:** Ready  
**Priority:** Plus  
**Supersedes:** the Apple HIG refactor spec, now withdrawn — see Further Notes

---

## Problem Statement

The flow for registering a Registered Cat works correctly but looks like a generic form rather than a considered product. Numbered stepper circles with captions compete with a navigation title and an in-content section header, so three different titles are on screen at once. Fields are gray-filled boxes with leading icons and labels floating outside them. The primary red is spent everywhere at once — on chips, outlines, icons, connectors, and a destructive-looking "Remove Photo" link — so nothing on screen reads as the one thing the user should do next. Two buttons sit side by side at the bottom of steps one and two, while step three has no button bar at all and hides its save action inside a scroll view.

The result is a flow that is functional but visually noisy and internally inconsistent, and it undersells the rest of the app. A reference design was supplied showing a calmer, more confident treatment, and the registration flow is the most-scrutinized surface in the product.

Separately, coat colour and gender were collected during registration but were never displayed anywhere the user could see them — the Registered Cat detail screen delivered in Story 6 does not show either field. Users are being asked for information that the product never uses.

## Solution

The three registration steps, the review step, and the success confirmation are restyled to a single calm visual language, while their behaviour, validation rules, copy, and step structure stay exactly as they are.

The numbered stepper becomes a row of three small dashes. The in-content section header becomes the screen's visual anchor — a large bold title with a grey subtitle beneath it — while the navigation bar keeps a quiet inline "Add Cat" for context. Fields become white, outlined by a hairline border, with the field's label floating inside the box above the value and persistent grey helper text below carrying the input rules. Leading field icons are removed. A single full-width pill button pins to the bottom of every step, and backward navigation moves to the navigation bar. Colour is spent in exactly one place per screen: the call to action.

Coat colour and gender are removed from the registration form and from the review summary. Because the local persistence schema cannot safely drop stored properties without risking a launch failure on devices that already hold Registered Cats, the underlying schema is left untouched and the removal is confined to the form and the ViewModel.

## User Stories

1. As a user registering a cat, I want each step to open with one large, obvious title, so that I immediately know what this step is asking of me.
2. As a user, I want a grey explanatory line under each step's title, so that I understand the purpose of the step without reading the fields first.
3. As a user, I want only one title competing for my attention per screen, so that the screen does not feel repetitive.
4. As a user, I want the app's name for this flow to stay visible in the navigation bar, so that I always know which part of the app I am in.
5. As a user, I want a simple row of dashes showing how many steps exist and how far along I am, so that I can gauge my progress without reading labels.
6. As a user, I want the progress dashes to fill in as I advance, so that I get confirmation that my tap did something.
7. As a user relying on VoiceOver, I want my step position announced, so that I am not disadvantaged by the step captions being removed from the visible design.
8. As a user, I want each field's label to sit inside its box above the value I typed, so that I can still see what a field is for after I have filled it in.
9. As a user, I want an empty field to show a plain prompt rather than a label and a prompt at once, so that empty fields look calm rather than cluttered.
10. As a user, I want the label to animate into place when I focus a field, so that the interface feels responsive to my attention.
11. As a user, I want input rules such as the valid age range and the minimum description length to remain visible while I type, so that I can satisfy them without guessing.
12. As a user, I want validation errors to replace the helper text in the same position, so that the layout does not jump when I make a mistake.
13. As a user, I want an invalid field's border to turn red, so that I can find the problem field at a glance.
14. As a user, I want fields to be visually quiet and uniform, so that the form reads as a single list rather than a collection of decorated rows.
15. As a user, I want the breed selector to look exactly like the other fields, so that the form feels coherent.
16. As a user, I want the breed selector to keep a chevron, so that I can tell it opens a picker rather than accepting typing.
17. As a user, I want one clear button at the bottom of every step, so that I never have to work out which of two buttons moves me forward.
18. As a user, I want that button in the same position on every step including the review step, so that I build muscle memory through the flow.
19. As a user, I want the primary button to always be tappable, so that tapping it tells me what is wrong instead of leaving me stuck with a greyed-out control and no explanation.
20. As a user, I want to go back via the navigation bar, so that the bottom of the screen is reserved for moving forward.
21. As a user, I want the back control to appear only when there is somewhere to go back to, so that I am not offered a dead action on the first step.
22. As a user, I want a short directional animation when I move between steps, so that I can feel whether I went forward or backward.
23. As a user, I want the keyboard to dismiss cleanly before a step transition, so that the animation does not stutter.
24. As a user, I want the photo well to match the visual language of the fields, so that it feels like part of the same form.
25. As a user, I want a photo of my cat shown at a generous size, so that the most personal part of registering a cat feels worth doing.
26. As a user, I want the option to remove a chosen photo presented in a neutral colour, so that I do not mistake a reversible choice for a dangerous one.
27. As a user, I want the review step to present my entries in the same visual language as the form, so that the flow does not appear to change design halfway through.
28. As a user, I want a clear confirmation screen after saving, so that I know the registration succeeded.
29. As a user, I want the confirmation to be centred and distinct from the form steps, so that I recognise I have finished rather than landed on another page.
30. As a user, I want the progress dashes to disappear once I have finished, so that a completed flow does not still look in progress.
31. As a user, I want the success screen's two actions clearly ranked, so that I can tell which one is the main path.
32. As a user, I do not want to be asked for my cat's coat colour, so that registration stops collecting a field the product has decided not to keep.
33. As a user, I do not want to be asked for my cat's gender, so that registration stays as short as the product actually needs.
34. As a user viewing one of my Registered Cats, I do not want to see a blank Color row or a Gender reading "Unknown", so that the detail screen never displays fields the app stopped collecting.
35. As a user with cats already saved on my device, I want the app to keep launching normally after this change, so that removing fields never costs me my data.
36. As a user, I want the rest of the app — the Breed List, Breed detail, the My Cats list, and every empty and error state — to look exactly as it did before, so that this change reads as a deliberate improvement to one flow rather than a partial redesign.
37. As a user in dark mode, I want the reskinned flow to remain legible, so that the new design is not a light-mode-only feature.
38. As a user, I want none of the flow's existing wording changed, so that nothing I previously understood has to be relearned.

## Implementation Decisions

### Design token layer

- The shared theme is extended, not restructured. No existing colour value changes.
- Two tokens are added: a pill corner radius for the new button shape, and a standard animation token for the step transition. The only animation in the codebase today is hard-coded inside the button component; the transition work must not add a second magic number.
- Two tokens that currently exist with no consumers — the background colour and the large title font — are put to use by this change.
- The primary theme colour takes the role that the reference design gives to black: it fills the call to action and the completed progress dashes. Every element the reference design renders as neutral grey stays neutral. Decorative uses of the primary colour are removed from the flow.

### Shared component changes and blast radius

Two of the four components being changed are used outside this flow, so their new behaviour must be opt-in with the current behaviour as the default. This was verified against actual call sites before specifying:

- The **text field component** is used only within this flow. It can change freely.
- The **stepper indicator component** is used only by this flow's container view. It can be rewritten in place.
- The **button component** is also used by the shared empty-state component. The pill shape must therefore be a new opt-in option, defaulting to the existing corner radius.
- The **section header component** is also used by the Breed detail screen and the Registered Cat detail screen, twice each. The prominent style must therefore be a new opt-in case, with the existing icon-plus-headline treatment remaining the default.

The intended outcome is a zero-line diff at all four out-of-scope call sites.

### Text field component

- Gains a focus binding to support a true floating label: when the field is empty and unfocused it shows only its placeholder at body size; when focused or non-empty, the label shrinks and moves to the top inset with the value beneath it.
- Gains a helper-text input rendered in caption weight and secondary colour beneath the box, replaced by the error row when an error is present.
- Loses its leading icon input, and with it the behaviour of recolouring that icon on error. The red border and the error row remain as the two error signals.
- Changes its fill from the surface colour to the background colour, retaining the hairline border and small corner radius.
- Sizes to its content via padding rather than a fixed height, so that longer strings or future accessibility work degrade by growing rather than clipping.
- The chrome shared by the text field and the breed selector — border, floating label, helper and error rows — is extracted into a common container. The breed selector currently duplicates all of it verbatim; this is the single most valuable deduplication in the change.

### Stepper indicator component

- Rewritten in place, keeping its name and call site. Its step-titles input is removed.
- Renders three small centred capsules with fixed spacing. Filled in the primary colour for the current and completed steps, and in the border colour for pending steps.
- Non-interactive. No numbers, captions, connectors, or trailing divider.
- Carries an accessibility label announcing the step position. This is required rather than optional: the visible step captions are being removed, so without it the step position is lost entirely to assistive technology.
- Hidden once the flow reaches its saved state.

### Screens

- The container view receives a tab-selection binding from the root tab view, used by the success screen's confirm action to switch to My Cats. The reskin must preserve this when relocating the success-screen actions into the pinned bar.
- The container view hides the navigation bar background so the inline title floats over the page, and adds a leading navigation-bar item combining a chevron and the existing "Back" wording, shown only when a previous step exists and calling the existing backward-navigation method.
- A single pinned bottom bar holds one full-width pill button on every step. The review step's save action moves out of its scroll view and into this bar. The bar sits on the plain background with no divider or material, and the scrolling content gains a bottom inset so the final field can clear it.
- Step transitions are animated by wrapping the existing advance and back calls at the call site and applying an asymmetric slide-and-fade transition to the step content. Focus is dismissed before advancing so that keyboard dismissal does not overlap the transition. **No ViewModel changes are required for this.**
- All three step headers adopt the prominent header style.
- The review rows move from the surface fill to the same white-with-border treatment as the fields, so that the review step matches the two steps preceding it.
- The success view stays centred, keeps its 80pt confirmation glyph in the semantic success colour, promotes its primary action to a pill in the bottom bar, and demotes its secondary action from an outlined button to plain text.

### Colour discipline

Green survives on the success screen but not on the progress dashes. This is deliberate and not an inconsistency: on the dashes, green was decorative redundancy alongside the red active state, whereas on the confirmation screen it is the semantic signal that the operation succeeded.

### Removing coat colour and gender

- Both are removed from the details step, from the review summary, and from the ViewModel's published state.
- **The persistence schema is deliberately left unchanged.** The stored properties and both enumerations remain, and the save path passes an empty string and the unknown case explicitly. Deleting non-optional stored properties from the local persistence model changes the schema and can cause the store to fail to open on a device that already holds Registered Cats. A launch crash is disqualifying under the challenge's evaluation criteria, so the schema cleanup is deferred to a versioned migration tracked separately.
- One enumeration becomes unreferenced as a result. This is an accepted and recorded deferral, not an oversight.
- **The Registered Cat detail screen displays both fields and must be amended.** Its information section renders a Gender row and a Color row. Left alone, every cat registered after this change would show "Gender: Unknown" and a blank Color. Both rows are therefore removed as part of this work. This is the one edit this spec makes outside the registration flow, and it is deliberate: retiring a field means retiring everywhere it surfaces, not just where it is collected.

### Step structure

The flow stays at three steps and the ViewModel's step, validation, and error-handling logic is untouched. The details step is left with two fields. Merging it into the first step was considered and rejected for now: it would require rewriting the per-step validators and reworking a substantial part of the existing test suite, which is behavioural work this change deliberately excludes. It is recorded as a follow-up to revisit once the sparser step can actually be seen.

### Typography and Dynamic Type

The theme's rounded title design is retained. Switching to a neutral face would more closely match the reference design, but the affected tokens are consumed by screens outside this flow, so the change would leak a global restyle into a scoped one. Similarly, converting the theme's fixed font sizes to scalable ones is out of scope; the fields are specified to size to content so that the eventual accessibility work is not blocked by hard-coded heights.

### Copy

No wording is reworded. The only copy change is positional: the parenthetical input constraints move out of two placeholders and into the new helper-text slot, because a floating label hides the placeholder at exactly the moment those constraints are needed.

### Documentation and domain language

- The original registration spec describes the coat colour and gender pickers in its user stories, data model notes, and step breakdown; these must be updated so the specs do not contradict the code.
- The project's domain glossary defines a Registered Cat as having "a name, age, gender, color, and photo". This definition is reworded as part of this change.
- ADR 0001 references gender in its rationale for separating Breeds from Registered Cats. The ADR's decision still stands and is not reopened; only the illustrative field list is now inaccurate, which is noted rather than rewritten.

## Testing Decisions

### What makes a good test here

Tests assert externally observable behaviour — that validation rejects an out-of-range age, that advancing is blocked while a step is invalid, that saving produces a persisted Registered Cat — never internal structure such as which view contains which subview. Visual output is explicitly *not* unit-tested; it is verified by inspection.

### Seams

**No new seams are introduced.** This change is presentation-layer work, and the correct seam already exists.

- The **AddCat ViewModel suite** is the single seam. It already covers step validation, step advancement, backward navigation, saving, and reset. It absorbs the only genuine behaviour change in this spec — the removal of the coat colour and gender published properties — via its save and reset assertions.
- The decisive point: **the step-navigation and validation tests must pass completely unmodified.** That is the regression proof that the reskin stayed in the presentation layer. If those tests need editing, the change has exceeded its own scope and should be re-examined.
- The **My Cats ViewModel suite** requires a mechanical fix only, because it constructs a Registered Cat directly. It is not a new seam and its assertions do not change.

### Prior art

Both suites use the project's existing swift-testing style: a named suite struct, a static decoded fixture built from an inline JSON literal, and a private factory that injects a stubbed service protocol. New and amended tests follow that pattern exactly.

### Visual verification

Performed by generating the project and building for the simulator target named in the project's build instructions, then capturing all four screens — three steps plus the success confirmation — in both light and dark appearance. The interaction pass confirms that the label floats on focus, that helper text persists while typing, and that an error replaces the helper text and reddens the border. A regression pass confirms the Breed detail screen, the Registered Cat detail screen, and the shared empty-state component are visually unchanged. Formatting is applied with the project's configured formatter, matching the existing formatting commits.

### Known verification risk

Making the fields white-on-white inverts to near-black-on-black in dark mode, separated only by a hairline border. This is the one place the reskin measurably reduces contrast. It must be looked at explicitly rather than assumed, and if field edges prove hard to read, retaining the surface fill in dark mode only is the accepted fallback.

## Out of Scope

The following are deliberately excluded and tracked separately:

1. ~~Both success-screen actions behave identically.~~ **Already resolved** ahead of this spec: the confirm action now switches to the My Cats tab before resetting. No longer a follow-up. Noted here because the reskin must preserve that behaviour when it moves the success-screen actions into the pinned bar.
2. **The breed picker's loading and error states offer no way out** — neither is wrapped in a navigation container and neither has a cancel action, so a hung breeds request traps the user in a modal. This is the highest-priority follow-up in this list; it is a stuck-state defect, not a cosmetic one.
3. **The versioned schema migration** that would actually drop the coat colour and gender stored properties and delete the now-unreferenced enumeration.
4. **Dynamic Type support** across the theme's font tokens, and accessibility labelling for the flow beyond the step indicator's position announcement.
5. **Collapsing the flow from three steps to two**, to be revisited once the two-field details step can be judged on screen.
6. **A snapshot or view-inspection test seam** for the reskinned components. Considered and declined to avoid a new dependency and snapshot churn against a design that is still settling.
7. **Any change to the Breed List, Breed detail, or My Cats list screens.** These are regression surfaces, not work surfaces. The Registered Cat detail screen is the sole exception, and only to remove its Gender and Color rows.
8. **A deliberate dark-mode design pass.** Dark mode is inherited from the existing tokens, verified, and fixed only where outright broken.
9. **The button component's enabled-state input being a custom parameter rather than the standard disabled environment**, meaning the standard modifier silently does nothing on it. Documented here as a latent trap; it does not affect this change, since the call to action is specified as always enabled.

## Further Notes

**The withdrawn Apple HIG refactor spec.** An earlier spec proposed rebuilding this flow on the framework's built-in form and section constructs, moving it into a modal sheet, and adopting stack-based navigation with swipe-back. It has been withdrawn — its ticket is closed and its document removed from this directory — for two reasons. First, the built-in form styling hands the visual layer to system grouped-list appearance, bypassing the shared text field, the surface and border tokens, and the corner-radius tokens; that is directly opposed to a token-driven reskin, and in tension with the challenge constraint to use and extend the existing components and theme rather than reinvent them. Second, swipe-based step navigation was explicitly ruled out for this flow. One observation from it survives as a live defect and is carried forward as item 2 of Out of Scope above.

**Why the schema is being left dirty on purpose.** Leaving two always-empty columns and an unreferenced enumeration in place is a real code smell, and it would be reasonable to object to it. It is accepted here because the alternative — a schema change without a migration plan — risks a launch failure, and the challenge's evaluation criteria treat a crash as disqualifying. The clean-up is item 3 of Out of Scope rather than an omission.

**What "match the look and feel" was taken to mean.** The reference design is monochrome, and the brief was also to keep the existing colour theme. These pull against each other. The resolution adopted throughout is that the reference design's character comes from its *restraint and hierarchy* — one saturated element per screen, everything else neutral — rather than from any specific hue. The theme's primary colour therefore takes over every role the reference gives to black, and decorative colour is stripped from the flow. The typeface is the one deliberate exception, kept as-is because it is the theme's most identity-bearing token and is shared with screens outside this flow.
