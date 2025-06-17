---

````markdown
# mggraph-pwsh

PowerShell automation scripts for managing Microsoft 365 users via Microsoft Graph API.
This project includes tools to assist in offboarding users by revoking sessions, removing licenses, group memberships, and authentication methods.

## 📁 Scripts Included

| Script                         | Description                                                                              |
| ------------------------------ | ---------------------------------------------------------------------------------------- |
| `remove-usersigninsession.ps1` | Revokes all active sign-in sessions for a specified user.                                |
| `remove-userlicenses.ps1`      | Removes all Microsoft 365 licenses assigned to a specified user.                         |
| `remove-usergroups.ps1`        | Removes the user from all Azure AD groups.                                               |
| `remove-userauthMethods.ps1`   | Deletes all registered authentication methods (e.g., MFA phone, app, etc.) for the user. |

## ✅ Requirements

- PowerShell 7+
- Microsoft Graph PowerShell SDK (`Microsoft.Graph`)
- Azure AD admin privileges
- App registration (optional if using delegated auth)

Install Microsoft Graph SDK:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```
````

## 🔐 Authentication

You can sign in interactively with:

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.AccessAsUser.All"
```

Or using a service principal (client credentials) with certificate or secret.

## 🚀 Usage

Run each script individually, or combine them as part of your offboarding workflow.

Example:

```powershell
.\remove-usersigninsession.ps1 -UserPrincipalName user@domain.com
.\remove-userlicenses.ps1 -UserPrincipalName user@domain.com
.\remove-usergroups.ps1 -UserPrincipalName user@domain.com
.\remove-userauthMethods.ps1 -UserPrincipalName user@domain.com
```

Each script will prompt for login or use your existing `Connect-MgGraph` session.

## 📌 Notes

- Scripts are designed to be run by an admin with appropriate Graph permissions.
- Error handling is included for common scenarios (e.g., user not found, no groups assigned).
- Logs or status messages are output to the console for visibility.

## 🛠️ Customization

Feel free to add parameters, logging to file, or integration into larger workflows (e.g., Teams notifications, CSV input, CI/CD triggers).

---
