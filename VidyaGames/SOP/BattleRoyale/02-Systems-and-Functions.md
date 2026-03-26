# Battle Royale Systems and Function Types

## Core Functions
- `StartMatchPhase`
- `GenerateSafeZone`
- `AdvanceCirclePhase`
- `TrySpawnLootTier`
- `HandlePlayerEliminated`
- `EnterSpectateMode`
- `FinalizeMatchResults`

## Networking
- Circle logic server-only, replicate params and countdowns.
- Loot authority server-only.
- Kill feed and match events replicated via `GameState`.
