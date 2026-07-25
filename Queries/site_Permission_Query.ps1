# runs through the site and checks the permissions of each list if they differ from default
#

param(
  [Parameter(Mandatory)]
  [string]$SiteUrl
  
  [Parameter(Mandatory)]
  [string]$EntraID,
)
# Connect to the SharePoint List
Connect-PnPOnline -Url $SiteUrl  -ClientId $EntraID

# Get all lists
$Lists = Get-PnPList
$Results = @()

foreach ($List in $Lists)
{
    # Load HasUniqueRoleAssignments
    Get-PnPProperty -ClientObject $List -Property HasUniqueRoleAssignments

    Write-Host "Checking: $($List.Title)"

    if ($List.HasUniqueRoleAssignments)
    {
        Write-Host "  Unique Permissions Found" -ForegroundColor Yellow

        # Load RoleAssignments
        Get-PnPProperty -ClientObject $List -Property RoleAssignments

        foreach ($RoleAssignment in $List.RoleAssignments)
        {
            # Load Member and Roles
            Get-PnPProperty -ClientObject $RoleAssignment -Property Member, RoleDefinitionBindings

            $Roles = ($RoleAssignment.RoleDefinitionBindings |
                Select-Object -ExpandProperty Name) -join ", "

            # $Result = [PSCustomObject]@{
            $Results.Add([PSCustomObject]@{
                SiteURL      = $SiteUrl
                ListName     = $List.Title
                ListUrl      = $List.DefaultViewUrl
                Principal    = $RoleAssignment.Member.Title
                PrincipalType= $RoleAssignment.Member.PrincipalType
                Permission   = $Roles
            })

            $Results = [System.Collections.Generic.List[object]]::new()
        }
    }
    else
    {
        Write-Host "  Inherits Permissions"
    }
}

Write-Host ""
Write-Host "Found $($Results.Count) permission assignments."
if ($Results.Count -gt 0)
{
    $Results | Export-Csv `
        "C:\Users\jdavidson\OneDrive - MARY CARIOLA CHILDRENS CENTER\Pnp\testing\$(SiteName).csv" `
        -NoTypeInformation

    Write-Host "Exported $($Results.Count) records." -ForegroundColor Green
}
else
{
    Write-Warning "No unique permissions were found."
}

