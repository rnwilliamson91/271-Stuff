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
