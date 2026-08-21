# Target Layer Conventions

## Type Structure
- Concrete type: `enum`

## File Structure (top to bottom)
1. **Enum** (`{Entity}Target`) — declares all API cases with their associated values
2. **Extension** (`{Entity}Target: TargetType`) — computed properties in this order:
   - `var path: String` — endpoint path per case
   - `var method: Moya.Method` — HTTP method per case
   - `var task: Moya.Task` — request parameters/encoding per case
   - `var headers: [String : String]?` — request headers

When a computed property has a single value for all cases, return the value directly without a `switch` statement.
