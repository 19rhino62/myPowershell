#$ServerList = $env:COMPUTERNAME
$ServerList = 'zbnaaeex001.corporate.healthcareit.net'
#$ServerList = 'DMEMCFDB501.development.webmd.net'

$DNSSettings = @()

#$Creds = (Get-Credential)

foreach ($server in $ServerList){
    $server = $server.Trim()
    Write-Progress -Status "Checking DNS Settings on $server" -Activity "Gathering Data"

    $DNSInfo = New-Object psObject

#   Get-DnsClientServerAddress
#    $DNSServers = gwmi -q "select * from win32_networkadapterconfiguration where ipenabled='true'" -ComputerName $server | where {$_.DNSServerSearchOrder -ne $null} | select PSComputerName, DNSServerSearchOrder
#    gwmi -q "select * from win32_networkadapterconfiguration where ipenabled='true'" -ComputerName . | where {$_.DNSServerSearchOrder -ne $null} | select PSComputerName, DNSServerSearchOrder, DNSDomainSuffixSearchOrder
#    $NetItems = gwmi -q "select * from win32_networkadapterconfiguration where ipenabled='true'" -ComputerName $server -Credential $Creds | where {$_.DNSServerSearchOrder -ne $null}
    $NetItems = gwmi -q "select * from win32_networkadapterconfiguration where ipenabled='true'" -ComputerName $server | where {$_.DNSServerSearchOrder -ne $null}
    if ($NetItems) {
        [string]$DNSSO = @()
        foreach ($DNSSOItem in $NetItems){
            if ($DNSSOItem.{DNSServerSearchOrder}.Count -gt 1){
                $TempDNSSO = [string]$DNSSOItem.DNSServerSearchOrder
                $TempDNSSO = $TempDNSSO.Replace(" ", "`n")
#            $DNS += $TempDNSAddresses +"`n"
                $DNSSO += $TempDNSSO +"`n"
            #break;
            }
            else{$DNSSO += $DNSSOItem.{DNSServerSearchOrder} +"`n"}

            }
            $DNSInfo | Add-Member -Type NoteProperty -Name "ServerName" -Value $server -Force
            $DNSInfo | Add-Member -Type NoteProperty -Name "DNS Server Search Order" -Value $DNSSO -Force
            } 
    else {
        Write-Warning "The RPC server is unavailable"
        $DNSInfo | Add-Member -Type NoteProperty -Name "ServerName" -Value $server -Force
        $DNSInfo | Add-Member -Type NoteProperty -Name "DNS Server Search Order" -Value "NA" -Force
        }
#        $DNSInfo | Add-Member -Type NoteProperty -Name "DNS Server Suffix" -Value DNSDomainSuffixSearchOrder
        $DNSSettings += $DNSInfo
} # END FOR

$DNSSettings | fl *

#Validation
#gwmi -q "select * from win32_networkadapterconfiguration where ipenabled='true'" -ComputerName . | where {$_.DNSServerSearchOrder -ne $null} | select PSComputerName, DNSServerSearchOrder, DNSDomainSuffixSearchOrder
 