#+-------------------------------------------------------------------
# CHECK RECYCLE BIN
#.LINK http://www.frickelsoft.net/blog/?p=224
#+-------------------------------------------------------------------

$RecycleBin = Get-ADOptionalFeature -Identity "Recycle Bin Feature"
    If ($RecycleBin.EnabledScopes) {Write-Host "`n`tRecycle Bin Enabled" -ForegroundColor Green}
    Else {Write-Host "`n`tRecycle Bin Disabled" -ForegroundColor Red}

#+-------------------------------------------------------------------
# ACCIDENTAL DELETION
#.LINK https://gallery.technet.microsoft.com/scriptcenter/Check-Enable-and-Disable-f2c71244
#+-------------------------------------------------------------------

Get-ADOrganizationalUnit -Filter * -Properties *| Select-Object CanonicalName,DistinguishedName,ProtectedFromAccidentalDeletion
