param(
    [switch]$PassThru,
    [switch]$WriteMarkdown,
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
    summary = [pscustomobject]@{
        status = 'placeholder'
        running_node_processes = 0
        repo_root = $RepoRoot
    }
}

$artifactPath = Join-Path $OutputDirectory 'node-process-audit.json'
$payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $artifactPath -Encoding UTF8

$markdownPath = $null
if ($WriteMarkdown) {
    $markdownPath = Join-Path $OutputDirectory 'node-process-audit.md'
    @(
        '# Node Process Audit',
        '',
        '- status: placeholder',
        '- running_node_processes: 0',
        "- repo_root: $RepoRoot"
    ) | Set-Content -LiteralPath $markdownPath -Encoding UTF8
}

$result = [pscustomobject]@{
    artifact_path = $artifactPath
    markdown_path = $markdownPath
    payload = $payload
}

if ($PassThru) {
    return $result
}

$result | ConvertTo-Json -Depth 6
