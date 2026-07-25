# Powershell script to query permissions for a SharePoint site


param(
  [Parameter(Mandatory)]
  [string]$list_Name
)

$list = Get-PnPList -Identity $list_Name

Get-PnPProperty -ClientObject $list -Property HasUniqueRoleAssignments

#$list.HasUniqueRoleAssignments

