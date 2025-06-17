Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All" -NoWelcome

# Path to the CSV file containing UserPrincipalNames
$csvPath = "smlp-useremail/creative.csv"

# ID of the "All User" group that should NOT be removed
$allUserGroupId = "25567b3f-8a83-4c83-b8bc-01dfb7c3e06c"

# === Import the list of users from the CSV ===
# The CSV should have a header column named 'UserPrincipalName'
$UserList = Import-Csv -Path $csvPath

# === Process each user in the list ===
foreach ($entry in $UserList) {

    # Extract the UPN (UserPrincipalName) of the user
    $userUPN = $entry.UserPrincipalName
    Write-Host "`n=== Processing $userUPN ===" -ForegroundColor Cyan

    try {
        # Get the user object using Microsoft Graph PowerShell
        $user = Get-MgUser -UserId $userUPN

        # Get all group memberships for the user
        $userGroups = Get-MgUserMemberOf -UserId $userUPN -All
    } catch {
        # If an error occurs (e.g. user not found), log and skip to the next user
        Write-Warning "⚠️ Failed to get user or groups for $( $userUPN ): $_"
        continue
    }

    # Counter to track how many groups were removed
    $removedGroupCount = 0

    # === Loop through each group the user is a member of ===
    foreach ($group in $userGroups) {
        $groupId = $group.Id
        $groupName = $group.AdditionalProperties['displayName']

        # Only proceed if the group is NOT the "All User" group
        if ($groupId -ne $allUserGroupId) {
            try {
                # Remove the user from the group
                Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $user.Id -ErrorAction Stop
                Write-Host "✅ Removed from group: $groupName ($groupId)" -ForegroundColor Green
                $removedGroupCount++
            } catch {
                # Log if the removal fails for any reason
                Write-Warning "❌ Failed to remove from group $groupName ($groupId): $_"
            }
        }
    }

    # === Re-check user's group memberships after removals ===
    $remainingGroups = Get-MgUserMemberOf -UserId $userUPN -All

    # If the user is not a member of any group (including "All User"), log a warning
    if ($remainingGroups.Count -eq 0) {
        Write-Host "ℹ️ User $userUPN is no longer a member of any group." -ForegroundColor Yellow
    } else {
        Write-Host "🧾 User $userUPN is still a member of the following group(s):" -ForegroundColor Cyan
        foreach ($group in $remainingGroups) {
            $groupId = $group.Id
            $groupName = $group.AdditionalProperties['displayName']
            $groupType = $group.AdditionalProperties['groupTypes'] -join ", "  # may be empty
            Write-Host "➡️  Group Name: $groupName | ID: $groupId | Type: $groupType"
        }
    }
}
Write-Host "`n ===== End ===== " -ForegroundColor Green