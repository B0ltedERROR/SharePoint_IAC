# query the permissions of a single list

param(
  [Parameter(Mandatory)]
  [string]$list_Name

)
# Grabs the ID number for this list
$listID = Get-PnPList -Identity $list_Name

# adds the property roleAssignment to the variable
Get-PnPProperty -ClientObject $listID -Property RoleAssignments

# Loops through each role to grab the permissions of each group
foreach ($roleAssignment in $listID.RoleAssignments)
{
    Get-PnPProperty -ClientObject $roleAssignment -Property Member, RoleDefinitionBindings

    Write-Host "Principal:" $roleAssignment.Member.Title

    foreach ($role in $roleAssignment.RoleDefinitionBindings)
    {
        Write-Host "  -" $role.Name
    }

    Write-Host ""
}


