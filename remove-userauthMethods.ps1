# Connect to Microsoft Graph if not already connected
Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All" -NoWelcome

# Import csvfiles
$csvPath = "sampleuser.csv"

# Get user ID
#$user = Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    $userId = $user.UserPrincipalName
    Write-Host "`nProcessing user: $userId" -ForegroundColor Cyan

    # Get current authentication methods
    $authMethods = Get-MgUserAuthenticationMethod -UserId $userId

    foreach ($method in $authMethods) {
        $odataType = $method.'@odata.type'
        if (-not $odataType -and $method.PSObject.Properties.Match('@odata.type')) {
            $odataType = $method.PSObject.Properties['@odata.type'].Value
        }
        if (-not $odataType -and $method.AdditionalProperties.ContainsKey('@odata.type')) {
            $odataType = $method.AdditionalProperties['@odata.type']
        }
        $methodId = $method.Id
        if (-not $methodId -and $method.PSObject.Properties.Match('Id')) {
            $methodId = $method.PSObject.Properties['Id'].Value
        }
        if (-not $methodId -and $method.AdditionalProperties.ContainsKey('id')) {
            $methodId = $method.AdditionalProperties['id']
        }

        Write-Host "`nFound Method:" -ForegroundColor Gray
        Write-Host "  Type: $odataType"
        Write-Host "  ID:   $methodId"

        switch ($odataType) {
            "#microsoft.graph.passwordAuthenticationMethod" {
                Write-Host "  Skipping password method..." -ForegroundColor Yellow
            }
            "#microsoft.graph.phoneAuthenticationMethod" {
                Write-Host "  Removing phone method..." -ForegroundColor Red
                Remove-MgUserAuthenticationPhoneMethod -UserId $userId -PhoneAuthenticationMethodId $methodId
            }
            "#microsoft.graph.emailAuthenticationMethod" {
                Write-Host "  Removing email method..." -ForegroundColor Red
                Remove-MgUserAuthenticationEmailMethod -UserId $userId -EmailAuthenticationMethodId $methodId
            }
            "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" {
                Write-Host "  Removing Microsoft Authenticator..." -ForegroundColor Red
                Remove-MgUserAuthenticationMicrosoftAuthenticatorMethod -UserId $userId -MicrosoftAuthenticatorAuthenticationMethodId $methodId
            }
            "#microsoft.graph.fido2AuthenticationMethod" {
                Write-Host "  Removing FIDO2 method..." -ForegroundColor Red
                Remove-MgUserAuthenticationFido2Method -UserId $userId -Fido2AuthenticationMethodId $methodId
            }
            "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" {
                Write-Host "  Removing Windows Hello for Business..." -ForegroundColor Red
                Remove-MgUserAuthenticationWindowsHelloForBusinessMethod -UserId $userId -WindowsHelloForBusinessAuthenticationMethodId $methodId
            }
            "#microsoft.graph.temporaryAccessPassAuthenticationMethod" {
                Write-Host "  Removing Temporary Access Pass..." -ForegroundColor Red
                Remove-MgUserAuthenticationTemporaryAccessPassMethod -UserId $userId -TemporaryAccessPassAuthenticationMethodId $methodId
            }
            "#microsoft.graph.softwareOathAuthenticationMethod" {
                Write-Host "  Removing Software OATH token..." -ForegroundColor Red
                Remove-MgUserAuthenticationSoftwareOathMethod -UserId $userId -SoftwareOathAuthenticationMethodId $methodId
            }
            Default {
                Write-Host "  Unknown or unsupported method type. Skipping..." -ForegroundColor Yellow
            }
        }
    }

    # Wait a few seconds before final status check to allow changes to propagate
    Write-Host "`nWaiting for changes to propagate..." -ForegroundColor DarkGray
    Start-Sleep -Seconds 10

    # Final check after removals
    Write-Host "`n--- Final Status ---" -ForegroundColor Cyan

    $remainingMethods = Get-MgUserAuthenticationMethod -UserId $userId

    if ($remainingMethods.Count -eq 0 -or ($remainingMethods.Count -eq 1 -and $remainingMethods[0].'@odata.type' -eq "#microsoft.graph.passwordAuthenticationMethod")) {
        Write-Host "✅ All usable authentication methods removed for user $userId." -ForegroundColor Green
    } else {
        Write-Host "⚠️  Some methods still remain for user $($userId):" -ForegroundColor Yellow
        foreach ($method in $remainingMethods) {
            $remainingType = $method.'@odata.type'
            if (-not $remainingType -and $method.AdditionalProperties.ContainsKey('@odata.type')) {
                $remainingType = $method.AdditionalProperties['@odata.type']
            }
            Write-Host "  - $remainingType"
        }
    }
}
Write-Host "`n ===== End ===== " -ForegroundColor Green
