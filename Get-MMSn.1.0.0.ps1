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

#Enter Server or choose file
#$ServerList = Get-Content "C:\Users\wmorrison_admin\Documents\1191.fqdn.cmdb.txt"
$ServerList = Read-Host -Prompt 'Type or paste in servername (FQDN) or <ENTER> to select a file'

If(-not $ServerList) {
    $ServerList = Get-Content (Get-TXTinputFile)
    Write-Host `n`n
    }
    
$date = (Get-Date).ToString("MMddyyyy_HHmmss")

$i=0
$tot = $ServerList.count

$CompSystemArray = @()

ForEach ($server in $ServerList) {
    $server = $server.Trim()

	#// Set up progress bar
	$i++
	$status = "{0:N0}" -f ($i / $tot * 100)
	Write-Progress -Activity "Gathering Computer Information on $server" -status "Processing Server $i of $tot : $status% Completed" -PercentComplete ($i / $tot * 100)
    
    If (Test-Connection -Count 1 -ComputerName $server -ErrorAction SilentlyContinue) {

        $CompInfoArray = New-Object PSObject
        $ComputerSystem = Get-WmiObject -Class:Win32_ComputerSystem -ComputerName $server -ErrorAction SilentlyContinue
        Write-Host "`nServer: "-NoNewline -ForegroundColor Green
        $ComputerSystem.Name

        $CompInfoArray | Add-Member -Type NoteProperty -Name "Server" -Value $ComputerSystem.Name -Force

        Write-Host "Domain: "-NoNewline -ForegroundColor Green
        $ComputerSystem.Domain

        $CompInfoArray | Add-Member -Type NoteProperty -Name "Domain" -Value $ComputerSystem.Domain -Force

        Write-Host "Manufacturer: "-NoNewline -ForegroundColor Green
        $ComputerSystem.Manufacturer

        $CompInfoArray | Add-Member -Type NoteProperty -Name "Manufacturer" -Value $ComputerSystem.Manufacturer -Force

        Write-Host "Model: "-NoNewline -ForegroundColor Green
        $ComputerSystem.Model

        $CompInfoArray | Add-Member -Type NoteProperty -Name "Model" -Value $ComputerSystem.Model -Force

        $SerialBIOS = Get-WmiObject -Class:Win32_BIOS -ComputerName $server
        Write-Host "Serial Number: "-NoNewline -ForegroundColor Green
        $SerialBIOS.SerialNumber

        $CompInfoArray | Add-Member -Type NoteProperty -Name "Serial Number" -Value $SerialBIOS.SerialNumber -Force

#    Write-host $ComputerSystem.PrimaryOwnerName
    } # END IF
    $CompSystemArray += $CompInfoArray

} #END FOR

$CompSystemArray | ft *

#$CompSystemArray  | Export-Csv "C:\Users\wmorrison\Documents\Reports\MMSn_$date.csv"
