param(
  [string]$Message = "",
  [switch]$NoBuild,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Print($text) { Write-Host $text }

function Run($exe, $argv, $cwd) {
  if ($DryRun) { Print "$cwd> $exe $($argv -join ' ')"; return }
  if ($cwd) { Push-Location $cwd }
  try { & $exe @argv }
  finally { if ($cwd) { Pop-Location } }
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMsg = $(if ([string]::IsNullOrWhiteSpace($Message)) { "chore: auto-commit $timestamp" } else { $Message })

Run git @('submodule','update','--init','--recursive') $root

$modulePaths = @()
$lines = git config --file .gitmodules --get-regexp 'submodule\..*\.path'
foreach ($line in $lines) {
  $parts = $line -split '\s+'
  if ($parts.Length -ge 2) { $modulePaths += $parts[1] }
}

foreach ($mod in $modulePaths) {
  $path = Join-Path $root $mod
  if (-not (Test-Path $path)) { continue }

  if (-not $NoBuild) {
    if (Test-Path (Join-Path $path 'package.json')) {
      if (Get-Command npm -ErrorAction SilentlyContinue) {
        try { Run npm @('ci','--prefix',$path) $root } catch { Run npm @('install','--prefix',$path) $root }
        Run npm @('run','build','--prefix',$path) $root
      }
    } elseif ((Test-Path (Join-Path $path 'pyproject.toml')) -or (Test-Path (Join-Path $path 'requirements.txt'))) {
      if (Get-Command python -ErrorAction SilentlyContinue) {
        if (Test-Path (Join-Path $path 'requirements.txt')) { Run python @('-m','pip','install','-r',(Join-Path $path 'requirements.txt')) $root }
      }
    }
  }

  $status = git -C $path status --porcelain
  if (-not [string]::IsNullOrWhiteSpace($status)) {
    Run git @('-C',$path,'add','-A') $root
    Run git @('-C',$path,'commit','-m',$commitMsg) $root
    Run git @('-C',$path,'pull','--rebase') $root
    Run git @('-C',$path,'push') $root
  }
}

$rootStatus = git status --porcelain
if (-not [string]::IsNullOrWhiteSpace($rootStatus)) {
  Run git @('add','-A') $root
  Run git @('commit','-m',$commitMsg) $root
  Run git @('pull','--rebase') $root
  Run git @('push') $root
}
