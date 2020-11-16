<#.LINK https://stackoverflow.com/questions/16651580/add-multiple-users-to-multiple-groups-from-one-import-csv

# Heres whats in the csv file

Group 
IIQ
!VMware_Admin_Ops
Domain-DA-Windows-Ops 

Non-IIQ
Domain Admins

#>

$list = import-csv "C:\Scripts\Import Bulk Users into bulk groups\bulkgroups3.csv"

Foreach($user in $list){       
    add-adgroupmember -identity $_.Group -member $_.Accountname
}