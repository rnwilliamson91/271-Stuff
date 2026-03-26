#!/usr/bin/env bash
set -euo pipefail

ROOT="VidyaGames"

mkdir -p "$ROOT"/SOP/Common
mkdir -p "$ROOT"/SOP/Survival
mkdir -p "$ROOT"/SOP/FirstPerson
mkdir -p "$ROOT"/SOP/BattleRoyale
mkdir -p "$ROOT"/azure
mkdir -p "$ROOT"/docs

cat > "$ROOT/README.md" << 'MD'
# VidyaGames UE 5.7.x SOP Hub

This repository is a full Standard Operating Procedure (SOP) system for Unreal Engine 5.7.x projects.

## Start Here
1. `SOP/Common/00-README.md`
2. `SOP/Common/01-UE57-Project-Structure.md`
3. Choose a track:
   - `SOP/Survival/00-Overview.md`
   - `SOP/FirstPerson/00-Overview.md`
   - `SOP/BattleRoyale/00-Overview.md`

## Purpose
- Give classmates one place to find exact project setup and function ownership.
- Keep guidance practical, role-based, and searchable.
- Separate source control (Git) from heavy binary storage (Azure Blob).

## Scope
- Unreal Engine 5.7.x
- C++ + Blueprint hybrid workflows
- Team pipelines for design/programming/art/audio/production
MD

cat > "$ROOT/.gitignore" << 'TXT'
# Unreal Engine
Binaries/
DerivedDataCache/
Intermediate/
Saved/
.vs/
*.VC.db

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Python/Node misc if used for tooling
__pycache__/
node_modules/

# External heavy source assets (upload to Azure)
ExternalAssets/
TXT

cat > "$ROOT/.gitattributes" << 'TXT'
# Normalize text
* text=auto

# Optional LFS examples (uncomment if needed)
# *.uasset filter=lfs diff=lfs merge=lfs -text
# *.umap   filter=lfs diff=lfs merge=lfs -text
# *.wav    filter=lfs diff=lfs merge=lfs -text
# *.fbx    filter=lfs diff=lfs merge=lfs -text
TXT

cat > "$ROOT/.env.example" << 'TXT'
# Azure Blob config
AZURE_STORAGE_ACCOUNT=your_storage_account
AZURE_STORAGE_CONTAINER=external-assets
# Optional: if using SAS auth directly
# AZURE_STORAGE_SAS=?sv=...
TXT

cat > "$ROOT/docs/Git-Azure-Workflow.md" << 'MD'
# Git + Azure Large File Workflow

## Goal
Keep repository fast and clean while preserving access to heavy assets.

## Rule
- Put code/config/docs in Git.
- Put very large source assets in Azure Blob (`ExternalAssets/` local source).

## Steps
1. Place large files in local `ExternalAssets/`.
2. Run `azure/generate_manifest.ps1`.
3. Run `azure/upload_external_assets.ps1`.
4. Commit manifest + normal project files to Git.

## Notes
- Avoid committing Unreal transient folders.
- Use LFS only for medium-large assets you still want in Git.
MD

cat > "$ROOT/azure/generate_manifest.ps1" << 'PS1'
param(
    [string]$Root = ".",
    [string]$ExternalPath = "ExternalAssets",
    [string]$OutFile = "external-assets-manifest.json"
)

$base = Join-Path $Root $ExternalPath
if (!(Test-Path $base)) {
    Write-Host "No ExternalAssets folder found at $base"
    exit 0
}

$files = Get-ChildItem -Path $base -Recurse -File
$entries = @()

