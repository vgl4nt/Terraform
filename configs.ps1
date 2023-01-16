function EnableWinRM() {
    $NetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
    $Connections = $NetworkListManager.GetNetworkConnections()
    $Connections | ForEach-Object { $_.GetNetwork().SetCategory(1) }
    Enable-PSRemoting -Force
    winrm quickconfig -q
    winrm quickconfig -transport:http
    winrm set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'
    winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
    netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
    netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
    Set-Service winrm -startuptype "auto"
    Restart-Service winrm
}

function DisableFirewall() {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
}

function EnableRDP() {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
}


function Print($texto) {
    write-host -ForegroundColor Green $texto
}

function WindowsUpdate($texto) {
    Get-PackageProvider -name nuget -force
    Install-Module PSWindowsUpdate -confirm:$false -force
    Get-WindowsUpdate -MicrosoftUpdate -install -IgnoreUserInput -acceptall -AutoReboot | Out-File -filepath 'c:\windowsupdate.log' -append
}

function EnableWinRM2() {
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0
}

function InstallOpera() {
    mkdir C:\temp
    Invoke-WebRequest -Uri "https://net.geo.opera.com/opera/stable/windows" -OutFile "C:\temp\OperaSetup.exe"
    C:\temp\OperaSetup.exe --silent
}

function adduser() {
    (net user /add teste s1mpl3@TryHard) -and (net localgroup administrators teste /add)
}

function disco() {
    Initialize-Disk 1
    Start-Sleep 5
    new-partition -disknumber 1 -usemaximumsize -AssignDriveLetter | format-volume -filesystem NTFS -newfilesystemlabel newdrive
}
EnableWinRM
DisableFirewall
EnableRDP
InstallOpera
adduser
disco
#WindowsUpdate
