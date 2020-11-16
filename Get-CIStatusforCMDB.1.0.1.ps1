############################################################################################################################################################
## *********************************************************************************************************************************************************
## 
## Title:Get-CIStatusforCMDB.ps1
## Author: Wayne Morrison
## Purpose: CI STATUS
##
## SystemInfo
## HostName
## systeminfo | find /i “Boot Time”
##
## OS
## OS Ver
## Domain
## IN BUILDOUT
##
## IN BUILDOUT --> IN APPCONFIG (PINGABLE-TRUE)
## a.TRUE	(R) Check if MCAFEE AV is installed and reporting, if not, install and verify in ePO if reported and created in the right container
## b.TRUE	(R) Check if MONITORING is installed and reporting, if not, open SR ticket to Monitoring Team to add to standard monitoring
## c.NO	(R) Check if server is added to BACKUP schedule, if not, open SR ticket to Backup Team to add to backup schedule or install agent if needed. (VM does not need agent as backup is done through vCenter).
## d.NO	Check if BLADELOGIC Agent is installed, if not, install and verify if agent is working.
##       e. Check if TRUEAGENT local account is created, if not, create it. This is used as BladeLogic service account backup.
## f.	 If PHYSICAL, update firmware and drivers through DELL Software Updates
## g.TRUE Check if the server is patched with the latest approved SECURITY PATCHES, if not, run Shavlik/BladeLogic to patch the server
## 
## INAPP CONFIG --> IN SERVICE
## Along with FM approval, Application Team to submit another ticket to Windows Team to update CI Status from “InApp Config” to “In Service”. 
## This will ensure that server will be monitored, patched, backup and supported properly.
## APPLICATION CONFIGURED - BMC_Application
## 
## Windows Team to update CMDB for the following:
## a.	Change CI status – “In Service”
## b.	Add Team Responsibility for Equipment Administration to (if not present yet):
##    i.	191 – if for “Windows Support” (Offshore and Onsite Windows Team can support) - 
##    ii.	445 – if for “Windows Onshore Support” (Onsite Windows Team only)
##    iii.  448 - SQL Database Support - Database Administration
## c.	Add Notes and log the ticket number and the request details
## 
## Get-NetFirewallProfile ******
## 
##
##.INPUT description.
##
##    Example:
##
##.OUTPUT
##  Successful Connection
##	Host Returned: ZBNAAEEX001
##	OS Returned: Microsoft Windows Server 2016 Standard
##	OS Version Returned: 10.0.14393
##	Domain: corporate.healthcareit.net
##	McAfee Agent: McAfee Agent Service
##	McAfee State: Running
##	Tivoli/ITM Agent: Not Installed
##	BladeLogic Agent: BMC BladeLogic Server Automation RSCD Agent
##	BladeLogic State: Running
##	Hotfixes Installed: KB3199986 KB4035631 KB4049065 KB4093137 KB4132216 KB4343887
##
## .CSV File
## "Host","OS","Version","Domain","Tivoli Installed","BladeLogic Installed","Hotfixes Installed","CI Status"
## "CH106427","Microsoft Windows 10 Enterprise","10.0.17763","corporate.healthcareit.net","No","No","Yes","IN BUILDOUT"
##
############################################################################################################################################################

############################################################################################################################################################
## *********************************************************************************************************************************************************
##                                _____ _    _          _   _  _____ ______   _      ____   _____ 
##                               / ____| |  | |   /\   | \ | |/ ____|  ____| | |    / __ \ / ____|
##                              | |    | |__| |  /  \  |  \| | |  __| |__    | |   | |  | | |  __ 
##                              | |    |  __  | / /\ \ | . ` | | |_ |  __|   | |   | |  | | | |_ |
##                              | |____| |  | |/ ____ \| |\  | |__| | |____  | |___| |__| | |__| |
##                               \_____|_|  |_/_/    \_\_| \_|\_____|______| |______\____/ \_____|
##
##----------------------------------------------------------------------------------------------------------------------------------------------------------
## Date     | Description of change                                                                                                    | Author 
##----------------------------------------------------------------------------------------------------------------------------------------------------------
##
## 06/11/2020 Created the script.                                                                                                        Wayne Morrison
## 06/30/2020 Toggle WinRM service when it errors out                                                                                    Wayne Morrison
## 07/27/2020 Fixed so WinRM service is report in array                                                                                  Wayne Morrison
## mm/dd/yy   Updated the file references to look to the script directory for the installation file.                                     Author
## mm/dd/yy   Added an installation result column to the CSV output.                                                                     Author
## mm/dd/yy   Replaced the LastGoodServerName registry value with ServerName value.                                                      Author
## mm/dd/yy   Added a wait command to insure the registry values have time to update before pulling them.                                Author
##
## *********************************************************************************************************************************************************
############################################################################################################################################################

  # ==============================================================================================================================================
  # Clear the screen
  # ==============================================================================================================================================
    #CLS

