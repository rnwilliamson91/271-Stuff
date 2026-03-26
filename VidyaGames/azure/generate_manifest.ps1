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
