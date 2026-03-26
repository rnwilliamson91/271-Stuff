# Survival Game Architecture

## Systems
- Needs: hunger/thirst/stamina/temp
- Inventory + weight/encumbrance
- Crafting + recipes
- World harvesting nodes
- AI predators/hostiles
- Day/night + weather
- Save/restore world state

## Class Placement
- `ASurvivalGameMode`: survival rule authority
- `ASurvivalGameState`: time/weather/global events
- `ASurvivalPlayerState`: progression/XP/faction
- `ASurvivalCharacter`: movement + interaction actions
- `USurvivalNeedsComponent`: needs ticking
- `UInventoryComponent`: authoritative inventory operations
