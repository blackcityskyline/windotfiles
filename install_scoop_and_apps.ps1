# Check if Scoop is installed, and install it if necessary
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Output "Scoop is not installed. Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    iwr -useb get.scoop.sh | iex
} else {
    Write-Output "Scoop is already installed."
}

# Update Scoop and its repositories
scoop update
scoop update *
scoop bucket add main
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts

# List of packages to install
$packages = @(
    "7zip",
    "autohotkey",
    "ayugram",
    "cascadia-code",
    "curl",
    "cpu-z",
    "delugia-mono-nerd-font-complete",
    "delugia-nerd-font-complete",
    "fastfetch",
    "flow-launcher",
    "fzf",
    "git",
    "glazewm",
    "gpu-z",
    "hack-nf",
    "nanazip",
    "nano",
    "neofetch",
    "neovim",
    "nilesoft-shell",
    "nodejs",
    "notepadplusplus",
    "ntop",
    "obs-studio",        
    "oh-my-posh",
    "quicklook",
    "qview",
    "scoop-completion",
    "sharex",
    "sudo",
    "ultravnc",
    "ungoogled-chromium",
    "vscode",
    "python39",
    "putty",
    "windirstat",
    "yasb",
    "youtube-music",
    "zebar"
)

# Install each package
foreach ($package in $packages) {
    Write-Output "Installing $package..."
    scoop install $package
}

Write-Output "All packages have been installed."влены."