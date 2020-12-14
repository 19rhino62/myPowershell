#	FSMO Role
# 0	PDC Emulator
# 1	RID Master
# 2	Infrastructure Master
# 3	Schema Master
# 4	Domain Naming Master
#Move-ADDirectoryServerOperationMasterRole -Identity “DomainController” –OperationMasterRole 0,1,2,3,4 -Confirm:$false -Force

# --------------------------------------------------------------------------------------------------------------------------------
# sscincorporated.com
# --------------------------------------------------------------------------------------------------------------------------------

#PMEMCFSCDC01
#PMEMCFSCDC02

#I pick the newest DC that is in Nashville for IIQ and FAM configurations
#Get-ADDomainController -Filter * | Select Name, ipv4Address, OperatingSystem, site | Sort-Object -Property Name 


move FSMOs from  FL-DC-VM6/FL-DC-VM4 TO FL-DC-VM8/FL-DC-VM9

Schema master               FL-DC-VM6.sscincorporated.com
Domain naming master        FL-DC-VM6.sscincorporated.com
PDC                         FL-DC-VM4.sscincorporated.com
RID pool manager            FL-DC-VM4.sscincorporated.com
Infrastructure master       FL-DC-VM4.sscincorporated.com


Move-ADDirectoryServerOperationMasterRole -Identity “FL-DC-VM8” –OperationMasterRole 3,4 -Confirm:$false -Force
Move-ADDirectoryServerOperationMasterRole -Identity “FL-DC-VM9” –OperationMasterRole 0,1,2 -Confirm:$false -Force

#	FSMO Role
# 0	PDC Emulator
Move-ADDirectoryServerOperationMasterRole -Identity “pbnaaescdc03” –OperationMasterRole 0 -Confirm:$false -Force
Move-ADDirectoryServerOperationMasterRole -Identity “pbnaaescdc03” –OperationMasterRole 1,2 -Confirm:$false -Force
Move-ADDirectoryServerOperationMasterRole -Identity “pbnaaescdc04” –OperationMasterRole 3,4 -Confirm:$false -Force

# --------------------------------------------------------------------------------------------------------------------------------

