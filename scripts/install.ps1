# 安装：钉住 dsh-thinking-slider 0.3.3，应用档位改名补丁。
#
#   pwsh -File scripts/install.ps1 -Profile desktop
#
# 参数：
#   -Profile  DSH profile 名，默认 desktop
#   -Dsh      dsh 可执行文件路径；省略时依次尝试 PATH、桌面版内置路径
param(
    [string]$Profile = 'desktop',
    [string]$Dsh = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$patch = Join-Path $repoRoot 'patches\liang-level-names.patch'

if (-not (Test-Path $patch)) { throw "找不到补丁文件：$patch" }

function Resolve-Dsh {
    param([string]$Explicit)
    if ($Explicit) { return $Explicit }
    $onPath = Get-Command dsh -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }
    $builtin = 'F:\For DSH\resources\runtime\cli\bin\dsh.cmd'
    if (Test-Path $builtin) { return $builtin }
    throw '找不到 dsh 命令。请用 -Dsh 指定路径，例如：-Dsh "C:\Program Files\DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd"'
}

$dshExe = Resolve-Dsh -Explicit $Dsh
Write-Host "dsh      : $dshExe"
Write-Host "profile  : $Profile"

Write-Host "`n[1/3] 安装 dsh-thinking-slider@0.3.3 ..."
& $dshExe plugin --profile $Profile add 'dsh-thinking-slider@0.3.3'
if ($LASTEXITCODE -ne 0) { throw "安装失败（exit $LASTEXITCODE）" }

$pkg = Join-Path $env:USERPROFILE ".dsh\profiles\$Profile\node_modules\dsh-thinking-slider"
$client = Join-Path $pkg 'lib\client.js'
if (-not (Test-Path $client)) { throw "装完了但找不到 $client —— 可能是 profile 路径不同，请手动确认" }

Write-Host "`n[2/3] 应用补丁 ..."
$already = Select-String -Path $client -Pattern 'LIANG_LEVEL_NAMES' -Quiet
if ($already) {
    Write-Host '已经改过了，跳过。'
} else {
    Push-Location $pkg
    try {
        git apply -p1 --whitespace=nowarn $patch
        if ($LASTEXITCODE -ne 0) { throw "补丁应用失败（exit $LASTEXITCODE）。插件版本可能不是 0.3.3，或文件已被改动。" }
    } finally { Pop-Location }
    Write-Host '补丁已应用。'
}

Write-Host "`n[3/3] 完成。"
Write-Host '现在从系统托盘完全退出 DSH，再重新打开 —— 客户端模块只在启动时扫描。'
