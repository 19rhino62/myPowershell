############################################################################################################################################################
## *********************************************************************************************************************************************************
## 
## Title: PS-NSLOOKUP.PS1
## Author: Wayne Morrison
## Purpose: From shortname or HOSTNAME input, searches DNS using FQDN in ALL domains.
##
##.INPUT
## Input file should only contain a single servers FQDN per line with no spaces.
##
##    Example:
##              pbnaaeap001
##
##.OUTPUT
## 
## This script will scan a single server or a list of servers (text file) in DNS.
##	Successful
##	FQDN Returned: PAUGCDDB006.ghsinc.com
##	IP Returned: 10.0.0.167
##	Domain Returned: ghsinc.com
##	Access Type Returned: IIQ
##	Contraint Status Returned: US Constraint
##
##	 .\PS-NSLOOKUP-20200625_153248_serverlist.csv was logged
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
## 4/29/20     Created the script.                                                                                                        Wayne Morrison
## 7/16/20     Added progress bar.                                                                                                        Wayne Morrison
## 7/22/2020   Fixed multiple entries                                                                                                     Wayne Morrison
##
## *********************************************************************************************************************************************************
############################################################################################################################################################

  # ==============================================================================================================================================
  # Clear the screen
  # ==============================================================================================================================================
#    CLS

    
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

###################### EXECUTION POLICY #######################
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Confirm
#$shell = New-Object -ComObject Wscript.Shell
#Set-ExecutionPolicy Unrestricted | echo $shell.sendkeys("Y`r`n")

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

#$DNSDomains = @('adminisource.com','altegrahealth.local','ca.erxnetwork.com','capario.com','ce-a.intra','cloud.development.webmd.net','commad.pbm','corporate.healthcareit.net','cpd.emdeon.net','dcmalchemy.com','dev.healthcareit.net','development.webmd.net','DTSRV.LOCAL','ebprod.emdeon.com','gdd.emdeon.net','emdeon.net','emdeonpharmacy.com','erxnetwork.com','fpd2.healthcareit.net','ghsinc.com','gpd.emdeon.net','gwe.webmd.net','hq.fvtech.com','Humana-altegra.com','Humana-test.com','idcs.emdeon.net','interpaynet.com','m3client.net','m3net.net','mckesson.com','mhsdev.local','MHSPROD.local','na.webmd.net','ohis-dev.com','ohis-encrypt.com','outcomes.dom','pad.emdeon.net','pcloud.wpd.envoy.net','pgov.changehealthcare.com','prod.healthcareit.net','proxymed.com','resource.emdeon.net','sscincorporated.com','ts.fvtech.com','tsh.mis.mckesson.com','ucce.priv','webmd.net','wpd.envoy.net','backup.net','none')

#added unix zone
$Report = ""
$DNSDomains = @('adminisource.com','altegrahealth.local','ca.erxnetwork.com','capario.com','ce-a.intra','cloud.development.webmd.net','commad.pbm','corporate.healthcareit.net','cpd.emdeon.net','dcmalchemy.com','dev.healthcareit.net','development.webmd.net','DTSRV.LOCAL','ebprod.emdeon.com','gdd.emdeon.net','emdeon.net','emdeonpharmacy.com','erxnetwork.com','fpd2.healthcareit.net','ghsinc.com','gpd.emdeon.net','gwe.webmd.net','hq.fvtech.com','Humana-altegra.com','Humana-test.com','idcs.emdeon.net','interpaynet.com','m3client.net','m3net.net','mckesson.com','mhsdev.local','MHSPROD.local','na.webmd.net','ohis-dev.com','ohis-encrypt.com','outcomes.dom','pad.emdeon.net','pcloud.wpd.envoy.net','pgov.changehealthcare.com','prod.healthcareit.net','proxymed.com','resource.emdeon.net','sscincorporated.com','ts.fvtech.com','tsh.mis.mckesson.com','ucce.priv','webmd.net','wpd.envoy.net','backup.net','idcs.emdeon.net','emdeon.net','none')

#Enter Server or choose file
#.INPUTS HOSTNAME/SELECT FILE
$ServerList = Read-Host -Prompt 'Type in HOSTNAME or <ENTER> to open a file'

##======================================================================================================================================================
## Set up progress bar
##======================================================================================================================================================
## $i=1
## $total = $ServerList.count
##======================================================================================================================================================

$ResultsArray = @()

#Select File Input
If(-not $ServerList) {
    $ServerList = Get-Content (Get-TXTinputFile)
    Write-Host `n`n
    }

