#
#.LINK https://www.whatsupgold.com/blog/how-to-find-restart-info-for-machines-on-your-network-using-powershell-and-windows-event-logs

#Get-WinEvent -ComputerName PBNAAETS3001.prod.healthcareit.net -Credential prod\wmorrison_admin

#$ServerList = 'zmemcfdc015.gwe.webmd.net'
$ServerList = '.'

#$Domain = Read-Host "Enter Domain Name for these servers"

#$Creds = Get-Credential "$env:USERDOMAIN\$env:USERNAME" -Message "Enter ADMIN credentials"
#$Creds = Get-Credential "$Domain\$env:USERNAME" -Message "Enter ADMIN credentials"

#$lastpatch = Get-WmiObject -ComputerName "COMPUTERNAME" Win32_Quickfixengineering | select @{Name="InstalledOn";Expression={$_.InstalledOn -as [datetime]}} | Sort-Object -Property Installedon | select-object -property installedon -last 1
$RebootInfo = @()

ForEach ($server in $ServerList) {
#LAST BOOT TIME
#$lastboot = Get-WmiObject -ComputerName "COMPUTERNAME" win32_operatingsystem | select @{Name="LastBootUpTime";Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Select-Object -Property lastbootuptime
#$lastboot = Get-WmiObject -ComputerName . win32_operatingsystem | select @{Name="LastBootUpTime";Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Select-Object -Property lastbootuptime
#Get-Date $lastboot.lastbootuptime -Format "MM-dd-yyyy hh:mm:ss tt"

$lastboot = (Get-WmiObject -ComputerName $server win32_operatingsystem | select @{Name="LastBootUpTime";Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Select-Object -Property lastbootuptime).lastbootuptime

#Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074} -Credential prod\wmorrison_admin -ComputerName PBNAAETS3001.prod.healthcareit.net | Format-Table -wrap
#Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074} | Format-Table -wrap
$lastbootevent = @(Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074} -MaxEvents 1 | Format-Table -wrap)

    Write-Host "`n`tLast Reboot" -ForegroundColor Yellow
    Write-Host "`tDevice: " -NoNewline -ForegroundColor Green
    Write-Host $server
    Write-Host "`tLast Boot Time " -NoNewline -ForegroundColor Green
    Write-Host $lastboot
    Write-Host "`tLast Boot Event " -NoNewline -ForegroundColor Green
    Write-Host $lastbootevent

}