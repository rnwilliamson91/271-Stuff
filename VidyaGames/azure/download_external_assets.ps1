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
