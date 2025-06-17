Connect-MgGraph -Scopes "User.ReadWrite.All" -NoWelcome

$csvPath = "sampleuser.csv"

$userlist = Import-Csv -Path $csvPath

foreach ($user in $userlist)
{
    $userUPN = $user.UserPrincipalName
    try
    {
        # Revoke all sessions (forces sign out)
        Revoke-MgUserSignInSession -UserId $userUPN
        Write-Host "✅ Sign-in sessions revoked for $userUPN"
    }
    catch
    {
        Write-Host "❌ Failed to revoke sessions for $( $userUPN ): $_"
    }

    try
    {
        # Block future sign-ins
        Update-MgUser -UserId $userUPN -AccountEnabled:$false
        Write-Host "✅ User account disabled for $userUPN"
    }
    catch
    {
        Write-Host "❌ Failed to disable account for $( $userUPN ): $_"
    }

    # Confirm status
#    $status = Get-MgUser -UserId $userUPN | Select-Object DisplayName, UserPrincipalName, AccountEnabled
    #    $status | Format-Table
}
Write-Host "`n ===== End ===== " -ForegroundColor Green
