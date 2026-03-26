# Engineering Standards (UE 5.7.x)

## Ownership Map
- `GameInstance`: global runtime services
- `GameMode`: server-authoritative match rules
- `GameState`: replicated match state
- `PlayerState`: replicated player summary state
- `PlayerController`: input routing and UI orchestration
- `Pawn/Character`: movement and ability execution
- `Subsystems`: reusable service-style logic

## Function Guidelines
- Keep network authority checks explicit (`HasAuthority()` where needed).
- Use data-driven config via `DataAssets` / `DataTables`.
- Prefer composition over monolithic character classes.
- Keep one class responsible for one system boundary.
