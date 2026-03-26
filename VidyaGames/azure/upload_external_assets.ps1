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
