# ViewModel Conventions

## Type Structure
- Concrete type: `final class` conforming to `ObservableObject`

## File Structure (top to bottom)
Organized with MARK sections in this order:

1. `// MARK: - Properties`
   - `private let` dependencies
   - `private var` mutable state
   - Non-published instance properties (e.g. `var alert`, `let` subjects)
   - `@Published var` properties
2. `// MARK: - Computed Properties`
3. `// MARK: - Initializers` — setup calls at the end of init
4. `// MARK: - Public Methods`
5. `// MARK: - Private Methods`
