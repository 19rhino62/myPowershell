#.LINK https://www.whatsupgold.com/blog/how-to-find-restart-info-for-machines-on-your-network-using-powershell-and-windows-event-logs
#$computer = "."
#$computers | ForEach-Object {Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074} -MaxEvents 2 | format-table -wrap}

#$computers | ForEach-Object {Get-WinEvent -ComputerName $_  -FilterHashtable @{logname = 'System'; id = 1074} -MaxEvents 2 | format-table -wrap}

#Get-WinEvent -ComputerName $computer -FilterHashtable @{logname = 'System'; id = 1074, 6005, 6006, 6008} -MaxEvents 6 | Format-Table -wrap

#Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074, 6005, 6006, 6008} -MaxEvents 2| 
Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074} -MaxEvents 2| #ft -wrap
    ForEach-Object {
        $EventData = New-Object PSObject | Select-Object Date, EventID, User, Action, Reason, ReasonCode, Comment, Computer, Message, Process
        $EventData.Date = $_.TimeCreated
        $EventData.User = $_.Properties[6].Value
#        $EventData.Process = $_.Properties[0].Value
#        $EventData.Action = $_.Properties[4].Value
#        $EventData.Reason = $_.Properties[2].Value
#        $EventData.ReasonCode = $_.Properties[3].Value
        $EventData.Comment = $_.Properties[5].Value
        $EventData.Computer = $env:ComputerName #$computer
        $EventData.EventID = $_.id
        $EventData.Message = $_.message

        #$EventData | Select-Object Computer, Date, EventID, Action, Reason, User, Process, Comment | ft -Wrap
        $EventData | Select-Object Date, Computer, EventID, Message | ft -Wrap
        }

