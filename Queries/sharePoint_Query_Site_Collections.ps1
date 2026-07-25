# --- Configuration Variables ---
param(
  [Parameter(Mandatory)]
  [string]$csv,
  # Input csv file with URLs for all site collections that you want to query

  [Parameter(Mandatory)]
  [string]$EntraID,

  [Parameter(Mandatory)]
  [string]$ExportPath
  # the path to the directory that the CSV output will be
)

$SitesCsv = Import-Csv $csv

foreach ($Site in $SitesCsv) {
  
  # --- Connect to SharePoint Online ---
  Connect-PnPOnline -Url $Site.Url -ClientId $EntraID
  
  # Array to collect final report rows
  $ReportData = @()
  
  # Fetch all lists and explicitly load hidden and unique permission properties
  Write-Host "Fetching lists from $($Site.Url)..." -ForegroundColor Cyan
  $Lists = Get-PnPList -Includes HasUniqueRoleAssignments, Hidden, RootFolder, RoleAssignments
  
  # Filter out system hidden lists
  $VisibleLists = $Lists | Where-Object { $_.Hidden -eq $false }
  
  foreach ($List in $VisibleLists) {
      # Check if the list/library has broken inheritance
      if ($List.HasUniqueRoleAssignments) {
          Write-Host "Found unique permissions on list: $($List.Title)" -ForegroundColor Yellow
          
          # Load the specific RoleAssignments property for security objects
          $RoleAssignments = Get-PnPProperty -ClientObject $List -Property RoleAssignments
          
          foreach ($RoleAssignment in $RoleAssignments) {
              # Resolve Member (User/Group) and RoleDefinitionBindings (Permission levels)
              $Member = Get-PnPProperty -ClientObject $RoleAssignment -Property Member
              $RoleBindings = Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings
              
              # Extract permission level names (e.g., Read, Contribute, Full Control)
              $PermissionLevels = ($RoleBindings | Select-Object -ExpandProperty Name) -join ", "
              
              # Skip "Limited Access" if you want a cleaner report
              if ($PermissionLevels -eq "Limited Access") { continue }
  
              # Create an object for each permission assignment
              $ReportRow = [PSCustomObject]@{
                  "List Title"        = $List.Title
                  "List URL"          = $List.RootFolder.ServerRelativeUrl
                  "Principal Name"    = $Member.Title
                  "Principal Login"   = $Member.LoginName
                  "Principal Type"    = $Member.PrincipalType
                  "Permission Levels" = $PermissionLevels
              }
              $ReportData += $ReportRow
          }
      }
  }
  
  # --- Export to CSV File ---
  if ($ReportData.Count -gt 0) {
      # grabs the site collection url to add to the csv output
      $SiteName = $Site.Url.TrimEnd('/').Split('/')[-1]
      # Checks network path exists and makes one if it doesn't
      $Directory = Split-Path -Path $ExportPath
      if (-not (Test-Path -Path $Directory)) {
          New-Item -ItemType Directory -Path $Directory -Force | Out-Null
      }
      #exports the csv file 
      $ReportData | Export-Csv -Path "$($ExportPath)$($SiteName).csv" -NoTypeInformation -Encoding utf8
      Write-Host "Successfully exported unique permissions report to: $ExportPath" -ForegroundColor Green
  } else {
      Write-Host "No lists with unique permissions were found on this site." -ForegroundColor White
  }
  
}
