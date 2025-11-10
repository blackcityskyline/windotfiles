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
scoop bucket add java
scoop bucket add versions
scoop bucket add nerd-fonts
scoop bucket add nonportable
scoop bucket add anderlli0053_DEV-tools https://github.com/anderlli0053/DEV-tools
scoop bucket add okibcn_ScoopMaster https://github.com/okibcn/ScoopMaster

# List of packages to install
$packages = @(
    "3utools",
    "7zip",
    "autohotkey",
    "asio4all-np"
    "aria2",
    "atom-ng",
    "ayugram",
    "brave",
    "cascadia-code",
    "cava",
    "curl",
    "cpu-z",
    "delugia-mono-nerd-font-complete",
    "delugia-nerd-font-complete",
    "dotnet-framework-3.5-sp1",
    "dotnet-3.1-desktopruntime",
    "discord",
    "fastfetch",
    "flow-launcher",
    "fzf",
    "git",
    "github",
    "glazewm",
    "gpu-z",
    "hack-nf",
    "msiafterburner",
    "nanazip",
    "nano",
    "neofetch",
    "neovim",
    "nilesoft-shell",
    "nodejs",
    "nonportable/file-converter-np",
    "notepadplusplus",
    "notion",
    "ntop",
    "obs-studio",        
    "oh-my-posh",
    "oraclejre8",
    "handbrake",
    "quicklook",
    "qview",
    "scoop-completion",
    "sharex",
    "sudo",
    "speedfan",
    "systeminformer",
    "ultravnc",
    "ungoogled-chromium",
    "vcredist2022",
    "vcredist",
    "vscode",
    "parsec-np",
    "python39",
    "putty",
    "qbittorrent",
    "wget",
    "windhawk",
    "windowsdesktop-runtime",
    "windowsdesktop-runtime-lts",
    "windowsdesktop-runtime-7.0",
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

Write-Output "All packages have been installed."
