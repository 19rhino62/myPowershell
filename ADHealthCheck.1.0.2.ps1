﻿############################################################################# 
#       Author: Vikas Sukhija 
#       Reviewer:     
#       Date: 12/25/2014 
#       Satus: Ping,Netlogon,NTDS,DNS,DCdiag Test(Replication,sysvol,Services) 
#       Description: AD Health Status 
############################################################################# 
#
#.LINKS
#   https://github.com/VikasSukhija/Downloads/blob/master/ADHealthCheck.zip
#   https://gallery.technet.microsoft.com/scriptcenter/Active-Directory-Health-709336cd
#
###########################Define Variables################################## 
 
# --------------------------------------------------------------------------------------------------------------------------------
# Create Scripts directory if it does not exist 09/02/2020 wjm
# --------------------------------------------------------------------------------------------------------------------------------

#$ScriptsPath = 'C:\Users\wmorrison_admin\Documents\'
#$reportpath = 'C:\Users\wmorrison_admin\Documents\ADReport.htm'


$ScriptsPath = 'C:\Scripts\'
$reportpath = 'C:\Scripts\ADReport.htm'
 
If (Test-Path -Path $ScriptsPath -PathType Container){
    Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "The input directory $ScriptsPath already exists" -ForegroundColor DarkGray
    Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkCyan
    }
Else {
    Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
    Write-Host "$ScriptsPath folder has now been created." -ForegroundColor Red
    New-Item -Path $ScriptsPath -ItemType Directory
    Write-Host "--------------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Red
    }

CD $ScriptsPath

# --------------------------------------------------------------------------------------------------------------------------------
# Create New ADReport every time
# --------------------------------------------------------------------------------------------------------------------------------
If (Test-Path -Path $reportpath) {
    Remove-Item $reportpath -ErrorAction SilentlyContinue
   }
If (-not(Test-Path -Path $reportpath)) {
    new-item $reportpath -type file -ErrorAction SilentlyContinue
    }

# --------------------------------------------------------------------------------------------------------------------------------
# MAKE CHANGES HERE
# --------------------------------------------------------------------------------------------------------------------------------

$smtphost = "RELAYER.EMDEON.NET"
#$smtphost = "ddcmail.mckesson.com"
$from = "DoNotReply@changehealthcare.com"  
$to = "ITOps-WindowsSupport-Onshore@changehealthcare.com"
#$to = "Wintel-Wipro-offshore@changehealthcare.com,ITOps-WindowsSupport-Onshore@changehealthcare.com"
#$to = "bill.white@changehealthcare.com,jill.irving@changehealthcare.com,ITOps-WindowsSupport-Onshore@changehealthcare.com"
#$to = "wayne.morrison@changehealthcare.com" 
$timeout = "60" 
 
###############################HTml Report Content############################ 
$report = $reportpath 
 
Clear-Content $report  
Add-Content $report "<html>"  
Add-Content $report "<head>"  
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"  
Add-Content $report '<title>Exchange Status Report</title>'  
add-content $report '<STYLE TYPE="text/css">'  
add-content $report  "<!--"  
add-content $report  "td {"  
add-content $report  "font-family: Tahoma;"  
add-content $report  "font-size: 11px;"  
add-content $report  "border-top: 1px solid #999999;"  
add-content $report  "border-right: 1px solid #999999;"  
add-content $report  "border-bottom: 1px solid #999999;"  
add-content $report  "border-left: 1px solid #999999;"  
add-content $report  "padding-top: 0px;"  
add-content $report  "padding-right: 0px;"  
add-content $report  "padding-bottom: 0px;"  
add-content $report  "padding-left: 0px;"  
add-content $report  "}"  
add-content $report  "body {"  
add-content $report  "margin-left: 5px;"  
add-content $report  "margin-top: 5px;"  
add-content $report  "margin-right: 0px;"  
add-content $report  "margin-bottom: 10px;"  
add-content $report  ""  
add-content $report  "table {"  
add-content $report  "border: thin solid #000000;"  
add-content $report  "}"  
add-content $report  "-->"  
add-content $report  "</style>"  
Add-Content $report "</head>"  
Add-Content $report "<body>"  
add-content $report  "<table width='100%'>"  
add-content $report  "<tr bgcolor='Lavender'>"  
add-content $report  "<td colspan='7' height='25' align='center'>"  
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Active Directory Health Check</strong></font>"  
add-content $report  "</td>"  
add-content $report  "</tr>"  
add-content $report  "</table>"  
  