############################################################################################################################################################
## *********************************************************************************************************************************************************
##                              __      __     _____  _____          ____  _      ______  _____ 
##                              \ \    / /\   |  __ \|_   _|   /\   |  _ \| |    |  ____|/ ____|
##                               \ \  / /  \  | |__) | | |    /  \  | |_) | |    | |__  | (___  
##                                \ \/ / /\ \ |  _  /  | |   / /\ \ |  _ <| |    |  __|  \___ \ 
##                                 \  / ____ \| | \ \ _| |_ / ____ \| |_) | |____| |____ ____) |
##                                  \/_/    \_\_|  \_\_____/_/    \_\____/|______|______|_____/ 
##
## *********************************************************************************************************************************************************
############################################################################################################################################################

  # ================================================================================================================================================
  # Variable Declarations
  # ================================================================================================================================================


    # ----------------------------------------------------------------------------------------------------------------------------------
    # Date/Time
    # ----------------------------------------------------------------------------------------------------------------------------------

#      $CurrentDateTime = Get-Date -format "yyyyMMdd_HHmm"

    # ----------------------------------------------------------------------------------------------------------------------------------
    # File Paths and Names
    # ----------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################################################
## *********************************************************************************************************************************************************
##                               ______ _    _ _   _  _____ _______ _____ ____  _   _  _____ 
##                              |  ____| |  | | \ | |/ ____|__   __|_   _/ __ \| \ | |/ ____|
##                              | |__  | |  | |  \| | |       | |    | || |  | |  \| | (___  
##                              |  __| | |  | | . ` | |       | |    | || |  | | . ` |\___ \ 
##                              | |    | |__| | |\  | |____   | |   _| || |__| | |\  |____) |
##                              |_|     \____/|_| \_|\_____|  |_|  |_____\____/|_| \_|_____/ 
##
## *********************************************************************************************************************************************************
############################################################################################################################################################
 
  # ==============================================================================================================================================
  # Function:     Get-TXTinputFile
  # Information:  Get the text input file name
  # Example Call: $ServerList = Get-Content (Get-TXTinputFile)
  # ==============================================================================================================================================

  # ==============================================================================================================================================
  # Function:     Get-TXTinputFile
  # Information:  Get the text input file name
  # Example Call: $ServerList = Get-Content (Get-TXTinputFile)
  # ==============================================================================================================================================
    Function Get-TXTinputFile{
	  Write-Host `n; Write-Host "Select the TXT server input file." -BackgroundColor Yellow -ForegroundColor Black
	
	  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
	  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	  $OpenFileDialog.InitialDirectory = $InputPath
	  $OpenFileDialog.Multiselect = $False
	  $OpenFileDialog.Filter = "TXT files (*.txt)|*.txt"
	  $OpenFileDialog.ShowDialog() | Out-Null
	  $OpenFileDialog.FileName
	
	  Write-Host `n; Write-Host "The selected file is" $OpenFileDialog.FileName
    }


#############################################################
#################### MAIN CODE ##############################
#############################################################

#Input FQDN server names
#$server = 'zbnaaeap159.corporate.healthcareit.net' No Tivoli
#$server = 'zbnaaevhemsva01.corporate.healthcareit.net' winrm issues
#$ServerList = 'PBNAAEAP005.wpd.envoy.net' # JUMP SERVER
#$server = 'zyvrcpfs001.corporate.healthcareit.net'
#$serverlist = 'zbnaaeex001.corporate.healthcareit.net' #EXCHANGE SERVER No Tivoli

$CIStatusArray = @()

$ServerList = Read-Host -Prompt 'Type or paste in FQDN or <ENTER> to open a file'
$server = 

