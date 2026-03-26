# Survival Systems and Function Types

## Core Functions
- `TryHarvestNode`
- `TryCraftRecipe`
- `ApplyNeedDelta`
- `ConsumeItem`
- `ApplyStatusEffect`
- `SaveSurvivalSnapshot`
- `LoadSurvivalSnapshot`

## Networking
- Inventory writes server-only
- Need state replicated to owning client (and summary to others)
- Time/weather replicated from `GameState`
