"""
This Script work to remove all licensed and grooup of a user
"""

# Make sure you are connected to Microsoft Graph before running this script
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All" -NoWelcome

# Step 1: List of user UPNs (email addresses) or Azure AD User IDs to process
#$UserList = @("Kurt.Venzon@strongmind.com")
$CsvPath = "smlp-useremail/creative.csv"

$userlist = Import-Csv -Path $CsvPath | Select-Object -ExpandProperty UserPrincipalName
# Step 2: Loop through each user in the list
foreach ($user in $userlist) {
    try {
        # Step 3: Retrieve all license details assigned to the user
        # This returns license objects which contain the SKU (license) IDs
        $userLicenseInfo = Get-MgUserLicenseDetail -UserId $user

        # Step 4: Extract all SkuIds from the license info
        # These SkuIds represent the licenses assigned to the user
        $skuIds = $userLicenseInfo.SkuId

        # Step 5: Check if there are any licenses to remove
        if ($skuIds.Count -gt 0) {
            # Step 6: Unassign all licenses using Set-MgUserLicense
            # -AddLicenses is empty because we don't want to add any licenses
            # -RemoveLicenses includes all current SkuIds to remove
            Set-MgUserLicense -UserId $user -AddLicenses @() -RemoveLicenses $skuIds

            # Step 7: Output confirmation to the console
            Write-Host "✅ Successfully removed licenses for $user"
        }
        else {
            # If user has no licenses, log that
            Write-Host "ℹ️ No licenses found for $user"
        }
    } catch {
        # Catch any errors and print a message
        Write-Host "❌ Error processing ${user}: $_"
    }
}
Write-Host "`n ===== End ===== " -ForegroundColor Green