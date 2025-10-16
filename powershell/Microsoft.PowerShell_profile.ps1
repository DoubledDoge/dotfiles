# ========================================
# POWERSHELL PROFILE INITIALIZATION
# ========================================

$ProfileVersion = "1.0"
$PSMinimumVersion = 7

# ========================================
# MODULE MANAGEMENT & INITIALIZATION
# ========================================

Import-Module PSReadLine -ErrorAction SilentlyContinue

$RequiredModules = @(
    'PSFzf',           # FZF integration
    'ZLocation',       # Zoxide equivalent
    'posh-git',        # Git integration
    'CompletionPredictor'  # Enhanced completions
)

foreach ($Module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Host "Installing module: $Module" -ForegroundColor Yellow
        Install-Module -Name $Module -Repository PSGallery -Force -Scope CurrentUser
    }
    Import-Module $Module -ErrorAction SilentlyContinue
}

# ========================================
# HISTORY CONFIGURATION
# ========================================

# History file location
if ($IsWindows) {
    $HistoryFilePath = "$env:APPDATA\PowerShell\history.txt"
} else {
    $HistoryFilePath = "$env:HOME/.config/powershell/history.txt"
}

$env:PSHistoryPath = $HistoryFilePath

# PSReadLine history settings
$PSReadLineOptions = @{
    HistorySaveStyle              = 'SaveIncrementally'
    HistorySearchCursorMovesToEnd = $true
    MaximumHistoryCount           = 10000
    MaximumKillRingCount          = 50
}
Set-PSReadLineOption @PSReadLineOptions

# ========================================
# KEY BINDINGS
# ========================================

# Emacs-style key bindings
Set-PSReadLineOption -EditMode Emacs

# History search
Set-PSReadLineKeyHandler -Key 'UpArrow' -Function 'HistorySearchBackward'
Set-PSReadLineKeyHandler -Key 'DownArrow' -Function 'HistorySearchForward'
Set-PSReadLineKeyHandler -Key 'Ctrl+r' -Function 'ReverseSearchHistory'

# Smart word completion
Set-PSReadLineKeyHandler -Key 'Tab' -Function 'MenuComplete'
Set-PSReadLineKeyHandler -Key 'Ctrl+Spacebar' -Function 'TabCompleteNext'

# Directory navigation
Set-PSReadLineKeyHandler -Key 'Ctrl+d' -Function 'DeleteCharOrExit'

# ========================================
# COMPLETION SYSTEM
# ========================================

# Tab completion options
$PSReadLineOptions = @{
    CompletionQueryItems = 100
    ShowToolTips         = $true
    ExtraPromptLineCount = 0
}
Set-PSReadLineOption @PSReadLineOptions

# Syntax highlighting colors
Set-PSReadLineOption -Colors @{
    "Command"            = "#e0def4"
    "Parameter"          = "#908caa"
    "Operator"           = "#ebbcba"
    "Variable"           = "#31748f"
    "String"             = "#9ccfd8"
    "Number"             = "#f6c177"
    "Type"               = "#c4a7e7"
    "Comment"            = "#6e6a86"
    "Keyword"            = "#c4a7e7"
    "ContinuationPrompt" = "#31748f"
}

# ========================================
# ENVIRONMENT VARIABLES
# ========================================

# Editor configuration
$env:EDITOR = 'code'
$env:VISUAL = $env:EDITOR

# FZF Configuration
$env:FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git"

# FZF Options
$show_file_or_dir_preview = 'if (Test-Path -PathType Container $args) { eza --tree --color=always --level=2 $args | head -200 } else { bat -n --color=always --line-range :500 $args }'
$env:FZF_CTRL_T_OPTS = "--preview '$show_file_or_dir_preview' --height 60% --border --layout=reverse"
$env:FZF_ALT_C_OPTS = "--preview 'eza --tree --color=always --level=2 {0} | head -200' --height 60% --border --layout=reverse"
$env:FZF_DEFAULT_OPTS = "--height 60% --layout=reverse --border --inline-info --color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f"

