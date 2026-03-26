# Battle Royale Architecture

## Systems
- Lobby + matchmaking handoff
- Drop phase
- Loot spawning
- Circle generation and shrink timeline
- Elimination/spectate/revive rules
- Endgame and rewards

## Class Placement
- `ABRGameMode`: match authority and phase state machine
- `ABRGameState`: replicated phase/circle/match clock
- `ABRPlayerState`: placement/kills/assists/revival data
- `ABRPlayerController`: map markers, spectate, HUD routing
- `UCircleSubsystem`: deterministic safe-zone generation
