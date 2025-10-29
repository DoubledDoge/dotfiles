# ========================================
# POWERSHELL PROFILE INITIALIZATION
# ========================================

$ProfileVersion = "3.0"
$PSMinimumVersion = 7

# Suppress progress bars
$ProgressPreference = 'SilentlyContinue'

# Import PSReadLine
Import-Module PSReadLine -Force -ErrorAction Stop

# ========================================
# COMMAND CACHE
# ========================================

$script:CommandCache = @{}
function Test-CommandExists {
    param([string]$Command)
    if (-not $script:CommandCache.ContainsKey($Command)) {
        $script:CommandCache[$Command] = [bool](Get-Command $Command -ErrorAction SilentlyContinue)
    }
    return $script:CommandCache[$Command]
}

# ========================================
# PSREADLINE CONFIGURATION
# ========================================

# Core PSReadLine options
Set-PSReadLineOption -EditMode Windows `
                     -HistorySaveStyle SaveIncrementally `
                     -HistorySearchCursorMovesToEnd `
                     -MaximumHistoryCount 10000 `
                     -MaximumKillRingCount 50 `
                     -ShowToolTips `
                     -PredictionSource History `
                     -PredictionViewStyle ListView `
                     -BellStyle None

# History configuration
$HistoryFilePath = if ($IsWindows) {
    "$env:APPDATA\PowerShell\history.txt"
} else {
    "$env:HOME/.config/powershell/history.txt"
}

$HistoryDir = Split-Path $HistoryFilePath -Parent
if (-not (Test-Path $HistoryDir)) {
    New-Item -ItemType Directory -Force -Path $HistoryDir | Out-Null
}

$env:PSHistoryPath = $HistoryFilePath
Set-PSReadLineOption -HistorySavePath $HistoryFilePath

# ========================================
# KEY BINDINGS
# ========================================

# History search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

# Tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Shift+Tab -Function TabCompletePrevious
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function TabCompleteNext

# Navigation
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord

# ========================================
# MODULE MANAGEMENT 
# ========================================

function Import-ModuleAsync {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,
        [bool]$Required = $true
    )
    
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        if ($Required) {
            Write-Host "Module $ModuleName not found. Install with: Install-Module $ModuleName -Scope CurrentUser" -ForegroundColor Yellow
        }
        return
    }
    
    # Defer non-critical imports for faster startup
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        Import-Module $using:ModuleName -ErrorAction SilentlyContinue
    } | Out-Null
}

# Critical modules
$CriticalModules = @('Terminal-Icons')

foreach ($Module in $CriticalModules) {
    if (Get-Module -ListAvailable -Name $Module) {
        Import-Module $Module -ErrorAction SilentlyContinue
    }
}

# Required modules (lazy loaded)
$RequiredModules = @(
    'PSFzf',
    'posh-git'
)

# Optional modules
$OptionalModules = @(
    'CompletionPredictor',
    'Microsoft.WinGet.CommandNotFound',
    'PSScriptAnalyzer'
)

foreach ($Module in $RequiredModules) {
    Import-ModuleAsync -ModuleName $Module -Required $true
}

foreach ($Module in $OptionalModules) {
    Import-ModuleAsync -ModuleName $Module -Required $false
}

# ========================================
# ENVIRONMENT VARIABLES
# ========================================

$env:EDITOR = 'code'
$env:VISUAL = $env:EDITOR
$env:FZF_DEFAULT_OPTS = "--height 60% --layout=reverse --border --inline-info --color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f,pointer:#ebbcba,marker:#ebbcba,prompt:#31748f"

# ========================================
# PATH CONFIGURATION
# ========================================

$PathItems = if ($IsWindows) {
    @(
        "$env:USERPROFILE\.cargo\bin",
        "$env:USERPROFILE\.spicetify",
        "$env:USERPROFILE\go\bin",
        "$env:USERPROFILE\.dotnet\bin",
        "$env:USERPROFILE\.local\bin"
    )
} else {
    @(
        "$env:HOME/.cargo/bin",
        "$env:HOME/.spicetify",
        "$env:HOME/go/bin",
        "$env:HOME/.dotnet/bin",
        "$env:HOME/.local/bin"
    )
}

