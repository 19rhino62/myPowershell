############################################################################################################################################################
## *********************************************************************************************************************************************************
## 
## Author: Wayne Morrison
## Purpose: This script was created to locate the vCenter based on the VM hostname/shortname.  
#  The vmlist.csv file must be used for this script.  The location of the
## file must match the $VMPath variable location.
##
##.INPUT description.
##
## Shortname or HOSTNAME
##    Example:
##              pbnaaeap001
##              pbnaaeap002
##              FBNAAEAP006
##
##.OUTPUT
##
##  Out contains information of the vCenter, OS type, vCenter version and FQDN.
## 	VM Search Successful
##
##    Example:
##	Server: FBNAAEAP006
##	FQDN: FBNAAEAP006.fpd2.healthcareit.net
##	OS Type: Microsoft Windows Server 2012 (64-bit)
##	vCenter/Hyper-V/Host Version: 6.5
##	vCenter/Hyper-V/Host Returned: fbnaaevvc001.fpd2.healthcareit.net
##
## A log file report is also produced in the form of a .csv
##
##	.\vCenter-20200625_144202.csv was logged
## *********************************************************************************************************************************************************
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
## 06/15/20   Created the script.                                                                                                        Wayne Morrison
## 06/25/20   Added documentation.                                                                                                       Wayne Morrison
## 06/29/20   Add message if VM cannot be located.                                                                                       Wayne Morrison
## 07/23/20   Added progress bar.                                                                                                        Wayne Morrison
## 07/23/20   Add start and stop timestamp                                                                                               Wayne Morrison
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
  $Report = ""
  $i = ""
    # ----------------------------------------------------------------------------------------------------------------------------------
    # Date/Time
    # ----------------------------------------------------------------------------------------------------------------------------------
#      $CurrentDateTime = Get-Date -format "yyyyMMdd_HHmm"

    # ----------------------------------------------------------------------------------------------------------------------------------
    # Server List
    # Enter a single server name of select a list <ENTER> from a text file.
    # ----------------------------------------------------------------------------------------------------------------------------------


