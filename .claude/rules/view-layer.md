# View Conventions

## Type Structure
- Concrete type: `struct` conforming to `View`

## File Structure (top to bottom)
Properties are declared without MARK sections, in this order:

1. **Properties**
   - `@Environment` properties
   - `@StateObject` for the view model
   - `@Binding` properties
   - `let` constants and closures
   - Computed properties
2. **Custom `init`** (only when needed, e.g. to initialize `@StateObject` or `@Binding`)
3. **`var body: some View`** — the view hierarchy