# Deduplicate paths with proper case handling
$CurrentPath = [System.Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
$env:PATH.Split([IO.Path]::PathSeparator) | ForEach-Object { $CurrentPath.Add($_) | Out-Null }

foreach ($PathItem in $PathItems) {
    if ((Test-Path $PathItem) -and -not $CurrentPath.Contains($PathItem)) {
        $env:PATH = "$PathItem$([IO.Path]::PathSeparator)$env:PATH"
    }
}

# ========================================
# ALIASES & FUNCTIONS
# ========================================

function c { Clear-Host }

# Git shortcuts
function gst { git status --short --branch @args }
function glog { git log --oneline --graph --decorate --all @args }
function gdiff { git diff --color-words @args }
function ga { git add @args }
function gaa { git add --all @args }
function gc { git commit @args }
function gcm { 
    param([Parameter(Mandatory)][string]$Message)
    git commit -m $Message 
}
function gp { git push @args }
function gl { git pull @args }
function gco { git checkout @args }
function gb { git branch @args }
function gbd { git branch -d @args }
function gf { git fetch @args }
function gm { git merge @args }
function gr { git rebase @args }
function gsta { git stash @args }
function gstp { git stash pop @args }

# Directory shortcuts
function .. { Set-Location '..' }
function ... { Set-Location '../..' }
function .... { Set-Location '../../..' }

# Utility functions
function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    try {
        New-Item -ItemType Directory -Force -Path $Path -ErrorAction Stop | Out-Null
        Set-Location $Path
    } catch {
        Write-Error "Failed to create or navigate to directory: $_"
    }
}

function touch { 
    param([Parameter(Mandatory)][string]$Path)
    try {
        if (Test-Path $Path) {
            (Get-Item $Path).LastWriteTime = Get-Date
        } else {
            New-Item -ItemType File -Path $Path -ErrorAction Stop | Out-Null
        }
    } catch {
        Write-Error "Failed to touch file: $_"
    }
}

function extract {
    param([Parameter(Mandatory)][string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Error "'$FilePath' is not a valid file"
        return
    }
    
    try {
        switch -Regex ($FilePath) {
            '\.tar\.bz2$'  { tar xjf $FilePath }
            '\.tar\.gz$'   { tar xzf $FilePath }
            '\.tar\.xz$'   { tar xJf $FilePath }
            '\.bz2$'       { bzip2 -d $FilePath }
            '\.rar$'       { unrar x $FilePath }
            '\.gz$'        { gzip -d $FilePath }
            '\.tar$'       { tar xf $FilePath }
            '\.tbz2$'      { tar xjf $FilePath }
            '\.tgz$'       { tar xzf $FilePath }
            '\.zip$'       { Expand-Archive -Path $FilePath -DestinationPath . }
            '\.7z$'        { 7z x $FilePath }
            default        { Write-Error "'$FilePath' cannot be extracted via extract()" }
        }
    } catch {
        Write-Error "Failed to extract file: $_"
    }
}

function which {
    param([Parameter(Mandatory)][string]$Command)
    try {
        $cmd = Get-Command $Command -ErrorAction Stop
        $cmd | Select-Object -ExpandProperty Source
    } catch {
        Write-Error "Command '$Command' not found"
    }
}

function Get-DiskUsage {
    Get-ChildItem -Force | 
        ForEach-Object { 
            [PSCustomObject]@{
                Name = $_.Name
                Size = if ($_.PSIsContainer) {
                    (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | 
                     Measure-Object -Property Length -Sum).Sum
                } else { $_.Length }
            }
        } | 
        Sort-Object Size -Descending | 
        Select-Object Name, @{N='Size';E={"{0:N2} MB" -f ($_.Size / 1MB)}}
}

function reload { 
    . $PROFILE 
    Write-Host "Profile reloaded!" -ForegroundColor Green
}

function Update-Profile {
    param([string]$ProfileUrl = "https://raw.githubusercontent.com/DoubledDoge/dotfiles/main/powershell/Microsoft.PowerShell_profile.ps1")
    
    try {
        Write-Host "Downloading profile from $ProfileUrl..." -ForegroundColor Yellow
        $WebProfile = Invoke-RestMethod -Uri $ProfileUrl -ErrorAction Stop
        $WebProfile | Out-File -FilePath $PROFILE -Encoding UTF8 -Force
        Write-Host "Profile updated successfully! Run 'reload' to apply changes." -ForegroundColor Green
    } catch {
        Write-Error "Failed to update profile: $_"
    }
}

# ========================================
# EXTERNAL INTEGRATIONS
# ========================================

# PSFzf
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    if (Get-Module -Name PSFzf) {
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
} | Out-Null

# Zoxide integration
if (Test-CommandExists 'zoxide') {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Dotnet completion
if (Test-CommandExists 'dotnet') {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# ========================================
# PROMPT (OH-MY-POSH)
# ========================================

$OhMyPoshConfig = if ($IsWindows) {
    "$env:APPDATA\oh-my-posh\zen.toml"
} else {
    "$env:HOME/.config/ohmyposh/zen.toml"
}

if (Test-CommandExists 'oh-my-posh') {
    if (Test-Path $OhMyPoshConfig) {
        & oh-my-posh init powershell --config $OhMyPoshConfig | Invoke-Expression
    } else {
        & oh-my-posh init powershell | Invoke-Expression
    }
}
