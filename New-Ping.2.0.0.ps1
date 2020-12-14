############################################################################################################################################################
## *********************************************************************************************************************************************************
## 
## Property of Change Healthcare
##
## Author:  Zach Schreiber
## Purpose: Pulls the server data needed for CHCBR1240 "Logging of Server Events"
##
## Information: This has been tested on on Server 2008, 2012, 2016 & 2019 on PowerShell versions 2 - 5.1
##              
## Input File:  If using an input file to pull the server names it needs to be in a .txt file. 
##              The system will automatically look in the "Input" directory where the script is run from for the input file and filters for just .txt files.
##              Each server must be listed on it's own line.
##              You can use the base server name or FQDN.  But to avoid DNS issues it is recommended to use the FQDN.
##          
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
## 08/20/20   Base script created.                                                                                                       Zach Schreiber
## 08/21/20   Modified the script to allow the local server name to be used without typing it in.                                        Zach Schreiber
## 08/25/20   Updated the script to run the port 135 check only if the server is pingable.                                               Zach Schreiber
## 08/25/20   Added the checks to insure the user running the script has access to the server also accounts for RPD errors.              Zach Schreiber
## 08/25/20   Added a section to pull all of the drive letters from the server.                                                          Zach Schreiber
## 08/25/20   Added the local domain name to the output file to allow easier organization.                                               Zach Schreiber
## 08/25/20   Corrected the output path that shows on the screen.                                                                        Zach Schreiber
## 08/31/20   Added check for the PowerShell version being used.                                                                         Zach Schreiber
## 08/31/20   Corrected the variable error $ServerRole.DomainRole to $ServerType.DomainRole.                                             Zach Schreiber
## 08/31/20   Modified the followin service checks to avoid unnecessary errors on the screen when the services are not found.            Zach Schreiber
##            Citrix
##              - Was: $CitrixRelated = (Get-Service -Computer $Server -Name 'BrokerAgent' -ErrorAction SilentlyContinue).Status
##              - Now: $CitrixRelated = (Get-Service -Computer $Server -Name 'BrokerAgent' -ErrorAction SilentlyContinue) | Select Status 
##            IIS
##              - Was: $IISInstalled = (Get-Service -Computer $Server -Name 'IISADMIN' -ErrorAction SilentlyContinue).Status
##              - Now: $IISInstalled = (Get-Service -Computer $Server -Name 'IISADMIN' -ErrorAction SilentlyContinue) | Select Status 
##            Horizon
##              - Was: $VMHorizonRelated = (Get-Service -Computer $Server -Name 'VMBlast' -ErrorAction SilentlyContinue).Status
##              - Now: $VMHorizonRelated = (Get-Service -Computer $Server -Name 'VMBlast' -ErrorAction SilentlyContinue) | Select Status
##            TS Gateway
##              - Was: $TSGatewayInstalled = (Get-Service -Computer $Server -Name 'WSNM' -ErrorAction SilentlyContinue).Status
##              - Now: $TSGatewayInstalled = (Get-Service -Computer $Server -Name 'WSNM' -ErrorAction SilentlyContinue) | Select Status
## 08/31/20   Added logic for versions of PowerShell that do not work with the $PSScriptRoot variable                                    Zach Schreiber
## 08/31/20   Added the missing variable $Timeout                                                                                        Zach Schreiber
## 10/27/20   Hardcoded to only use an input server list to bypass the issues with older powershell versions.                            Zach Schreiber
## 11/16/20   Added a seperate E: drive check.                                                                                           Zach Schreiber
## 11/16/20   Added additional logic to pull all the data from all physical drive letters.                                               Zach Schreiber
##
## *********************************************************************************************************************************************************
############################################################################################################################################################
  
  # ==============================================================================================================================================
  # Clear the screen
  # ==============================================================================================================================================
  #  Clear-Host

    Set-StrictMode –Version 2

  # ==============================================================================================================================================
  # Admin Check: If PowerShell is not running as administrator stop running the script.
  # ==============================================================================================================================================
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 

    If($IsAdmin -eq $False){
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
      Write-Host "                                                                                      " -ForegroundColor Yellow
      Write-Host "  Please restart the script with elevated administrator permissions.                  " -ForegroundColor Yellow
      Write-Host "                                                                                      " -ForegroundColor Yellow
      Write-Host "  Exiting the script...                                                               " -ForegroundColor Yellow
      Write-Host "                                                                                      " -ForegroundColor Yellow
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
      Break
    }

  # ==============================================================================================================================================
  # PowerShell Version Check: If PowerShell is not running on version 2 or higher stop running the script.
  # ==============================================================================================================================================
    $LocalPSVersion = (Get-Host).Version
    Write-Host "`t`nPowerShell Version: "  -NoNewline -ForegroundColor Green
    Write-Host $LocalPSVersion

    If($LocalPSVersion.Major -lt 2){
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
      Write-Host "                                                                                      " -ForegroundColor Yellow
      Write-Host "  This PowerShell version $LocalPSVersion is not compatiable with this script.        " -ForegroundColor Yellow
      Write-Host "                                                                                      " -ForegroundColor Yellow
      Write-Host "  Exiting the script...                                                               " -ForegroundColor Yellow
      Write-Host "                                                                                      " -ForegroundColor Yellow
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
      Write-Host "**************************************************************************************" -ForegroundColor Yellow
    }

  # ==============================================================================================================================================
  # PowerShell Execution Policy Check: If PowerShell is running in restricted mode update the policy temporarily.
  # ==============================================================================================================================================
    #If((Get-ExecutionPolicy) -eq "Restricted"){
    #  Set-ExecutionPolicy Unrestricted -Scope Process -Force
    #}

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

  # ==============================================================================================================================================
  # Variable Declarations
  # ==============================================================================================================================================

    # ----------------------------------------------------------------------------------------------------------------------------------
    # Date/Time
    # ----------------------------------------------------------------------------------------------------------------------------------
      $CurrentDateTime   = Get-Date -format "yyyyMMdd_HHmm" 

    # ----------------------------------------------------------------------------------------------------------------------------------
    # Character Replacement
    # ----------------------------------------------------------------------------------------------------------------------------------
      $UnwantedCharacters = ':', '?', '/', '\', '|', '*', '<', '>', '"', '.', ' '                 #String of unwanted characters in the file name
      $CharactersToReplace = [string]::join('|', ($UnwantedCharacters | % {[regex]::escape($_)})) #Formats the $UnwantedCharacters string

    # ----------------------------------------------------------------------------------------------------------------------------------
    # Local Domain
    # ----------------------------------------------------------------------------------------------------------------------------------
      $LocalDomain  = (Get-WmiObject Win32_ComputerSystem).Domain
      $LocalDomain = $LocalDomain -replace $CharactersToReplace, '_'

    # ----------------------------------------------------------------------------------------------------------------------------------
    # Arrays
    # ----------------------------------------------------------------------------------------------------------------------------------
      $ResultsArray       = New-Object System.Collections.ArrayList                                                   # Output array Dupe Line 171

    # ----------------------------------------------------------------------------------------------------------------------------------
    # File paths and names
    # ----------------------------------------------------------------------------------------------------------------------------------
      Try{$PSScriptRoot}
      Catch{$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path}

      CD $PSScriptRoot                                                                                               # Change the path to the current directory from which this script is being executed

      $InputPath          = Join-Path $PSScriptRoot ("\Input\")                                                       # Input path

      $OutputPath         = Join-Path $PSScriptRoot ("\Output\")                                                      # Output path
      $OutputFile         = Join-Path $OutputPath ("$($LocalDomain)_ServerResults_$($CurrentDateTime).csv")           # Output file Dupe Line 178

      # --------------------------------------------------------------------------------------------------------------------------------
      # Create output directory if it does not exist
      # --------------------------------------------------------------------------------------------------------------------------------
        If (Test-Path -Path $OutputPath -PathType Container){
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
          Write-Host "The output directory $OutputPath already exists" -ForegroundColor DarkCyan
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
        }
        Else {
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
          Write-Host "Output folder has now been created." -ForegroundColor Red
          New-Item -Path $OutputPath -ItemType Directory
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
        }

#***************************************************************************************************************************************
<# COMMENTED OUT PATH
    # ----------------------------------------------------------------------------------------------------------------------------------
    # File paths and names
    # ----------------------------------------------------------------------------------------------------------------------------------
      Try{$PSScriptRoot}
      Catch{$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path}

      CD $PSScriptRoot                                                                                               # Change the path to the current directory from which this script is being executed
      
      $InputPath          = Join-Path $PSScriptRoot ("\Input\")                                                       # Input path

      $OutputPath         = Join-Path $PSScriptRoot ("\Output\")                                                      # Output path
      $OutputFile         = Join-Path $OutputPath ("$($LocalDomain)_ServerResults_$($CurrentDateTime).csv")           # Output file

      $LogFileTranscript  = Join-Path $OutputPath ("$($LocalDomain)_ServerCheck_Transcript_$($CurrentDateTime).txt")  # Log file transcript folder name

      $ResultsArray       = New-Object System.Collections.ArrayList                                                   # Output array

      # --------------------------------------------------------------------------------------------------------------------------------
      # Create input directory if it does not exist
      # --------------------------------------------------------------------------------------------------------------------------------
        If (Test-Path -Path $InputPath -PathType Container){
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

      # --------------------------------------------------------------------------------------------------------------------------------
      # Create output directory if it does not exist
      # --------------------------------------------------------------------------------------------------------------------------------
        If (Test-Path -Path $OutputPath -PathType Container){
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
          Write-Host "The output directory $OutputPath already exists" -ForegroundColor DarkCyan
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
        }
        Else {
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
          Write-Host "Output folder has now been created." -ForegroundColor Red
          New-Item -Path $OutputPath -ItemType Directory
          Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
        }
END COMMENTED OUT PATHS#> 

#***************************************************************************************************************************************

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
	  Write-Host `n; Write-Host "Select a TXT input file." -BackgroundColor Yellow -ForegroundColor Black
	
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
  # Get the servers to run against.
  # ==============================================================================================================================================

    # ------------------------------------------------------------------------------------------------------------------------------------
    # Server name list: get servers from the file
    # ------------------------------------------------------------------------------------------------------------------------------------

    $ServerList = Get-Content (Get-TXTinputFile -Title "server list")
   #$ServerList = 'pbnaaeidb001.wpd.envoy.net','qmemcfap009.na.webmd.net','CMSQLMON01.Corp.tc3health.com'

  # ==============================================================================================================================================
  # Start the transcript file
  # ==============================================================================================================================================
    #Try{Start-Transcript -Path $LogFileTranscript}Catch{Write-Host "Transcript files are not supported on this version of PowerShell."}

    #Clear-Host

  # ==============================================================================================================================================
  # Loop for each server in the file
  # ==============================================================================================================================================
    ForEach ($Server in $ServerList){ 

      Write-Host "`n-----------------------------------------------------------------------------------------------"

      # --------------------------------------------------------------------------------------------------------------------------------
      # Create the individual server array to be added to the overall list
      # --------------------------------------------------------------------------------------------------------------------------------
        $ResultArray = New-Object PSObject

      # --------------------------------------------------------------------------------------------------------------------------------
      # Remove spaces in the file
      # --------------------------------------------------------------------------------------------------------------------------------
        $Server = $Server.trim();
        $ResultArray | Add-Member -Type NoteProperty -Name "ServerName" -Value $Server -Force

        Write-Host "Checking: $Server`n"

      # --------------------------------------------------------------------------------------------------------------------------------
      # Check if the server is pingable
      # --------------------------------------------------------------------------------------------------------------------------------
        $ServerPingable = Test-Connection -computername $Server -Quiet

        Write-Host "`tServer Responds       : $ServerPingable"
        $ResultArray | Add-Member -Type NoteProperty -Name "ServerPingable" -Value $ServerPingable -Force

        If ($ServerPingable) {
            $Ping = Test-Connection -ComputerName $Server -Count 1 -ErrorAction SilentlyContinue
            Write-Host "`tIP Address            : "  -NoNewline -ForegroundColor Green
            Write-Host $Ping.IPV4Address
            $ResultArray | Add-Member -Type NoteProperty -Name "IP" -Value $Ping.IPV4Address -Force
            }
        Else {$ResultArray | Add-Member -Type NoteProperty -Name "IP" -Value "--" -Force}

<# COMMENTED OUT
      # --------------------------------------------------------------------------------------------------------------------------------
      # Check if port 135 is open/reachable
      # --------------------------------------------------------------------------------------------------------------------------------
        If($ServerPingable -eq $TRUE){
          $Port = 135
          $CheckPort135 = $NULL
          $Timeout = 5

          $connection = $NULL

          If (Get-Command Test-NetConnection -errorAction SilentlyContinue){

            $connection = TNC $Server -Port $Port
            $CheckPort135 = $connection.TcpTestSucceeded

            Write-Host  "`tChecking Port         : $Port"
            $ResultArray | Add-Member -Type NoteProperty -Name "Port135Open" -Value $CheckPort135 -Force

          }
          Else{

            Try {
              $tcp = New-Object System.Net.Sockets.TcpClient
              $connection = $tcp.BeginConnect($Server, $Port, $null, $null)
              $connection.AsyncWaitHandle.WaitOne($timeout,$false)  | Out-Null

              $CheckPort135 = $tcp.Connected
              $ResultArray | Add-Member -Type NoteProperty -Name "Port135Open" -Value $CheckPort135 -Force

              If($CheckPort135 -eq $true) {
                Write-Host  "`tSuccessfully connected to Host: $Server on Port: $Port" -ForegroundColor Green
              } 
              Else {
                Write-Host "`tCould not connect to Host: $Server on Port: $Port" -ForegroundColor Red
              }

            }
            Catch {
              Write-Host "`tUnknown Error" -ForegroundColor Red
            }
          }

        }
        Else{

          Write-Host "`tCould not connect to Host: $Server on Port: $Port" -ForegroundColor Red
          $ResultArray | Add-Member -Type NoteProperty -Name "Port135Open" -Value $False -Force

        }

      # --------------------------------------------------------------------------------------------------------------------------------
      # Process if server is online/reachable and port 135 is open
      # --------------------------------------------------------------------------------------------------------------------------------
        If($ServerPingable -eq $TRUE -AND $CheckPort135 -eq $TRUE){

          # ----------------------------------------------------------------------------------------------------------------------------
          # Check if user has access to WMI & Pull OS Information
          # ----------------------------------------------------------------------------------------------------------------------------
            $AccessGranted = $NULL
            $OSInfo = $NULL

            Try {

              $OSInfo = Get-WMIObject -class Win32_OperatingSystem -computername $Server | Select Caption, CSDVersion, OSArchitecture, Version

              If($OSInfo -ne $NULL) {

                $AccessGranted = $True

                Write-Host "`tOS                    : $($OSInfo.Caption)"
                Write-Host "`tService Pack          : $($OSInfo.CSDVersion)"
                Write-Host "`tArchitecture          : $($OSInfo.OSArchitecture)"
                Write-Host "`tVersion               : $($OSInfo.Version)"

                $ResultArray | Add-Member -Type NoteProperty -Name "OS" -Value $OSInfo.Caption -Force
                $ResultArray | Add-Member -Type NoteProperty -Name "OSServicePack" -Value $OSInfo.CSDVersion -Force
                $ResultArray | Add-Member -Type NoteProperty -Name "OSArchitecture" -Value $OSInfo.OSArchitecture -Force
                $ResultArray | Add-Member -Type NoteProperty -Name "OSVersion" -Value $OSInfo.Version -Force

              } 
              Else {

                $AccessGranted = $False

                Write-Host "`tAccess denied via WMI to: $Server" -ForegroundColor Red

                $ResultArray | Add-Member -Type NoteProperty -Name "OS" -Value "--" -Force
                $ResultArray | Add-Member -Type NoteProperty -Name "OSServicePack" -Value "--" -Force
                $ResultArray | Add-Member -Type NoteProperty -Name "OSArchitecture" -Value "--" -Force
                $ResultArray | Add-Member -Type NoteProperty -Name "OSVersion" -Value "--" -Force

              }
          
            }
            Catch {

              $WMI_Error = $_.Exception.Message
    
              If ($WMI_Error  -like '*Access*Denied*') {
                Write-Host "`tAccess Denied" -ForegroundColor Red
                $AccessGranted = $False
              }
              Else{
                Write-Host "`tUnknown Error         : $WMI_Error" -ForegroundColor Red
                $AccessGranted = $WMI_Error
              }

              $ResultArray | Add-Member -Type NoteProperty -Name "OS" -Value "--" -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "OSServicePack" -Value "--" -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "OSArchitecture" -Value "--" -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "OSVersion" -Value "--" -Force

            }

            $ResultArray | Add-Member -Type NoteProperty -Name "AccessGranted" -Value $AccessGranted -Force
            Write-Host "`tAccess Granted        : $AccessGranted"
                    
        }
        Else{
          Write-Host "`tSkipped Access Check for : $Server" -ForegroundColor Red
          
          $ResultArray | Add-Member -Type NoteProperty -Name "OS" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "OSServicePack" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "OSArchitecture" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "OSVersion" -Value "--" -Force

          $ResultArray | Add-Member -Type NoteProperty -Name "AccessGranted" -Value "Skipped Check" -Force

        }


      # --------------------------------------------------------------------------------------------------------------------------------
      # Process if server is online/reachable, port 135 is open and the user has access to query the server
      # --------------------------------------------------------------------------------------------------------------------------------
        If($ServerPingable -eq $TRUE -AND $CheckPort135 -eq $TRUE -AND $AccessGranted -eq $TRUE){

          # ----------------------------------------------------------------------------------------------------------------------------
          # Pull the System DNS Name
          # ----------------------------------------------------------------------------------------------------------------------------
            $ServerData = $NULL
            $ServerData=[System.Net.Dns]::GetHostByName("$Server")

            Write-Host "`tServer FQDN           : $($ServerData.HostName)"

            $ResultArray | Add-Member -Type NoteProperty -Name "ServerFQDN" -Value $ServerData.HostName -Force

          # ----------------------------------------------------------------------------------------------------------------------------
          # Pull DNS Information
          # ----------------------------------------------------------------------------------------------------------------------------
            $DNSInfo = $NULL
            $DNSInfo = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Server -ErrorAction Inquire  `
                       | Where{$_.IPEnabled -eq "TRUE"} `
                       | Select PSComputerName,IPAddress,DNSServerSearchOrder,`
                                @{L="IPs";E={$_.IPAddress -join "; "}},`
                                @{L="DNS_Servers";E={$_.DNSServerSearchOrder -join "; "}}

            $IPList = $NULL            
            $IPList = (($DNSInfo.IPAddress -join ';')| Out-String).Trim()
                        
            $DNSList = $NULL            
            $DNSList = (($DNSInfo.DNSServerSearchOrder -join ';')| Out-String).Trim()

            Write-Host "`tServer IP(s)          : $($DNSInfo.IPs)"
            Write-Host "`tDNS IPs               : $($DNSInfo.DNS_Servers)"
            Write-Host "`tDNS IPs               : $($DNSList)"

            
            #$ResultArray | Add-Member -Type NoteProperty -Name "ServerIPs" -Value $DNSInfo.IPs -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "ServerIPs" -Value $IPList -Force
            #$ResultArray | Add-Member -Type NoteProperty -Name "ServerDNSIPs" -Value $DNSInfo.DNS_Servers -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "ServerDNSIPs" -Value $DNSList -Force
            
          # ----------------------------------------------------------------------------------------------------------------------------      
          # Pull C drive Information
          # ----------------------------------------------------------------------------------------------------------------------------
            If(Test-Path "\\$($Server)\C$"){

              $DiskSpace_C = Get-WMIObject -class win32_logicaldisk -computername $Server | where {$_.DeviceID -match "C:"} | Select * #Select @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}}
              $DiskSpace_C_SizeGB = $NULL
              $DiskSpace_C_SizeGB = [math]::Round(($DiskSpace_C.Size /1gb),2)	
              $DiskSpace_C_FreeGB = $NULL
              $DiskSpace_C_FreeGB = [math]::Round(($DiskSpace_C.Freespace /1gb),2)

              Write-Host "`tDisk Space C Total    : $($DiskSpace_C_SizeGB) GB"
	          Write-Host "`tDisk Space C Free     : $($DiskSpace_C_FreeGB) GB"

              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_C_SizeGB" -Value $DiskSpace_C_SizeGB -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_C_FreeGB" -Value $DiskSpace_C_FreeGB -Force

            }
            Else{

              Write-Host "`tDisk Space C Total    : Inaccessible"
	          Write-Host "`tDisk Space C Free     : Inaccessible"

              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_C_SizeGB" -Value "Inaccessible" -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_C_FreeGB" -Value "Inaccessible" -Force

            }

          # ----------------------------------------------------------------------------------------------------------------------------
          # Pull D drive Information
          # ----------------------------------------------------------------------------------------------------------------------------
            If(Test-Path "\\$($Server)\D$"){

              $DiskSpace_D = Get-WMIObject -class win32_logicaldisk -computername $Server | where {$_.DeviceID -match "D:"} | Select *
              $DiskSpace_D_SizeGB = $NULL
              $DiskSpace_D_SizeGB = [math]::Round(($DiskSpace_D.Size /1gb),2)	
              $DiskSpace_D_FreeGB = $NULL
              $DiskSpace_D_FreeGB = [math]::Round(($DiskSpace_D.Freespace /1gb),2)

              Write-Host "`tDisk Space D Total    : $($DiskSpace_D_SizeGB) GB"
	          Write-Host "`tDisk Space D Free     : $($DiskSpace_D_FreeGB) GB"

              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_D_SizeGB" -Value $DiskSpace_D_SizeGB -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_D_FreeGB" -Value $DiskSpace_D_FreeGB -Force

            }
            Else{

              Write-Host "`tDisk Space D Total    : Inaccessible"
	          Write-Host "`tDisk Space D Free     : Inaccessible"

              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_D_SizeGB" -Value "Inaccessible" -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_D_FreeGB" -Value "Inaccessible" -Force

            }

          # ----------------------------------------------------------------------------------------------------------------------------
          # Pull E drive Information
          # ----------------------------------------------------------------------------------------------------------------------------
            If(Test-Path "\\$($Server)\E$"){

              $DiskSpace_E = Get-WMIObject -class win32_logicaldisk -computername $Server | where {$_.DeviceID -match "E:"} | Select *
              $DiskSpace_E_SizeGB = $NULL
              $DiskSpace_E_SizeGB = [math]::Round(($DiskSpace_E.Size /1gb),2)	
              $DiskSpace_E_FreeGB = $NULL
              $DiskSpace_E_FreeGB = [math]::Round(($DiskSpace_E.Freespace /1gb),2)

              Write-Host "`tDisk Space E Total    : $($DiskSpace_E_SizeGB) GB"
	          Write-Host "`tDisk Space E Free     : $($DiskSpace_E_FreeGB) GB"

              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_E_SizeGB" -Value $DiskSpace_E_SizeGB -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_E_FreeGB" -Value $DiskSpace_E_FreeGB -Force

            }
            Else{

              Write-Host "`tDisk Space E Total    : Inaccessible"
	          Write-Host "`tDisk Space E Free     : Inaccessible"

              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_E_SizeGB" -Value "Inaccessible" -Force
              $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_E_FreeGB" -Value "Inaccessible" -Force

            }

          # ----------------------------------------------------------------------------------------------------------------------------
          # Pull all physical drive info
          # ----------------------------------------------------------------------------------------------------------------------------
            $AllDiskInfo = $NULL

            $Drives = Get-WMIObject -class win32_logicaldisk -computername $Server | ?{$_.DriveType -eq 3} | Select @{L="DriveLetters";E={$_.DeviceID -join "; "}}

            $DriveList = $NULL
            $DriveList = (($Drives.DriveLetters -join ';') -replace $CharactersToReplace, '' | Out-String).Trim()

            Write-Host "`tDrive Letter List     : $DriveList"

            ForEach($Drive in $Drives.DriveLetters){
              
              $DiskSpace_Temp = $NULL
              $DiskSpace_Temp = Get-WMIObject -class win32_logicaldisk -computername $Server | where {$_.DeviceID -match $Drive} | Select *

              $DiskSpace_Temp_SizeGB = $NULL
              $DiskSpace_Temp_SizeGB = [math]::Round(($DiskSpace_Temp.Size /1gb),2)	
              $DiskSpace_Temp_FreeGB = $NULL
              $DiskSpace_Temp_FreeGB = [math]::Round(($DiskSpace_Temp.Freespace /1gb),2)

              $DiskSpace_Temp = "$($Drive) (Total: $($DiskSpace_Temp_SizeGB) GB | Free: $($DiskSpace_Temp_FreeGB) GB)"
              
	          $AllDiskInfo += $DiskSpace_Temp+"; "
 
            }

            $ResultArray | Add-Member -Type NoteProperty -Name "PhysicalDriveData" -Value $AllDiskInfo -Force

          # ----------------------------------------------------------------------------------------------------------------------------
          # Check the System Type
          # ----------------------------------------------------------------------------------------------------------------------------
            $ServerType = Get-WMIObject -class win32_computersystem -computername $Server `
                          | Select Domain, Manufacturer, Model, PartOfDomain, Workgroup, DomainRole, NumberOfLogicalProcessors, NumberOfProcessors, TotalPhysicalMemory

            $RAM_GB = $NULL
            $RAM_GB = [math]::Round(($ServerType.TotalPhysicalMemory /1gb),2)

            $ServerRole = switch($ServerType.DomainRole){
              0 {"Standalone Workstation"}
              1 {"Member Workstation"}
              2 {"Standalone Server"}
              3 {"Member Server"}
              4 {"Backup Domain Controller"}
              5 {"Primary Domain Controller"}
              default {"Unknown"}
            }

            If($ServerType.DomainRole -eq 4 -or $ServerType.DomainRole -eq 5){
              $IsDomainController = "Yes"
            }
            Else{
              $IsDomainController = "No"
            }

            Write-Host "`tManufacturer          : $($ServerType.Manufacturer)"
            Write-Host "`tModel                 : $($ServerType.Model)"
            Write-Host "`tPartOfDomain          : $($ServerType.PartOfDomain)"
            Write-Host "`tDomain                : $($ServerType.Domain)"
            Write-Host "`tWorkgroup             : $($ServerType.Workgroup)"
            Write-Host "`tDomain Controller     : $IsDomainController"
            Write-Host "`tDomain Role           : $ServerRole"
            Write-Host "`tLogical CPUs          : $($ServerType.NumberOfLogicalProcessors)"
            Write-Host "`tCPUs                  : $($ServerType.NumberOfProcessors)"
            Write-Host "`tTotal RAM             : $RAM_GB"

            $ResultArray | Add-Member -Type NoteProperty -Name "Manufacturer" -Value $ServerType.Manufacturer -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "Model" -Value $ServerType.Model -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "DomainMember" -Value $ServerType.PartOfDomain -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "Domain" -Value $ServerType.Domain -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "Workgroup" -Value $ServerType.Workgroup -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "DomainController" -Value $IsDomainController -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "DomainRole" -Value $ServerRole -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "LogicalCPUs" -Value $ServerType.NumberOfLogicalProcessors -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "CPUs" -Value $ServerType.NumberOfProcessors -Force
            $ResultArray | Add-Member -Type NoteProperty -Name "TotalRAMGB" -Value $RAM_GB -Force

          # ----------------------------------------------------------------------------------------------------------------------------
          # Check if the Server is Citrix Related
          #    Uses services to check instead of "(Get-WmiObject -Class Win32_product -Filter "name LIKE 'vmware%'" | Select Caption,Version)"
          # ----------------------------------------------------------------------------------------------------------------------------
            $CitrixRelated = $NULL
            $CitrixRelated = (Get-Service -Computer $Server -Name 'BrokerAgent' -ErrorAction SilentlyContinue) | Select Status 
            If($CitrixRelated -ne $NULL){
              $CitrixRelated = "Yes"
            }
            Else{
              $CitrixRelated = "No"
            }

            Write-Host "`tCitrix Related        : $CitrixRelated"

            $ResultArray | Add-Member -Type NoteProperty -Name "CitrixRelated" -Value $CitrixRelated -Force
            
          # ----------------------------------------------------------------------------------------------------------------------------
          # Check if the Server Has IIS Installed
          # ----------------------------------------------------------------------------------------------------------------------------
            $IISInstalled = $NULL
            $IISInstalled = (Get-Service -Computer $Server -Name 'IISADMIN' -ErrorAction SilentlyContinue) | Select Status 
            If($IISInstalled -ne $NULL){
              $IISInstalled = "Yes"
            }
            Else{
              $IISInstalled = "No"
            }

            Write-Host "`tIIS Installed         : $IISInstalled"

            $ResultArray | Add-Member -Type NoteProperty -Name "IISInstalled" -Value $IISInstalled -Force
            
          # ----------------------------------------------------------------------------------------------------------------------------
          # Check if the Server is VMHorizon Related
          #   Uses services to check instead of "(Get-WmiObject -Class Win32_product -Filter "name LIKE 'xen%'" | Select Caption,Version)"
          #
          #   WSNM = "VMware Horizon View Agent" Service, was producing false negatives in the Citrix environment.
          #   VMBlast = "VMware Blast Properties" Service
          # ----------------------------------------------------------------------------------------------------------------------------
            $VMHorizonRelated = $NULL
            $VMHorizonRelated = (Get-Service -Computer $Server -Name 'VMBlast' -ErrorAction SilentlyContinue) | Select Status 
            If($VMHorizonRelated -ne $NULL){
              $VMHorizonRelated = "Yes"
            }
            Else{
              $VMHorizonRelated = "No"
            }

            Write-Host "`tVMHorizon Related     : $VMHorizonRelated"

            $ResultArray | Add-Member -Type NoteProperty -Name "VMHorizonRelated" -Value $VMHorizonRelated -Force

          # ----------------------------------------------------------------------------------------------------------------------------
          # Check if the Server has RDS Gateway Installed
          #   TSGateway = "Remote Desktop Gateway" Service
          # ----------------------------------------------------------------------------------------------------------------------------
            $TSGatewayInstalled = $NULL
            $TSGatewayInstalled = (Get-Service -Computer $Server -Name 'WSNM' -ErrorAction SilentlyContinue) | Select Status 
            If($TSGatewayInstalled -ne $NULL){
              $TSGatewayInstalled = "Yes"
            }
            Else{
              $TSGatewayInstalled = "No"
            }

            Write-Host "`tRDS Gateway Installed : $TSGatewayInstalled"

            $ResultArray | Add-Member -Type NoteProperty -Name "TSGatewayInstalled" -Value $TSGatewayInstalled -Force
                        
          # ----------------------------------------------------------------------------------------------------------------------------
          # Pull the PowerShell Version Information
          # ----------------------------------------------------------------------------------------------------------------------------
            $RegHive = [Microsoft.Win32.RegistryHive]“LocalMachine”;
            $RegKey  = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegHive,$Server);

            If(($RegKey.OpenSubKey(“SOFTWARE\Microsoft\Powershell\3\PowerShellEngine”)) -ne $NULL){
              $PSRegValues       = $RegKey.OpenSubKey(“SOFTWARE\Microsoft\Powershell\3\PowerShellEngine”);
              $PSVersion         = $PSRegValues.GetValue("PowerShellVersion")
              $PSRunTimeVersion  = $PSRegValues.GetValue("RunTimeVersion")
            }
            ElseIf(($RegKey.OpenSubKey(“SOFTWARE\Microsoft\Powershell\1\PowerShellEngine”)) -ne $NULL){
              $PSRegValues       = $RegKey.OpenSubKey(“SOFTWARE\Microsoft\Powershell\1\PowerShellEngine”);
              $PSVersion         = $PSRegValues.GetValue("PowerShellVersion")
              $PSRunTimeVersion  = $PSRegValues.GetValue("RunTimeVersion")
            }
            Else{
              $PSRegValues       = $NULL
              $PSVersion         = "Not Installed"
              $PSRunTimeVersion  = "Not Installed"
            }

             Write-Host "`tPowerShell Version    : $($PSVersion)"
             Write-Host "`tPowerShell Runtime    : $($PSRunTimeVersion)"

             $ResultArray | Add-Member -Type NoteProperty -Name "PSVersion" -Value $PSVersion -Force
             $ResultArray | Add-Member -Type NoteProperty -Name "PSRunTimeVersion" -Value $PSRunTimeVersion -Force
             
          # ----------------------------------------------------------------------------------------------------------------------------
          # Pull the RDS Licensing Server Config
          # ----------------------------------------------------------------------------------------------------------------------------
            If(($RegKey.OpenSubKey(“SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers”)) -ne $NULL){
              $RDSRegValues       = $RegKey.OpenSubKey(“SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers”);
              $RDSLicenseServer   = ($RDSRegValues.GetValue("SpecifiedLicenseServers") -join ";")
              $RDSServer          = "Yes"
            }
            Else{
              $RDSRegValues       = $NULL
              $RDSLicenseServer   = "Not Installed"
              $RDSServer          = "No"
            }

             Write-Host "`tRDS License Server    : $($RDSLicenseServer)"
             Write-Host "`tRDS Server            : $($RDSServer)"

             $ResultArray | Add-Member -Type NoteProperty -Name "RDSLicenseServer" -Value $RDSLicenseServer -Force
             $ResultArray | Add-Member -Type NoteProperty -Name "RDSServer" -Value $RDSServer -Force

             $RegKey.Close()

        }
        Else{
          Write-Host "`t$Server is not online/reachable!" -ForegroundColor Red
          $ResultArray | Add-Member -Type NoteProperty -Name "ServerFQDN" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "ServerIPs" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "ServerDNSIPs" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_C_SizeGB" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_C_FreeGB" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_D_SizeGB" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_D_FreeGB" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_E_SizeGB" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DiskSpace_E_FreeGB" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "PhysicalDriveData" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "Manufacturer" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "Model" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DomainMember" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "Domain" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "Workgroup" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DomainController" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "DomainRole" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "LogicalCPUs" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "CPUs" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "TotalRAMGB" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "CitrixRelated" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "IISInstalled" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "VMHorizonRelated" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "TSGatewayInstalled" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "PSVersion" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "PSRunTimeVersion" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "RDSLicenseServer" -Value "--" -Force
          $ResultArray | Add-Member -Type NoteProperty -Name "RDSServer" -Value "--" -Force
        }

COMMENTED OUT #>

      # --------------------------------------------------------------------------------------------------------------------------------
      # Record the end of the server check and write the data to the log
      # --------------------------------------------------------------------------------------------------------------------------------
        $ResultArray | Add-Member -Type NoteProperty -Name "CheckedDateTime" -Value $(Get-Date -format "MM-dd-yyyy HH:mm:ss") -Force
        $0 = $ResultsArray.Add($ResultArray)

    }

    Write-Host "-----------------------------------------------------------------------------------------------"
    

    # ============================================================================================================================================
    # Export the results to a csv file
    # ============================================================================================================================================
      $ResultsArray | Export-CSV -Path $OutputFile -NoTypeInformation
      Write-Host "  Results saved to: $OutputFile" -ForegroundColor Green

#      $ResultsArray | ft -Wrap

<# COMMENTED OUT
      Write-Host "******************************************************************************************************************************" -ForegroundColor Green
      Write-Host "******************************************************************************************************************************" -ForegroundColor Green
      Write-Host "                                                                                                                              " -ForegroundColor Green
      Write-Host "  Finished processing the script...                                                                                           " -ForegroundColor Green
      Write-Host "                                                                                                                              " -ForegroundColor Green
      Write-Host "  Results saved to: $OutputFile                                                                                               " -ForegroundColor Green
      Write-Host "                                                                                                                              " -ForegroundColor Green
#      Write-Host "  Log file save to: $LogFileTranscript                                                                                        " -ForegroundColor Green
      Write-Host "                                                                                                                              " -ForegroundColor Green
      Write-Host "******************************************************************************************************************************" -ForegroundColor Green
      Write-Host "******************************************************************************************************************************" -ForegroundColor Green
  
#>
############################################################################################################################################################
## *********************************************************************************************************************************************************
##                                           _____ _      ______          _   _ _    _ _____  
##                                          / ____| |    |  ____|   /\   | \ | | |  | |  __ \ 
##                                         | |    | |    | |__     /  \  |  \| | |  | | |__) |
##                                         | |    | |    |  __|   / /\ \ | . ` | |  | |  ___/ 
##                                         | |____| |____| |____ / ____ \| |\  | |__| | |     
##                                          \_____|______|______/_/    \_\_| \_|\____/|_|  
##
## *********************************************************************************************************************************************************
############################################################################################################################################################

  # ==============================================================================================================================================
  # Close the transcript file
  # ==============================================================================================================================================
    #Stop-Transcript
#    Try{Stop-Transcript}Catch{Write-Host ""}