#$Creds=Get-Credential -Message "Enter Domain Credentials"

#Select File Input
If(-not $ServerList) {
    $ServerList = Get-Content (Get-TXTinputFile)
    Write-Host `n`n
    }

<#If ($ServerList -eq ".") {
#Get Domain if SERVER is local host
            $WMIDomain = Get-WmiObject -ComputerName . -Class Win32_ComputerSystem -ErrorAction SilentlyContinue 
            $Domain = $WMIDomain.Domain
            $server = $server.Trim();
          }
#>

ForEach ($server in $ServerList) {
    $server = $server.Trim()

    $ServiceSArray = New-Object PSObject

# ----------------------------------------------------------------------------------------------------------------------------------
# ################ TEST PING IN CASE WINRM OR RPC ERRORS OUT ###########
# ----------------------------------------------------------------------------------------------------------------------------------
    Try {$Ping = Test-Connection -ComputerName $server -Count 1 -ErrorAction SilentlyContinue
        $PingTest = $true
        }
    Catch {$Ping = $null #}
        $PingTest = $false}

  # ==============================================================================================================================================
  # 
  # #################### SystemInfo ###############################
  # 
  # ==============================================================================================================================================

    If ($Ping) {
#        $WinRMService = Get-Service -ComputerName $server -ErrorAction  | Where-Object {$_.Name -EQ "WinRM"}
        $SystemInfo = Get-CimInstance -ComputerName $server -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
# changed lookup 7/21/2020
        $ComputerSystem = Get-WmiObject -Class:Win32_ComputerSystem -ComputerName $server -ErrorAction SilentlyContinue

  # ==============================================================================================================================================
  # 
  ## systeminfo | find /i “Boot Time”
  # 
  # ==============================================================================================================================================
<#     $lastBootTime = [Management.ManagementDateTimeConverter]::ToDateTime($wmiOS.LastBootUpTime)
    Out-Object `
      @{"ComputerName" = $computerName},
      @{"LastBootTime" = $lastBootTime},
      @{"Uptime"       = (Get-Date) - $lastBootTime | Format-TimeSpan}
#>
  # ==============================================================================================================================================
  # 
  ################## Toggle WinRM Service ###############################
  # 
  # ==============================================================================================================================================
#        $WinRMService = Get-WmiObject -ComputerName $server -Class Win32_Service -Credential $Creds -Filter "Name='WinRM'"
<#        Switch ($WinRMService.StartMode)
            {
             Manual {
                #Start-Service -Name WinRM
                $WinRMService.startservice() | Out-Null
                sleep 1
                #$SystemInfo = Get-WmiObject -ComputerName $server -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
                $WinRMFlag = "Manual"
                break;
                    }

             Disabled{
                #Change to Manual, Start WinRM
                $WinRMService.ChangeStartMode("Manual") | Out-Null
                sleep 2
                $WinRMService.startservice() | Out-Null
                sleep 2
                #$SystemInfo = Get-WmiObject -ComputerName $server -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
                $WinRMFlag = "Disabled"
                break;
                    }
            Auto {
                #$SystemInfo = Get-WmiObject -ComputerName $server -ClassName Win32_OperatingSystem -Credential $Creds -ErrorAction SilentlyContinue
                break
#                $WinRMFlag = "Auto"
                }
#>  }
    Else {
        Write-Host "`n`t$server " -NoNewline
        Write-Host 'IS NOT PINGABLE' -ForegroundColor Red
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Host" -Value $SystemInfo.CSName -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "CI Status" -Value "Not Pingable" -Force

        $CIStatusArray += $ServicesArray
        }

#    Else {$WinRMService=$null;$SystemInfo=$null}
       
#################################################################################
  # ==============================================================================================================================================
  # 
  # #################### BAD CONNECTION NOT PINGABLE ###############################
  # 
  # ==============================================================================================================================================

    If ($SystemInfo -eq $null){
#        $WinRMService = Get-Service -ComputerName $server -ErrorAction  | Where-Object {$_.Name -EQ "WinRM"}
#        $WinRMService = Get-WmiObject -ComputerName $server -Class Win32_Service -Filter "Name='WinRM'"
#        $WinRMService | fl *
        Write-Host "`t$server " -NoNewline
        Write-Host "is pingable, but WinRM cannot process the request!" -ForegroundColor Red
        Write-Host "`tPlease start the Windows Remote Management (WS-Management) service!" -ForegroundColor Yellow

# Added 7/1/2020 report WinRM status
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Host" -Value $server -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "CI Status" -Value "Start WinRM" -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Domain" -Value "N/A" -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "McAfee Installed" -Value "N/A" -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Tivoli Installed" -Value "N/A" -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "BladeLogic" -Value "N/A" -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Tivoli Installed" -Value "N/A" -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Hotfixes Installed" -Value "N/A" -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "CI Status" -Value "Start WinRM Service" -Force

        $CIStatusArray += $ServicesArray
        } #END IF NOT PINGABLE

  # ==============================================================================================================================================
  # 
  # #################### GOOD CONNECTION PING NEEDS TO BE TRUE###############################
  # 
  # ==============================================================================================================================================

    If ($SystemInfo -ne $null) {
        Write-Host "`n`tSuccessful Connection" -ForegroundColor Green
        Write-Host "`tHost Returned: " -NoNewline -ForegroundColor Green
        Write-Host $SystemInfo.CSName
        Write-Host "`tOS Returned: " -NoNewline -ForegroundColor Green
        Write-Host $SystemInfo.Caption
        Write-Host "`tOS Version Returned: " -NoNewline -ForegroundColor Green
        Write-Host $SystemInfo.Version
        Write-Host "`tDomain: " -NoNewline -ForegroundColor Green
# changed lookup 7/21/2020
        Write-Host $ComputerSystem.Domain

        $ServiceSArray | Add-Member -Type NoteProperty -Name "Host" -Value $server -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "OS" -Value $SystemInfo.Caption -Force
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Version" -Value $SystemInfo.Version -Force

# changed lookup 7/21/2020
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Domain" -Value $ComputerSystem.Domain -Force

# ==============================================================================================================================================
# 
#################### #McAfee ###############################
#
# ==============================================================================================================================================

    Try{$McAfee = Get-CimInstance -ComputerName $server -ClassName Win32_service -ErrorAction SilentlyContinue | Where-Object {$_.Name -EQ "masvc" -and $_.State -EQ "Running"}}
    Catch{$McAfee = $null}

    If ($McAfee -ne $null) {
        Write-Host "`tMcAfee Agent: " -NoNewline -ForegroundColor Green
        Write-Host $McAfee.DisplayName
        Write-Host "`tMcAfee State: " -NoNewline -ForegroundColor Green
        Write-Host $McAfee.State

        $ServiceSArray | Add-Member -Type NoteProperty -Name "McAfee Installed" -Value "Yes" -Force
    }
#############################################################

# ==============================================================================================================================================
# 
#                   Tivoli
# 
#Tivoli or IBM Monitoring Agent
# KNTCMA_FCProvider                        Monitoring Agent for Windows OS - FCProvider 
# Monitoring Agent for Windows OS - Primary           
# KNTCMA_Primary                           Monitoring Agent for Windows OS - Primary               
# Monitoring Agent for Windows OS - Watchdog
# KNTCMA_Watchdog                          Monitoring Agent for Windows OS - Watchdog
# 
# ==============================================================================================================================================

    Try{$Tivoli = Get-CimInstance -ComputerName $server -ClassName Win32_Service -ErrorAction SilentlyContinue | Where-Object {$_.Name -EQ "KNTCMA_Primary" -and $_.State -EQ "Running"}}
    Catch {$Tivoli = $null}

    #If ($Tivoli -eq $null) {}

    If ($Tivoli -ne $null) {
        Write-Host "`tTivoli/ITM Agent: " -NoNewline -ForegroundColor Green
        Write-Host $Tivoli.DisplayName
        Write-Host "`tTivoli/ITM State: " -NoNewline -ForegroundColor Green
        Write-Host $Tivoli.State

        $ServiceSArray | Add-Member -Type NoteProperty -Name "Tivoli Installed" -Value "Yes" -Force
        }
    Else {
        Write-Host "`tTivoli/ITM Agent: " -NoNewline -ForegroundColor Red
        Write-Host "Not Installed"
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Tivoli Installed" -Value "No" -Force

        }

# ==============================================================================================================================================
# 
##                            ##### Blade Logic #####
##
#                TrueSight Server Automation Console Upgrade Service
#
#                     BMC Bladelogic Server Automation RSCD Agent
# ==============================================================================================================================================

#Get-CimInstance  -ComputerName $server -class Win32_Service | Where-Object {$_.DisplayName -EQ "TrueSight Server Automation Console Upgrade Service" -and $_.State -eq "running"}
#Get-CimInstance -class Win32_Product | where-object Name -eq "BMC Bladelogic Server Automation RSCD Agent"

#       $BMC = Get-Service -ComputerName $Computer | Where-Object {$_.DisplayName -like "BMC *" -and $_.Status -EQ "Running"}
    Try {$BMC = Get-CimInstance  -ComputerName $server -class Win32_Service -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq "RSCDsvc" -and $_.State -eq "Running"}}
    Catch {$BMC = $null}

#   If (-not $BMC) {
#   $TSS = Get-CimInstance  -ComputerName $server -class Win32_Service | Where-Object {$_.DisplayName -like "TrueSight *" -and $_.State -EQ "Running"}
    If ($BMC -ne $null) {
        Write-Host "`tBladeLogic Agent: " -NoNewline -ForegroundColor Green
        Write-Host $BMC.DisplayName
        Write-Host "`tBladeLogic State: " -NoNewline -ForegroundColor Green
        Write-Host $BMC.State

        $ServiceSArray | Add-Member -Type NoteProperty -Name "BladeLogic" -Value $BMC.DisplayName -Force
        }
    Else {
        Write-Host "`tBladeLogic Agent: " -NoNewline -ForegroundColor Red
        Write-Host "Not Installed"

        $ServiceSArray | Add-Member -Type NoteProperty -Name "BladeLogic Installed" -Value "No" -Force
        }


# ==============================================================================================================================================
#
#################### Backup Agents ################################
#
# ==============================================================================================================================================

    #Try {$BackupAgent = Get-CimInstance  -ComputerName $server -class Win32_Service -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq "RSCDsvc" -and $_.State -eq "Running"}}
    #Catch {$BackupAgent = $null}

    $BackupAgent = $true

# ==============================================================================================================================================
# 
#################### Hot Fixes / Patches ################################
# 
# ==============================================================================================================================================

    #$QFE = Get-hotfix -computername $server | select-object -property CSName,Description,HotFixID,InstalledBy,InstalledOn | out-file c:\windows\temp\$server.txt

    #Get-Hotfix -computername $_ | Select CSName,Description,HotFixID,InstalledBy,InstalledOn | convertto-csv | out-file "C:\$_.csv" 
    #Get Last time patches were instaled
    #Get-WmiObject -Credential "domain\username" -ComputerName "COMPUTERNAME" Win32_Quickfixengineering | select @{Name="InstalledOn";Expression={$_.InstalledOn -as [datetime]}} | Sort-Object -Property Installedon | select-object -property installedon -last 1

#    Try{$Hotfix = Get-HotFix -ComputerName . | where {$_.HotfixID -ne ""}}
    Try{$Hotfix = Get-HotFix -ComputerName $server -ErrorAction SilentlyContinue}
    Catch{$Hotfix=$null}

## 
    If ($Hotfix -ne $null) {
        Write-Host "`tHotfixes Installed: " -NoNewline -ForegroundColor Green
#        Write-Host $Hotfix.HotFixID
        Write-Host "Yes"
#     Write-Host "`tBladeLogic State: " -NoNewline -ForegroundColor Green
#     Write-Host $BMC.State

        $ServiceSArray | Add-Member -Type NoteProperty -Name "Hotfixes Installed" -Value "Yes" -Force
    }
    Else {
        Write-Host "`tHotfixes Installed: " -NoNewline -ForegroundColor Red
        Write-Host "No"
        
        $ServiceSArray | Add-Member -Type NoteProperty -Name "Hotfixes Installed" -Value "No" -Force
    }
        
# ==============================================================================================================================================
##
#################### Tanium ################################
##
# ==============================================================================================================================================

#Try{$TaniumAgent = Get-Service -ComputerName $server -ErrorAction SilentlyContinue | Where-Object {$_.Name -EQ "Tanium Client" -and $_.Status -EQ "Running"}}
#Catch {$TaniumAgent = $null}

#############################################################

# ==============================================================================================================================================
## Get-NetFirewallProfile ******
##
## NEED CODE
# ==============================================================================================================================================

# ==============================================================================================================================================
##
#################### APPLICATIONS?? ################################
##
# ==============================================================================================================================================

#Try{$InstalledApps = Get-WmiObject -Class Win32_Product -Computer $server | select Name -ErrorAction SilentlyContinue}
#Catch {$InstalledApps = $null}
    $InstalledApps = $true
#Exhange Name = MSExchangeIS

#############################################################

# ==============================================================================================================================================
# 
####################### CI STATUS ########################
# 
# ==============================================================================================================================================
## IN BUILDOUT --> IN APPCONFIG (PINGABLE-TRUE)
## a.TRUE	(R) Check if MCAFEE AV is installed and reporting, if not, install and verify in ePO if reported and created in the right container
## b.TRUE	(R) Check if MONITORING is installed and reporting, if not, open SR ticket to Monitoring Team to add to standard monitoring
## c.NO	(R) Check if server is added to BACKUP schedule, if not, open SR ticket to Backup Team to add to backup schedule or install agent if needed. (VM does not need agent as backup is done through vCenter).
## d.NO	Check if BLADELOGIC Agent is installed, if not, install and verify if agent is working.
##       e. Check if TRUEAGENT local account is created, if not, create it. This is used as BladeLogic service account backup.
## f.	 If PHYSICAL, update firmware and drivers through DELL Software Updates
## g.TRUE Check if the server is patched with the latest approved SECURITY PATCHES, if not, run Shavlik/BladeLogic to patch the server
## 
## INAPP CONFIG --> IN SERVICE
## Along with FM approval, Application Team to submit another ticket to Windows Team to update CI Status from “InApp Config” to “In Service”. 
## This will ensure that server will be monitored, patched, backup and supported properly.
## 
## Windows Team to update CMDB for the following:
## a.	Change CI status – “In Service”
## b.	Add Team Responsibility for Equipment Administration to (if not present yet):
##    i.	191 – if for “Windows Support” (Offshore and Onsite Windows Team can support)
##    ii.	445 – if for “Windows Onshore Support” (Onsite Windows Team only)
##    iii.  448 - SQL Database Support - Database Administration
## c.	Add Notes and log the ticket number and the request details
## 
# ==============================================================================================================================================

<#
$PingTest
$McAfee
$BMC
$BackupAgent
$Hotfix
$InstalledApps
#>
# ==============================================================================================================================================
####################### IN APPCONFIG ########################
# ==============================================================================================================================================
#If ($McAfee -and $Tivoli -and $BMC -and $BackupAgent -and $Hotfix){
    If ($PingTest -and $McAfee -and $BMC -and $BackupAgent -and $Hotfix){
        $CIStatus = "IN APPCONFIG"
        $InAppConfig = $true
        }
#############################################################

# ==============================================================================================================================================
####################### IN BUILDOUT ########################
# ==============================================================================================================================================
    Else {If ($PingTest){$CIStatus = "IN BUILDOUT";$InAppConfig = $false}}
#############################################################

####################### IN SERVICE ########################
    If ($InAppConfig -and $InstalledApps){
        $CIStatus = "IN SERVICE"
        }
#############################################################

# ==============================================================================================================================================
####################### OUT OF SERVICE ########################
# ==============================================================================================================================================
    If (-not($Ping) -and -not($InAppConfig)) {$CIStatus = "OUT OF SERVICE"}
        
        $ServiceSArray | Add-Member -Type NoteProperty -Name "CI Status" -Value $CIStatus -Force

<#############################################################
## RESTORE WINRM SERVICES TO ORIGINAL SETTINGS
Switch ($WinRMFlag) {
    Manual {$WinRMService.stopservice() | Out-Null}
    Disabled {$WinRMService.changestartmode("Disabled") | Out-Null
            $WinRMService.stopservice() | Out-Null}
        }
#############################################################>
$CIStatusArray += $ServicesArray




        } # ENDIF SYSTEMINFO (PINGABLE)

} # END FOR

If ($CIStatusArray) {
#    $CIStatusArray #| ft -AutoSize

    $CIStatusArray | Export-Csv .\"CIStatus-$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv" -NoTypeInformation

    Write-Host "`n`t .\CIStatus-$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv was logged`n" -ForegroundColor Yellow
    }
#Else {Write-Host "`n`tCan't Connect to Server" -ForegroundColor DarkGray}