ForEach ($Server in $ServerList) {

##======================================================================================================================================================
## Set up progress bar
##======================================================================================================================================================
# $i++
# $status = "{0:N0}" -f ($i / $total * 100)
# Write-Progress -Activity "Gathering DNS on $server" -status "Processing Server $i of $total : $status% Completed" -PercentComplete ($i / $total * 100)
##======================================================================================================================================================

# To do - allow for IP input
        ForEach($Domain in $DNSDomains){
#            Write-Host "`nChecking DNS in: $Domain for $Server" -ForegroundColor DarkGray
            $NSLOOKUP = $NULL

#           Remove spaces on server name
            $Server = $Server.trim();

            $FQDNServerName = $Server+"."+$Domain

            Try{$NSLOOKUP = @(Resolve-DnsName $FQDNServerName  -DnsOnly -QuickTimeout -ErrorAction SilentlyContinue)}
            Catch{$NSLOOKUP = $NULL}

            If($NSLOOKUP -ne $NULL){

  # ==============================================================================================================================================
  # 
  # Check Server Name and IP for Multiple entries
  # 
  # ==============================================================================================================================================

#        $NetItems = @(Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" -ComputerName $StrComputer @PSBoundParameters)
        $NetItems = @(Resolve-DnsName $FQDNServerName -DnsOnly -QuickTimeout -ErrorAction SilentlyContinue) #@PSBoundParameters)
        $intRowNet = 0
#        $ServerObj | Add-Member -MemberType NoteProperty -Name "NIC's" -Value $NetItems.Length -Force
        [STRING]$Names = @()
        [STRING]$IpAddresses = @()

        foreach ($objItem in $NetItems){
# Multiple Device Names
            if ($objItem.{Name}.Count -gt 1){
                $TempNames = [STRING]$objItem.Name
                $TempNames = $TempNames.Replace(" ", " ; ")
                $Names += $TempNames +"; "
            }
            else{
                $Names += $objItem.{Name} +"; "
            }
# Multiple IP Addresses
            if ($objItem.IPAddress.Count -gt 1){
                $TempIpAddresses = [STRING]$objItem.IPAddress
                $TempIpAddresses  = $TempIpAddresses.Trim().Replace(" ", " ; ")
                $IpAddresses += $TempIpAddresses
            }
            else{
                $IpAddresses += $objItem.IPAddress +"; "
        } #END FOR MULTIPLE SUBARRAY
        $intRowNet = $intRowNet + 1
    }
  # ==============================================================================================================================================
  # 
  # FIND DOMAIN
  # 
  # =========================================================================================================================

#================ US Constraint Domains ==============================
            switch ($Domain) {
                
                altegrahealth.local {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                DTSRV.LOCAL {$Constraint = "US Constraint (DOD)";break}
                EMDEONPHARMACY.COM {$Constraint = "US Constraint (DOD)";break}
                fpd2.healthcareit.net {$Constraint = "US Constraint (RSA Token)";$AccessType = "IIQ";break}
                gdd.emdeon.net {$Constraint = "US Constraint";$AccessType = "IIQ";break}
                ghsinc.com {$Constraint = "US Constraint";$AccessType = "IIQ";break}
                gpd.emdeon.net {$Constraint = "US Constraint";$AccessType = "IIQ";break}
                humana-altegra.com {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                humana-test.com {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                m3client.net {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                m3net.net {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                mhsdev.local {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                MHSPROD.local {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                MHSVAULT.LOCAL {$Constraint = "US Constraint";$AccessType = "Decommissioned";break}
                ohis-dev.com {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                ohis-encrypt.com {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                outcomes.dom {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                pgov.changehealthcare.com {$Constraint = "US Constraint";$AccessType = "IIQ";break}
                sscincorporated.com {$Constraint = "US Constraint";$AccessType = "IIQ";break}
                tsh.mis.mckesson.com {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                ucce.priv {$Constraint = "US Constraint";$AccessType = "ITOPS";break}
                qa.ad.tc3health.com {$Constraint = "US Constraint (AWS)";$AccessType = "IIQ";break}
                dev.ad.tc3health.com {$Constraint = "US Constraint (AWS)";$AccessType = "IIQ";break}

#================ Non - Constraint Domains ====================================
                adminisource.com {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                cpd.emdeon.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                corporate.healthcareit.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                commad.pbm {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                gwe.webmd.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                dcmalchemy.com {$Constraint = "Non-Constraint (DOD)";break}
                dev.healthcareit.net {$Constraint = "Non-Constraint (DOD)";break}
                erxnetwork.com {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                hq.fvtech.com {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                interpaynet.com {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                na.webmd.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                pad.emdeon.net {$Constraint = "Non-Constraint (RSA Token)";$AccessType = "IIQ";break}
                ppd.emdeon.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                prod.healthcareit.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                proxymed.com {$Constraint = "Non-Constraint";$AccessType = "Horizon Client";break}
                resource.emdeon.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                #test.fvtech.com {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                ts.fvtech.com {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                webmd.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                wpd.envoy.net {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}
                na.webmd.net  {$Constraint = "Non-Constraint";$AccessType = "IIQ";break}

#================ Misc/Non-Supported Domains ==============================
                tc3health.com {$Constraint = "AWS";break}
                idcs.emdeon.net {$Constraint = "Paras Kapoor";break}
                las.capario.com {$Constraint = "OOS";break}
                mcp-services.net {$Constraint = "OOS";break}
                oam.capario.com {$Constraint = "OOS";break}
                prod.dakotaimaging.com {$Constraint = "OOS";break}
                prodcloud.wpd.envoy.net {$Constraint = "OOS";break}
                dsa.int {$Constraint = "OOS";break}                }
#==========================================================================

#=================================== OUTPUT EACH SERVER TO SCREEN ===========================================================
                Write-Host "`n`tDNS Search Successful" -ForegroundColor Green
                Write-Host "`tFQDN Returned: " -NoNewline -ForegroundColor Green
#                Write-Host $NSLOOKUP.Name
                Write-Host $Names
                Write-Host "`tIP Returned: " -NoNewline -ForegroundColor Green
#                Write-Host $NSLOOKUP.IP4Address
                Write-Host $IpAddresses
                Write-Host "`tDomain Returned: " -NoNewline -ForegroundColor Green
                Write-Host $Domain
                Write-Host "`tAccess Type Returned: " -NoNewline -ForegroundColor Green
                Write-Host $AccessType
                Write-Host "`tContraint Status Returned: " -NoNewline -ForegroundColor Green
                Write-Host $Constraint

                $DomainArray = New-Object PSObject
                $DomainArray | Add-Member -Type NoteProperty -Name "HostName" -Value $server -Force
#                $DomainArray | Add-Member -Type NoteProperty -Name "FQDN" -Value $NSLOOKUP.Name -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "FQDN" -Value $Names -Force
#                $DomainArray | Add-Member -Type NoteProperty -Name "IPv4" -Value $NSLOOKUP.IP4Address -Force

# If IPAddress = 173.247.66.250, Out of Service
                $DomainArray | Add-Member -Type NoteProperty -Name "IPv4" -Value $IpAddresses -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "Domain" -Value $Domain -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "Access Type" -Value $AccessType -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "Constraint" -Value $Constraint -Force

                #============================================================================================================

                $ResultsArray += $DomainArray

            #Found Domain, Next Server
                Break
            }

            #============================================================================================================

            If ($Domain -eq 'none') {
                Write-Host "`n`tError: " -NoNewline -ForegroundColor Red
                Write-Host "No domain found" -ForegroundColor White

                $DomainArray | Add-Member -Type NoteProperty -Name "HostName" -Value $server -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "FQDN" -Value "NA" -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "IPv4" -Value "NA" -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "Domain" -Value "NA" -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "Access Type" -Value "NA" -Force
                $DomainArray | Add-Member -Type NoteProperty -Name "Constraint" -Value "NA" -Force

                #$ResultsArray += $DomainArray
            #============================================================================================================

            }
        }

}

$Report = Read-Host "`n`tWould you like to log a report? (Y/N) <ENTER-No>"

Switch ($Report) {
    "" {If ($ResultsArray) {$ResultsArray};break}
    N {If ($ResultsArray) {$ResultsArray};break}
    No {If ($ResultsArray) {$ResultsArray};break}
    n {If ($ResultsArray) {$ResultsArray};break}
    Y {If ($ResultsArray) {
        $ResultsArray | Export-Csv ".\NSLOOKUP_$((Get-Date).ToString("yyyyMMdd_HHmmss"))_serverlist.csv" -NoTypeInformation
        Write-Host "`n`t .\NSLOOKUP_$((Get-Date).ToString("yyyyMMdd_HHmmss"))_serverlist.csv was logged`n" -ForegroundColor Yellow}}
    Yes {If ($ResultsArray) {
        $ResultsArray | Export-Csv ".\NSLOOKUP_$((Get-Date).ToString("yyyyMMdd_HHmmss"))_serverlist.csv" -NoTypeInformation
        Write-Host "`n`t .\NSLOOKUP_$((Get-Date).ToString("yyyyMMdd_HHmmss"))_serverlist.csv was logged`n" -ForegroundColor Yellow}}
    }

If (-not $ResultsArray) {Write-Warning "No DNS record found"}