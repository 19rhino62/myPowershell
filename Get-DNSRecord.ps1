#After saving the script, run it in PowerShell by calling its name GetDnsRecord.ps1. The demonstration below shows the output.
#.LINK https://adamtheautomator.com/resolve-dnsname/#ResolveDnsName_The_PowerShell_DNS_Resolver

$NameList = @('adamtheautomator.com','powershell.org','xyz.local')
$ServerList = @('8.8.8.8','8.8.4.4')

$FinalResult = @()
foreach ($Name in $NameList) {
    $tempObj = "" | Select-Object Name,IPAddress,Status,ErrorMessage    
    try {        $dnsRecord = Resolve-DnsName $Name -Server $ServerList -ErrorAction Stop | Where-Object {$_.Type -eq 'A'}        
    $tempObj.Name = $Name        
    $tempObj.IPAddress = ($dnsRecord.IPAddress -join ',')        
    $tempObj.Status = 'OK'        
    $tempObj.ErrorMessage = ''    }    
    catch {        
    $tempObj.Name = $Name        
    $tempObj.IPAddress = ''        
    $tempObj.Status = 'NOT_OK'        
    $tempObj.ErrorMessage = $_.Exception.Message    }    
    $FinalResult += $tempObj}
    return $FinalResult

#.\GetDnsRecord.ps1 | Export-Csv DnsRecord.csv -NoTypeInformation

