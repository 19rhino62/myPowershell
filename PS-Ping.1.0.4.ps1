############################################################################################################################################################
## *********************************************************************************************************************************************************
## 
## Title: PS-Ping.ps1
## Author: Wayne Morrison
## Purpose: Ping a FQDN to see if it is active.   
##
## .LINK https://www.terraform.io/docs/extend/best-practices/versioning.html 
## In summary, this means that with a version number of the form MAJOR.MINOR.PATCH, the following meanings apply:
##
## Increasing only the patch number suggests that the release includes only bug fixes, and is intended to be functionally equivalent.
## Increasing the minor number suggests that new features have been added but that existing functionality remains broadly compatible.
## Increasing the major number indicates that significant breaking changes have been made, and thus extra care or attention is required during an 
## upgrade.
## 
## Version numbers above 1.0.0 signify stronger compatibility guarantees, based on the rules above. Each increasing level can also contain changes 
## of the lower level (e.g. MINOR can contain PATCH changes).
##
##.INPUT description.
##
##    Example: ddc-sup01tk03.tsh.mis.mckesson.com
##
##.OUTPUT
## 
## HOSTNAME                               IP Address    Pingable
## --------                               ----------    --------
## ddc-sup01tk03.tsh.mis.mckesson.com     10.5.36.100   Yes     
## zbnaaeex001.corporate.healthcareit.net 10.160.88.220 Yes     
## cordecildb001.gpd.emdeon.net           10.176.18.20  Yes 
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
## 07/08/2020 Rewrote the script.                                                                                                        Wayne Morrison
## mm/dd/yy   Removed dependency on PSexec and replaced with WMIC to allow faster processing.                                            Author
## mm/dd/yy   Updated the transcript log naming and location to match the CSV file naming to allow users to match up logs faster.        Author
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

      # ----------------------------------------------------------------------------------------------------------------------------------
      # Create Log directory if it does not exist
      # ----------------------------------------------------------------------------------------------------------------------------------

      # --------------------------------------------------------------------------------------------------------------------------------
      # Create Input directory if it does not exist
      # --------------------------------------------------------------------------------------------------------------------------------

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

  # ==============================================================================================================================================
  # 
  # ==============================================================================================================================================

#Enter Server or choose file
$Report = ""
$ServerList = Read-Host -Prompt 'Type in FQDN or <ENTER> to open a file with FQDN'

$PingArray = @()

#Select File Input
If(-not $ServerList) {
    $ServerList = Get-Content (Get-TXTinputFile)
    Write-Host `n`n
    }

ForEach ($servername in $ServerList) {

#Remove spaces
#    $servername = $servername.trim();
    $servername = $servername.trim();
    $PingInfo = New-Object PSObject

  # ==============================================================================================================================================
  #  PING TEST
  # ==============================================================================================================================================

    $Ping = Test-Connection -ComputerName $servername -Count 1 -ErrorAction SilentlyContinue

    If ($Ping) {
        Write-Host "`n`tCONNECTION SUCCESSFUL " -NoNewline -ForegroundColor Green
        Write-Host "`n`tServer Name: " -NoNewline -ForegroundColor Green
        Write-Host $servername
        Write-Host "`tIP Address: " -NoNewline -ForegroundColor Green
        Write-Host $Ping.IPV4Address
        Write-Host "`tPingable: " -NoNewline -ForegroundColor Green
        Write-Host "Yes"

        $PingInfo | Add-Member -Type NoteProperty -Name "HOSTNAME" -Value $servername -Force
        $PingInfo | Add-Member -Type NoteProperty -Name "IP Address" -Value $Ping.IPV4Address -Force
        $PingInfo | Add-Member -Type NoteProperty -Name "Pingable" -Value 'Yes' -Force
        }

    #TEST FOR EMPTY LINE [string]::IsNullOrEmpty($Service.Description)
    If ([string]::IsNullOrEmpty($servername)) {break;}

#    Else {
    If (-NOT $Ping) {
        $hostname = $servername
        Write-Host "`n`tCONNECTION FAILED" -NoNewline -ForegroundColor Red
        Write-Host "`n`tServer Name: " -NoNewline -ForegroundColor Red
        Write-Host $hostname
        Write-Host "`tPingable Status: " -NoNewline -ForegroundColor Red
        Write-Host "No"

        $PingInfo | Add-Member -Type NoteProperty -Name "HOSTNAME" -Value $hostname -Force
        $PingInfo | Add-Member -Type NoteProperty -Name "IP Address" -Value "N/A" -Force
        $PingInfo | Add-Member -Type NoteProperty -Name "OS" -Value "N/A" -Force
        $PingInfo | Add-Member -Type NoteProperty -Name "Pingable" -Value 'No' -Force
        continue
        }

$PingArray += $PingInfo
} # END FOR

$Report = Read-Host "`n`tWould you like to log a report? (Y/N) <ENTER-No>"

Switch ($Report) {
    "" {If ($PingArray) {$PingArray};break}
    N {If ($PingArray) {$PingArray};break}
    No {If ($PingArray) {$PingArray};break}
    Y {$PingArray | Export-Csv ".\PINGRESULTS_$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv" -NoTypeInformation
        Write-Host "`n`t .\PINGRESULTS_$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv was logged`n" -ForegroundColor Yellow}
    Yes {$PingArray | Export-Csv ".\PINGRESULTS_$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv" -NoTypeInformation
        Write-Host "`n`t .\PINGRESULTS_$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv was logged`n" -ForegroundColor Yellow}
    }

If (-not $PingArray) {Write-Warning "Server cannot be reached"}
