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
