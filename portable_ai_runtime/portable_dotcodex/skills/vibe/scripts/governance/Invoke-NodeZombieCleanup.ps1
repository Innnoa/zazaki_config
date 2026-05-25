param(
    [switch]$PassThru,
    [string]$OutputDirectory = '',
    [string]$RepoRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot '..\..\outputs\runtime\process-health'
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

$payload = [pscustomobject]@{
    apply_requested = $false
    cleanup_candidate_count = 0
    repo_root = $RepoRoot
    results = @()
}

$artifactPath = Join-Path $OutputDirectory 'node-zombie-cleanup.json'
$payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $artifactPath -Encoding UTF8

$result = [pscustomobject]@{
    artifact_path = $artifactPath
    payload = $payload
}

if ($PassThru) {
    return $result
}

$result | ConvertTo-Json -Depth 6
