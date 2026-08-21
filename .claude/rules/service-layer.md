# Service Layer Conventions

## Type Structure
- Protocol: `{Entity}ServiceType`
- Concrete type: `struct`

## File Structure (top to bottom)
1. **Protocol** (`{Entity}ServiceType`) — declares all public method signatures
2. **Struct** (`{Entity}Service: {Entity}ServiceType`) — organized with MARK sections in this order:
   - `// MARK: - Properties`
   - `// MARK: - Initializers`
   - `// MARK: - Public Methods` — implementations matching the protocol
