# 回退：反向应用补丁，恢复官方的 Off / Low / High / Max。
#
#   pwsh -File scripts/revert.ps1 -Profile desktop
#
# 想彻底移除插件，用：
#   dsh plugin --profile desktop remove dsh-thinking-slider
param(
    [string]$Profile = 'desktop'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$patch = Join-Path $repoRoot 'patches\liang-level-names.patch'
$pkg = Join-Path $env:USERPROFILE ".dsh\profiles\$Profile\node_modules\dsh-thinking-slider"

if (-not (Test-Path $pkg)) {
    Write-Host "这个 profile 里没装 dsh-thinking-slider，无需回退。"
    exit 0
}

Push-Location $pkg
try {
    $touched = Select-String -Path 'lib\client.js' -Pattern 'LIANG_LEVEL_NAMES' -Quiet
    if (-not $touched) {
        Write-Host '补丁不在，已经是官方版本。'
        exit 0
    }
    git apply -R -p1 --whitespace=nowarn $patch
    if ($LASTEXITCODE -ne 0) { throw "反向应用失败（exit $LASTEXITCODE）。文件可能已被改动，建议直接重装插件。" }
    Write-Host '已回退。重启 DSH 后档位名恢复英文。'
} finally { Pop-Location }