<#      $TaniumPackageName   = "Tanium_Windows_Agent_preconfigured.msi"                                             # Name of the Tanium MSI package

      CD $PSScriptRoot                                                                                            # Change the path to the current directory from which this script is being executed
      $LogPath             = Join-Path $PSScriptRoot ("Logs\")                                                    # Log folder path
      $LogFile             = Join-Path $LogPath ("TaniumInstallation_"+$CurrentDateTime+".csv")                   # Log file location
      $LogFileTranscript   = Join-Path $LogPath ("TaniumInstallation__Transcript_"+$CurrentDateTime)              # Log file transcript folder name
      $InputPath           = Join-Path $PSScriptRoot ("\Input\")                                                  # Input path

      $TaniumInstallerPath = Join-Path $PSScriptRoot ("\Install\"+$TaniumPackageName)                             # Tanium MSI installer source path
#>
      # ----------------------------------------------------------------------------------------------------------------------------------
      # Create Log directory if it does not exist
      # ----------------------------------------------------------------------------------------------------------------------------------
 <#       If (Test-Path -Path $LogPath -PathType Container){
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
          Write-Host "The log directory $LogPath already exists" -ForegroundColor DarkCyan
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
        }
        Else {
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
          New-Item -Path $LogPath -ItemType Directory
          Write-Host "Log folder has now been created." -ForegroundColor Red
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
        }
#>
      # --------------------------------------------------------------------------------------------------------------------------------
      # Create Input directory if it does not exist
      # --------------------------------------------------------------------------------------------------------------------------------

<#        If (Test-Path -Path $InputPath -PathType Container){
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
          Write-Host "The input directory $InputPath already exists" -ForegroundColor DarkCyan
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
        }
        Else {
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
          Write-Host "Input folder has now been created." -ForegroundColor Red
          New-Item -Path $InputPath -ItemType Directory
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
        }
#>

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

############################################################################################################################################################
## *********************************************************************************************************************************************************
##                               __  __          _____ _   _    _____  _____ _____  _____ _____ _______ 
##                              |  \/  |   /\   |_   _| \ | |  / ____|/ ____|  __ \|_   _|  __ \__   __|
##                              | \  / |  /  \    | | |  \| | | (___ | |    | |__) | | | | |__) | | |   
##                              | |\/| | / /\ \   | | | . ` |  \___ \| |    |  _  /  | | |  ___/  | |   
##                              | |  | |/ ____ \ _| |_| |\  |  ____) | |____| | \ \ _| |_| |      | |   
##                              |_|  |_/_/    \_\_____|_| \_| |_____/ \_____|_|  \_\_____|_|      |_| 
##
## *********************************************************************************************************************************************************
############################################################################################################################################################

# --------------------------------------------------------------------------------------------------------------------------------
#TEST VMLIST PATH
# --------------------------------------------------------------------------------------------------------------------------------
#***************** CHANGE THE MASTER VM Inventory PATH AND FILE NAME HERE *******************************
$VMPath = 'C:\Users\wmorrison\Documents\Powershell\include\'
$VMFile = 'vmlist.csv'
#********************************************************************************************************

If (Test-Path -Path $VMPath$VMFile) {
    $VMList = Import-CSV -Path $VMPath$VMFile -ErrorAction SilentlyContinue
    }
Else {
    Write-Host "`n`tCan't find " -NoNewLine -ForegroundColor Red
    Write-Host $VMPath$VMFile
    break;
    }

#Enter Server or choose file
$ServerList = Read-Host -Prompt 'Type in HOSTNAME of the or <ENTER> to open a file'

    # ----------------------------------------------------------------------------------------------------------------------------------
    # File Paths and Names
    # ----------------------------------------------------------------------------------------------------------------------------------

# ==============================================================================================================================================
## 07/23/20   SETUP PROGRESS BAR
# ==============================================================================================================================================
$i=1
#$tot = $ServerList.count
# ==============================================================================================================================================

If(-not $ServerList) {
    $ServerList = Get-Content (Get-TXTinputFile)
    Write-Host `n`n

    }

$vCenterArray = @()

foreach ($hostname in $ServerList) {

    $hostname = $hostname.Trim();
  # ==============================================================================================================================================
  ## 07/23/20   PROGRESS BAR
  # ==============================================================================================================================================
#  	    $status = "{1:N1}" -f (($i / $tot) * 100)

#        Write-Progress -Activity "Searching VM List" -Status "Processing Server $i of $tot : $status% Completed" -PercentComplete (($i / $tot) * 100)
  # ==============================================================================================================================================

        $vCenterInfo = New-Object PSObject
    If ($ServerList.Count -gt 1) {
        Write-Progress -Activity "Searching for $hostname" -Status "Processing Server $i of $tot...checking $vm"
        }

###################################################################
    foreach ($vm in $VMList) {

        if ($vm.vm -eq $hostname){
            Write-Host "`n`tVM Search Successful`n" -ForegroundColor Green
            Write-Host "`tServer: " -NoNewline -ForegroundColor Green
            Write-Host $hostname
            Write-Host "`tFQDN: " -NoNewline -ForegroundColor Green
            Write-Host $vm.fqdn
            Write-Host "`tOS Type: " -NoNewline -ForegroundColor Green
            Write-Host $vm.os
            Write-Host "`tvCenter/Hyper-V/Host Version: " -NoNewline -ForegroundColor Green
            Write-Host $vm.vcversion
            Write-Host "`tvCenter/Hyper-V/Host: " -NoNewline -ForegroundColor Green
            Write-Host $vm.vCenter
            Write-Host "`tHypervisor: " -NoNewline -ForegroundColor Green
            Write-Host $vm.hypervisor

            $vCenterInfo | Add-Member -Type NoteProperty -Name "Server" -Value $hostname -Force
            $vCenterInfo | Add-Member -Type NoteProperty -Name "OS Type" -Value $vm.os -Force
            $vCenterInfo | Add-Member -Type NoteProperty -Name "Virtual Platform" -Value $vm.hypervisor -Force
            $vCenterInfo | Add-Member -Type NoteProperty -Name "FQDN" -Value $vm.fqdn -Force
            $vCenterInfo | Add-Member -Type NoteProperty -Name "vCenter/Hyper-V/Host" -Value $vm.vcenter -Force
            $vCenterInfo | Add-Member -Type NoteProperty -Name "vCenter Version" -Value $vm.vcversion -Force
            $vCenterInfo | Add-Member -Type NoteProperty -Name "Hypervisor" -Value $vm.hypervisor -Force
            break;
#>  
            }  # END IF VM IF        
        } # END FOR VM
    $i++
    $vCenterArray += $vCenterInfo
} # END FOR HOSTNAME

$Report = Read-Host "`n`tWould you like to log a report? (Y/N) <ENTER-No>"

Switch ($Report) {
    "" {If ($vCenterArray) {$vCenterArray};break}
    N {If ($vCenterArray) {$vCenterArray};break}
    No {If ($vCenterArray) {$vCenterArray};break}
    n {If ($vCenterArray) {$vCenterArray};break}
    Y {If ($vCenterArray) {
        $vCenterArray | Export-Csv .\vCenter-$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv
        Write-Host "`n`t.\vCenter-$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv was logged" -ForegroundColor Yellow
        };break}
    Yes {If ($vCenterArray) {
        $vCenterArray | Export-Csv .\vCenter-$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv
        Write-Host "`n`t.\vCenter-$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv was logged" -ForegroundColor Yellow
        };break}
    }
    
# Added 06/29/20 VM could not be found
If (-not $vCenterArray) {Write-Warning "VM / virtual HOST NOT FOUND! The server is either hardware, decommissioned or vmlist.csv needs to be updated."}