# ========================================
# PATH CONFIGURATION
# ========================================

if ($IsWindows) {
    $PathItems = @(
        "$env:USERPROFILE\.cargo\bin",
        "$env:USERPROFILE\.spicetify",
        "$env:USERPROFILE\go\bin",
        "$env:USERPROFILE\.dotnet\bin",
        "$env:USERPROFILE\.local\bin"
    )
} else {
    $PathItems = @(
        "$env:HOME/.cargo/bin",
        "$env:HOME/.spicetify",
        "$env:HOME/go/bin",
        "$env:HOME/.dotnet/bin",
        "$env:HOME/.local/bin"
    )
}

foreach ($PathItem in $PathItems) {
    if ($PathItem -notin $env:PATH.Split([IO.Path]::PathSeparator)) {
        $env:PATH = "$PathItem$([IO.Path]::PathSeparator)$env:PATH"
    }
}

# ========================================
# ALIASES
# ========================================

function ls { eza --color=always --git --icons=always --group-directories-first @args }
function ll { eza -la --color=always --git --icons=always --group-directories-first @args }
function la { eza -la --color=always --git --icons=always --group-directories-first @args }
function lt { eza --tree --color=always --icons=always --group-directories-first @args }
function vim { nvim @args }
function vi { nvim @args }
function c { Clear-Host }
function cd { z @args }
function grep { batgrep @args }
function find { fd @args }
function cat { bat --paging=never @args }
function less { bat @args }
function rm { rip @args }
function del { rip @args }
function cp { fcp @args }
function tree { tre @args }
function man { batman @args }
function top { btop @args }
function df { duf @args }
function du { dust @args }

# FZF with preview
function fzf {
    & fzf --preview="bat --color=always --style=numbers --line-range=:500 {}" --height 60% --border --layout=reverse @args
}

# Git shortcuts
function gst { git status --short --branch @args }
function glog { git log --oneline --graph --decorate --all @args }
function gdiff { git diff --color-words @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git pull @args }

# Directory shortcuts
function .. { Set-Location '..' }
function ... { Set-Location '../..' }
function .... { Set-Location '../../..' }

# ========================================
# FUNCTIONS
# ========================================

# Quick directory creation and navigation
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

# Extract function for various archive formats
function extract {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        Write-Error "'$FilePath' is not a valid file"
        return
    }

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
}

# Tre with aliases
function tre {
    & command tre @args -e
    if ($IsWindows) {
        $TreAliasPath = "$env:TEMP\tre_aliases_$env:USERNAME"
    } else {
        $TreAliasPath = "/tmp/tre_aliases_$env:USERNAME"
    }
    if (Test-Path $TreAliasPath) {
        & $TreAliasPath
    }
}

# Enhanced which command
function which {
    param([string]$Command)
    Get-Command $Command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

# ========================================
# EXTERNAL INTEGRATIONS
# ========================================

# PSFzf integration
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# Zoxide integration
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# thefuck integration
if (Get-Command thefuck -ErrorAction SilentlyContinue) {
    Invoke-Expression "$(thefuck --alias)"
    Invoke-Expression "$(thefuck --alias fk)"
}

# posh-git integration for Git status
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git -ErrorAction SilentlyContinue
}

# ========================================
# PROMPT INITIALIZATION
# ========================================

# Oh-My-Posh initialization
if ($IsWindows) {
    $OhMyPoshConfig = "$env:APPDATA\ohmyposh\zen.toml"
} else {
    $OhMyPoshConfig = "$env:HOME/.config/ohmyposh/zen.toml"
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $OhMyPoshConfig) {
        & oh-my-posh init powershell --config $OhMyPoshConfig | Out-String | Invoke-Expression
    } else {
        Write-Warning "Oh-My-Posh config not found at: $OhMyPoshConfig"
        & oh-my-posh init powershell | Out-String | Invoke-Expression
    }
}
