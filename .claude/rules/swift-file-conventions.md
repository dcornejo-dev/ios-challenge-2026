# Swift File Conventions

## Naming
- Type name: `{Entity}{LayerType}` (e.g. `UserService`, `SiteTarget`, `ScanViewModel`, `ScanView`)
- File name: matches the type name — `{Entity}{LayerType}.swift`

## General Ordering (top to bottom)
1. Properties / Dependencies
2. Initializers
3. Public interface (methods or `body`)
4. Private implementation

## Dependency Injection
- Dependencies are declared as `private let`
- Initializers provide default values for dependencies (e.g. `networkProvider: NetworkProvider = .init()`)

## Mutable State
- Internal mutable state is declared as `private var`

## MARK Sections
- Use `// MARK: - {Section}` to separate logical sections in Services and ViewModels
- Views skip MARK sections since their structure is simpler

## Layer-Specific Rules
See individual rule files for each layer's specific conventions:
- `service-layer.md`
- `target-layer.md`
- `viewmodel-layer.md`
- `view-layer.md`