foreach ($f in $files) {
    $hash = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash
    $rel = $f.FullName.Substring((Resolve-Path $base).Path.Length).TrimStart('\')
    $entries += [pscustomobject]@{
        relativePath = $rel
        sizeBytes = $f.Length
        sha256 = $hash
    }
}

$manifest = [pscustomobject]@{
    generatedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    externalRoot = $ExternalPath
    files = $entries
}

$manifest | ConvertTo-Json -Depth 8 | Set-Content -Path (Join-Path $Root $OutFile) -Encoding UTF8
Write-Host "Manifest written to $(Join-Path $Root $OutFile)"
PS1

cat > "$ROOT/azure/upload_external_assets.ps1" << 'PS1'
param(
    [string]$Root = ".",
    [string]$ExternalPath = "ExternalAssets",
    [string]$StorageAccount = $env:AZURE_STORAGE_ACCOUNT,
    [string]$Container = $env:AZURE_STORAGE_CONTAINER
)

if (-not $StorageAccount -or -not $Container) {
    Write-Error "Set AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_CONTAINER"
    exit 1
}

$src = Join-Path $Root $ExternalPath
if (!(Test-Path $src)) {
    Write-Host "No ExternalAssets folder found at $src"
    exit 0
}

az storage blob upload-batch `
  --account-name $StorageAccount `
  --destination $Container `
  --source $src `
  --overwrite true

Write-Host "Upload complete."
PS1

cat > "$ROOT/azure/download_external_assets.ps1" << 'PS1'
param(
    [string]$Root = ".",
    [string]$ExternalPath = "ExternalAssets",
    [string]$StorageAccount = $env:AZURE_STORAGE_ACCOUNT,
    [string]$Container = $env:AZURE_STORAGE_CONTAINER
)

if (-not $StorageAccount -or -not $Container) {
    Write-Error "Set AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_CONTAINER"
    exit 1
}

$dest = Join-Path $Root $ExternalPath
New-Item -ItemType Directory -Force -Path $dest | Out-Null

az storage blob download-batch `
  --account-name $StorageAccount `
  --destination $dest `
  --source $Container

Write-Host "Download complete."
PS1

cat > "$ROOT/SOP/Common/00-README.md" << 'MD'
# Common SOP (UE 5.7.x)

## Use This First
- `01-UE57-Project-Structure.md`
- `02-Engineering-Standards.md`
- `03-Blueprint-Standards.md`
- `04-Build-Release-QA.md`
- `99-UE57-Official-Source-Index.md`

## Team Operating Principle
Every feature has:
1. Owner
2. Definition of done
3. Test checklist
4. Documentation link
MD

cat > "$ROOT/SOP/Common/01-UE57-Project-Structure.md" << 'MD'
# UE 5.7 Project Structure

## Root Layout
- `Config/` project settings
- `Content/` game assets
- `Source/` C++ modules
- `Plugins/` optional modular systems
- `SOP/` team process docs
- `ExternalAssets/` local heavy assets (Azure sync target, not git)

## Suggested Content Layout
- `Content/_Project/Core`
- `Content/_Project/Characters`
- `Content/_Project/Weapons`
- `Content/_Project/UI`
- `Content/_Project/Maps`
- `Content/_Project/Data`
- `Content/_Project/VFX`
- `Content/_Project/SFX`

## Suggested Source Layout
- `Source/<Project>/Core`
- `Source/<Project>/Characters`
- `Source/<Project>/Combat`
- `Source/<Project>/Inventory`
- `Source/<Project>/UI`
- `Source/<Project>/Networking`
- `Source/<Project>/Save`
MD

cat > "$ROOT/SOP/Common/02-Engineering-Standards.md" << 'MD'
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
MD

cat > "$ROOT/SOP/Common/03-Blueprint-Standards.md" << 'MD'
# Blueprint Standards

## Blueprint vs C++
Use C++ for:
- Core systems
- Replication-sensitive paths
- Shared framework logic

Use Blueprint for:
- Gameplay tuning
- UI behavior
- Event glue logic
- Rapid iteration

## Rules
- No mega-graphs.
- Use function libraries for repeated node chains.
- Keep exposed variables categorized and documented.
- Prefer interfaces over hard casting where possible.
MD

cat > "$ROOT/SOP/Common/04-Build-Release-QA.md" << 'MD'
# Build, Release, QA SOP

## Build Profiles
- Development: daily integration
- Test/Staging: QA verification
- Shipping: release candidates only

## Minimum Gate
1. No blocking compile warnings in core modules
2. Smoke test on target platform
3. Save/load validation
4. Multiplayer session join/leave validation (if applicable)
5. Performance sanity pass on representative map

## Packaging Checklist
- Correct map list
- Correct game mode defaults
- Correct plugin enablement
- Version/changelog updated
MD

cat > "$ROOT/SOP/Common/99-UE57-Official-Source-Index.md" << 'MD'
# UE 5.7 Official Source Index

Use official Epic documentation and Epic Developer Community pages as primary references.

## Core Docs (search anchors)
- Unreal Engine Documentation (latest)
- Gameplay Framework
- Networking and Replication
- Enhanced Input
- Animation Blueprint
- UMG/UI
- Asset Management
- Cooking and Packaging
- Performance Profiling
- Build Configurations
- Unreal Insights
- Dedicated Server setup
- Online Subsystem and sessions

## Versioning
Tag each SOP section with:
- `Validated for UE 5.7.x`
- `Last reviewed: YYYY-MM-DD`
MD

cat > "$ROOT/SOP/Survival/00-Overview.md" << 'MD'
# Survival SOP Overview

## Loop
Explore -> Gather -> Craft -> Survive threats -> Upgrade base/loadout -> Repeat.

## Pillars
- Resource scarcity
- Risk/reward exploration
- Progression persistence
- Environmental pressure (hunger, thirst, weather, night cycle)
MD

cat > "$ROOT/SOP/Survival/01-Game-Architecture.md" << 'MD'
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
MD

cat > "$ROOT/SOP/Survival/02-Systems-and-Functions.md" << 'MD'
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
MD

cat > "$ROOT/SOP/Survival/03-Content-Pipeline.md" << 'MD'
# Survival Content Pipeline

## Data Assets
- Item definitions
- Recipe definitions
- Biome/weather profiles
- Loot tables

## Naming
- `DA_Item_*`
- `DA_Recipe_*`
- `DT_Loot_*`
- `BP_Interactable_*`
MD

cat > "$ROOT/SOP/Survival/04-Live-Tuning-and-Balance.md" << 'MD'
# Survival Balance SOP

## Tune First
- Harvest yield
- Hunger/thirst drain rates
- Crafting costs
- Hostile spawn pressure

## Cadence
- Weekly balance pass
- Collect session metrics
- Adjust data assets, avoid hardcoding balance in logic
MD

cat > "$ROOT/SOP/Survival/05-Test-Plan.md" << 'MD'
# Survival Test Plan

## Must Pass
1. New game starts with valid baseline stats
2. Harvest/craft loops function under multiplayer authority
3. Save/load restores inventory and world node depletion
4. Death/respawn rules preserve intended progression penalties
MD

cat > "$ROOT/SOP/FirstPerson/00-Overview.md" << 'MD'
# First-Person SOP Overview

## Loop
Navigate -> Engage -> Resolve combat spaces -> Progress objectives.

## Pillars
- Weapon feel
- Readable encounter spaces
- Reliable hit registration
- Strong feedback (audio/VFX/UI)
MD

cat > "$ROOT/SOP/FirstPerson/01-Game-Architecture.md" << 'MD'
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
MD

cat > "$ROOT/SOP/FirstPerson/02-Systems-and-Functions.md" << 'MD'
# First-Person Systems and Function Types

## Core Functions
- `TryFireWeapon`
- `ComputeSpread`
- `ApplyRecoil`
- `PerformHitScan`
- `ApplyDamageModel`
- `TryReload`
- `SetAimState`
MD

cat > "$ROOT/SOP/FirstPerson/03-Content-Pipeline.md" << 'MD'
# First-Person Content Pipeline

## Authoring Packs
- Weapon data assets
- Animation sets
- Sound cues
- Impact VFX decals
- Encounter scripts

## Naming
- `DA_Weapon_*`
- `ABP_FP_*`
- `SFX_Weapon_*`
- `VFX_Impact_*`
MD

cat > "$ROOT/SOP/FirstPerson/04-Combat-Feel-Tuning.md" << 'MD'
# Combat Feel Tuning SOP

## Tune Dimensions
- Time to kill bands
- Recoil readability
- ADS transition speed
- Audio impact layering
- Hit marker/feedback clarity

## Method
- Isolate one variable per test
- Record before/after clips
- Keep balance values in data assets
MD

cat > "$ROOT/SOP/FirstPerson/05-Test-Plan.md" << 'MD'
# First-Person Test Plan

## Must Pass
1. Weapon fire/reload cannot desync state
2. ADS transitions are interruption-safe
3. Hit registration matches collision profile expectations
4. Objective progression cannot soft-lock
MD

cat > "$ROOT/SOP/BattleRoyale/00-Overview.md" << 'MD'
# Battle Royale SOP Overview

## Loop
Queue -> Drop -> Loot -> Rotate -> Survive shrinking zone -> Final circle.

## Pillars
- Fair session start
- High-clarity pacing via zone pressure
- Reliable matchmaking/session flow
- Anti-cheat and exploit resistance
MD

cat > "$ROOT/SOP/BattleRoyale/01-Game-Architecture.md" << 'MD'
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
MD

cat > "$ROOT/SOP/BattleRoyale/02-Systems-and-Functions.md" << 'MD'
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
MD

cat > "$ROOT/SOP/BattleRoyale/03-Content-Pipeline.md" << 'MD'
# Battle Royale Content Pipeline

## Data
- Loot tier tables
- Circle timing profiles
- Drop route sets
- Spawn density maps

## Naming
- `DT_LootTier_*`
- `DA_CircleProfile_*`
- `DA_DropPath_*`
- `BP_LootSpawner_*`
MD

cat > "$ROOT/SOP/BattleRoyale/04-Matchmaking-Session-Flow.md" << 'MD'
# Matchmaking and Session Flow SOP

## Flow
1. Queue request
2. Session allocation
3. Pre-match lobby
4. Match start handshake
5. Post-match summary + return to queue

## Reliability
- Timeout fallback paths
- Reconnect handling
- Session health checks
- Region/ping guardrails
MD

cat > "$ROOT/SOP/BattleRoyale/05-Test-Plan.md" << 'MD'
# Battle Royale Test Plan

## Must Pass
1. 100-player (or target cap) join stability test
2. Circle timing and damage are deterministic server-authoritative
3. Elimination -> spectate -> post-match flow has no dead ends
4. Match end always resolves and returns all clients safely
MD

echo
echo "Created files under: $ROOT"
find "$ROOT" -maxdepth 4 -type f | sort
