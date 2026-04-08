[CmdletBinding()]
param(
    [string]$RepoPath = "",
    [string]$PreferredDistro = "Ubuntu",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Write-Info([string]$Message) {
    Write-Host "[INFO] $Message"
}

function Write-Ok([string]$Message) {
    Write-Host "[OK] $Message"
}

function Write-Warn([string]$Message) {
    Write-Host "[WARN] $Message"
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Get-WslDistroNames {
    try {
        $output = & wsl.exe -l -q 2>$null
        if (-not $output) {
            return @()
        }
        return @($output | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    } catch {
        return @()
    }
}

function Convert-WindowsPathToWsl([string]$Path) {
    if (-not $Path) {
        return $null
    }

    if ($Path -match '^(?<drive>[A-Za-z]):\\(?<rest>.*)$') {
        $drive = $Matches.drive.ToLower()
        $rest = $Matches.rest -replace '\\', '/'
        if ($rest) {
            return "/mnt/$drive/$rest"
        }
        return "/mnt/$drive"
    }

    return $null
}

function Invoke-WslInstall([string]$DistroName) {
    $argList = @("--install", "-d", $DistroName)
    if ($DryRun) {
        Write-Host "[DRY-RUN] wsl.exe $($argList -join ' ')"
        return
    }

    if (Test-IsAdministrator) {
        & wsl.exe @argList
        return
    }

    $commandLine = "wsl.exe $($argList -join ' ')"
    Start-Process -FilePath "powershell.exe" `
        -Verb RunAs `
        -Wait `
        -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $commandLine)
}

Write-Info "Checking WSL status..."
$distros = @(Get-WslDistroNames)
if ($distros.Count -gt 0) {
    Write-Ok ("Detected existing WSL distro(s): " + ($distros -join ", "))
} else {
    Write-Info "No WSL distro detected. Attempting to install WSL with $PreferredDistro."
    Invoke-WslInstall -DistroName $PreferredDistro
    $distros = @(Get-WslDistroNames)
    if ($distros.Count -gt 0) {
        Write-Ok ("WSL distro(s) now visible: " + ($distros -join ", "))
    } else {
        Write-Warn "WSL installation may still require a reboot or first-launch initialization."
    }
}

$targetDistro = if ($distros -contains $PreferredDistro) {
    $PreferredDistro
} elseif ($distros.Count -gt 0) {
    $distros[0]
} else {
    $PreferredDistro
}

$wslRepoPath = Convert-WindowsPathToWsl -Path $RepoPath

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. If Windows asks for a reboot, restart first."
Write-Host "  2. Launch your Linux distro once so user setup can finish:"
Write-Host "       wsl.exe -d $targetDistro"

if ($wslRepoPath) {
    Write-Host "  3. After the Linux shell opens, rerun zot inside WSL:"
    Write-Host "       cd '$wslRepoPath'"
    Write-Host "       ./setup.sh"
} else {
    Write-Host "  3. After the Linux shell opens, clone or copy this repo into WSL and run:"
    Write-Host "       git clone <your-repo-url> zot"
    Write-Host "       cd zot"
    Write-Host "       ./setup.sh"
}

Write-Host "  4. zot will install CLI tools inside WSL and keep GUI apps on the Windows side."