add-content $report  "<table width='100%'>"  
Add-Content $report  "<tr bgcolor='IndianRed'>"  
Add-Content $report  "<td width='5%' align='center'><B>Identity</B></td>"  
Add-Content $report  "<td width='10%' align='center'><B>PingSTatus</B></td>"  
Add-Content $report  "<td width='10%' align='center'><B>NetlogonService</B></td>"  
Add-Content $report  "<td width='10%' align='center'><B>NTDSService</B></td>"  
Add-Content $report  "<td width='10%' align='center'><B>DNSServiceStatus</B></td>"  
Add-Content $report  "<td width='10%' align='center'><B>NetlogonsTest</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>ReplicationTest</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>ServicesTest</B></td>" 
  
Add-Content $report "</tr>"  
 
#####################################Get ALL DC Servers################################# 
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest() 

#Added domain name for report header 5/22/2020 wjm
$ForestDomainName = $getForest.Name
 
$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name}  
 
################Ping Test###### 
 
foreach ($DC in $DCServers){ 
$Identity = $DC 
                Add-Content $report "<tr>" 
if ( Test-Connection -ComputerName $DC -Count 1 -ErrorAction SilentlyContinue ) { 
Write-Host $DC `t $DC `t Ping Success -ForegroundColor Green 
  
        Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B> $Identity</B></td>"  
                Add-Content $report "<td bgcolor= 'Aquamarine' align=center>  <B>Success</B></td>"  
 
                ##############Netlogon Service Status################ 
        $serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "Netlogon" -ErrorAction SilentlyContinue} -ArgumentList $DC 
                wait-job $serviceStatus -timeout $timeout 
                if($serviceStatus.state -like "Running") 
                { 
                 Write-Host $DC `t Netlogon Service TimeOut -ForegroundColor Yellow 
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NetlogonTimeout</B></td>" 
                 stop-job $serviceStatus 
                } 
                else 
                { 
                $serviceStatus1 = Receive-job $serviceStatus 
                 if ($serviceStatus1.status -eq "Running") { 
            Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green  
                $svcName = $serviceStatus1.name  
                $svcState = $serviceStatus1.status           
                Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>"  
                  } 
                 else  
                  {  
                 Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red  
               $svcName = $serviceStatus1.name  
               $svcState = $serviceStatus1.status           
               Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>"  
                  }  
                } 
               ###################################################### 
                ##############NTDS Service Status################ 
        $serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "NTDS" -ErrorAction SilentlyContinue} -ArgumentList $DC 
                wait-job $serviceStatus -timeout $timeout 
                if($serviceStatus.state -like "Running") 
                { 
                 Write-Host $DC `t NTDS Service TimeOut -ForegroundColor Yellow 
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NTDSTimeout</B></td>" 
                 stop-job $serviceStatus 
                } 
                else 
                { 
                $serviceStatus1 = Receive-job $serviceStatus 
                 if ($serviceStatus1.status -eq "Running") { 
            Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green  
                $svcName = $serviceStatus1.name  
                $svcState = $serviceStatus1.status           
                Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>"  
                  } 
                 else  
                  {  
                 Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red  
               $svcName = $serviceStatus1.name  
               $svcState = $serviceStatus1.status           
               Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>"  
                  }  
                } 
               ###################################################### 
                ##############DNS Service Status################ 
        $serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "DNS" -ErrorAction SilentlyContinue} -ArgumentList $DC 
                wait-job $serviceStatus -timeout $timeout 
                if($serviceStatus.state -like "Running") 
                { 
                 Write-Host $DC `t DNS Server Service TimeOut -ForegroundColor Yellow 
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>DNSTimeout</B></td>" 
                 stop-job $serviceStatus 
                } 
                else 
                { 
                $serviceStatus1 = Receive-job $serviceStatus 
                 if ($serviceStatus1.status -eq "Running") { 
            Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green  
                $svcName = $serviceStatus1.name  
                $svcState = $serviceStatus1.status           
                Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>"  
                  } 
                 else  
                  {  
                 Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red  
               $svcName = $serviceStatus1.name  
               $svcState = $serviceStatus1.status           
               Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>"  
                  }  
                } 
               ###################################################### 
 
               ####################Netlogons status################## 
               add-type -AssemblyName microsoft.visualbasic  
               $cmp = "microsoft.visualbasic.strings" -as [type] 
               $sysvol = start-job -scriptblock {dcdiag /test:netlogons /s:$($args[0])} -ArgumentList $DC 
               wait-job $sysvol -timeout $timeout 
               if($sysvol.state -like "Running") 
               { 
               Write-Host $DC `t Netlogons Test TimeOut -ForegroundColor Yellow 
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NetlogonsTimeout</B></td>" 
               stop-job $sysvol 
               } 
               else 
               { 
               $sysvol1 = Receive-job $sysvol 
               if($cmp::instr($sysvol1, "passed test NetLogons")) 
                  { 
                  Write-Host $DC `t Netlogons Test passed -ForegroundColor Green 
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>NetlogonsPassed</B></td>" 
                  } 
               else 
                  { 
                  Write-Host $DC `t Netlogons Test Failed -ForegroundColor Red 
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>NetlogonsFail</B></td>" 
                  } 
                } 
               ######################################################## 
               ####################Replications status################## 
               add-type -AssemblyName microsoft.visualbasic  
               $cmp = "microsoft.visualbasic.strings" -as [type] 
               $sysvol = start-job -scriptblock {dcdiag /test:Replications /s:$($args[0])} -ArgumentList $DC 
               wait-job $sysvol -timeout $timeout 
               if($sysvol.state -like "Running") 
               { 
               Write-Host $DC `t Replications Test TimeOut -ForegroundColor Yellow 
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>ReplicationsTimeout</B></td>" 
               stop-job $sysvol 
               } 
               else 
               { 
               $sysvol1 = Receive-job $sysvol 
               if($cmp::instr($sysvol1, "passed test Replications")) 
                  { 
                  Write-Host $DC `t Replications Test passed -ForegroundColor Green 
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>ReplicationsPassed</B></td>" 
                  } 
               else 
                  { 
                  Write-Host $DC `t Replications Test Failed -ForegroundColor Red 
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>ReplicationsFail</B></td>" 
                  } 
                } 
               ######################################################## 
           ####################Services status################## 
               add-type -AssemblyName microsoft.visualbasic  
               $cmp = "microsoft.visualbasic.strings" -as [type] 
               $sysvol = start-job -scriptblock {dcdiag /test:Services /s:$($args[0])} -ArgumentList $DC 
               wait-job $sysvol -timeout $timeout 
               if($sysvol.state -like "Running") 
               { 
               Write-Host $DC `t Services Test TimeOut -ForegroundColor Yellow 
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>ServicesTimeout</B></td>" 
               stop-job $sysvol 
               } 
               else 
               { 
               $sysvol1 = Receive-job $sysvol 
               if($cmp::instr($sysvol1, "passed test Services")) 
                  { 
                  Write-Host $DC `t Services Test passed -ForegroundColor Green 
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>ServicesPassed</B></td>" 
                  } 
               else 
                  { 
                  Write-Host $DC `t Services Test Failed -ForegroundColor Red 
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>ServicesFail</B></td>" 
                  } 
                } 
               ######################################################## 
                 
}  
else 
              { 
Write-Host $DC `t $DC `t Ping Fail -ForegroundColor Red 
        Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B> $Identity</B></td>"  
                Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"  
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"  
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"  
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"  
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
}          
        
}  
 
Add-Content $report "</tr>" 
############################################Close HTMl Tables########################### 
 
 
Add-content $report  "</table>"  
Add-Content $report "</body>"  
Add-Content $report "</html>"  
 
 
######################################################################################## 
#############################################Send Email################################# 
 
#Added domain name for report header 5/22/2020 wjm
$subject = "Active Directory Health Monitor - $ForestDomainName"  
$body = Get-Content ".\ADreport.htm"  
$smtp= New-Object System.Net.Mail.SmtpClient $smtphost  
$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body  
$msg.isBodyhtml = $true  
$smtp.send($msg)  
 
######################################################################################## 
 
######################################################################################## 