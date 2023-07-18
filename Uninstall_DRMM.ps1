# Remove any dregs from previous failed installs/uninstalls that will prevent the Agent installing
# Define architecture-based variables
$Arch=[intptr]::size*8
$WinReg="HKLM:\SOFTWARE"
if ($Arch -eq 32) {$PF=$env:ProgramFiles} else {$PF="$env:ProgramFiles (x86)" ; $WinReg+="\WOW6432Node"}

# Kill any existing processes and wait until they terminate
$Gui=(Get-Process -Name gui | Where-Object {$_.Path -Like "*CentraStage*"}).id
$AemAgent=(Get-Process -Name AEMAgent | Where-Object {$_.Path -Like "*CentraStage*"}).id
$Aria2c=(Get-Process -Name aria2c | Where-Object {$_.Path -Like "*CentraStage*"}).id

Stop-Process -Id $Gui -Force
Stop-Process -Id $AemAgent -Force
Stop-Process -Id $Aria2c -Force

Wait-Process -Id $Gui
Wait-Process -Id $AemAgent
Wait-Process -Id $Aria2c

# Uninstall if possible
if (Test-Path "$PF\CentraStage\uninst.exe") {Start-Process "$PF\CentraStage\uninst.exe" -Wait}

# Delete files and folders
Remove-Item "$PF\CentraStage" -Recurse -Force
Remove-Item "$env:windir\System32\config\systemprofile\AppData\Local\CentraStage" -Recurse -Force
Remove-Item "$env:windir\SysWOW64\System32\config\systemprofile\AppData\Local\Service" -Recurse -Force
Remove-Item "$env:windir\SysWOW64\config\systemprofile\AppData\Local\CentraStage" -Recurse -Force
Remove-Item "$env:windir\System32\config\systemprofile\AppData\Local\warp\packages\AEMAgent.exe" -Force
Remove-Item "$env:TEMP\.net\AEMAgent" -Recurse -Force
Remove-Item "$env:ProgramData\CentraStage" -Recurse -Force
Remove-Item "C:\Program Files (x86)\CentraStage" -Recurse -Force


$ProfilePath="$env:SystemDrive\Users"
$Usernames = Get-ChildItem -Path $ProfilePath
foreach ($Username in $Usernames) {Remove-Item "$ProfilePath\$Username\AppData\Local\CentraStage" -Recurse -Force}

# Delete registry keys and values
New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR
Remove-Item "HKCR:\cag" -Recurse -Force
Remove-Item "HKLM:\SOFTWARE\CentraStage" -Recurse -Force
Remove-ItemProperty "$WinReg\Microsoft\Windows\CurrentVersion\Run" -Name "CentraStage" -Force