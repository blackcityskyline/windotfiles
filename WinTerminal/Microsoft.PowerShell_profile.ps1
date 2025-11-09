oh-my-posh init pwsh --config D:\scoop\apps\oh-my-posh\current\themes\kushal.omp.json | Invoke-Expression

Import-Module posh-git
Clear-Host
# Force Fastfetch to use YOUR config every time (bypass path confusion)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch -c "C:/Users/admin/.config/fastfetch/config.jsonc"
}
