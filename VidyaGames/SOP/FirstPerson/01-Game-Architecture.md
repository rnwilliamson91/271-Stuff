# First-Person Architecture

## Systems
- Weapon framework
- Recoil/spread/bloom
- ADS and movement states
- Hit reaction and damage model
- Objective flow
- Checkpoints/save

## Class Placement
- `AFPSGameMode`: objective/win rules
- `AFPSPlayerController`: input/UI/state transitions
- `AFPSCharacter`: locomotion and camera behaviors
- `UWeaponComponent`: equip/fire/reload lifecycle
- `UHealthComponent`: health and damage intake
