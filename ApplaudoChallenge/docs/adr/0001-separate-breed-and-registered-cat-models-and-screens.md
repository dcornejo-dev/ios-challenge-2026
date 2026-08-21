# Breeds and Registered Cats are separate entities with separate screens

API-sourced Breeds and user-created Registered Cats are modeled as distinct domain concepts with their own list screens ("Cats" tab and "My Cats" tab). We considered unifying them into a single entity and a single list, but rejected it because they represent fundamentally different things: a Breed is a category (encyclopedia entry with description, origin, temperament), while a Registered Cat is an instance of a category (an individual animal with a name, age, gender, photo). Forcing them into one model would require either stripping fields from one side or adding meaningless fields to the other, and mixing them in one list would blur the distinction for the user.

## Considered Options

- **Unified entity + single list**: one model and one combined list with visual indicators to distinguish source. Rejected — the data shapes share almost no overlap, and a shared abstraction would be leaky.
- **Separate entities + single list with sections**: two models but shown in sections of the same screen. Rejected — couples two data sources (network + local) into one ViewModel and makes the "Cats" tab name ambiguous.
- **Separate entities + separate tabs** (chosen): each concept gets its own model, list screen, and detail screen. Clean separation, each tab is single-purpose, and the reviewer can independently evaluate API integration and local persistence.
