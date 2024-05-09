<#
    .SYNOPSIS
    Converts all user first names and last names in a specified OU to uppercase, checks for null values, and reports them.

    .DESCRIPTION
    This script is designed to traverse a specified Organizational Unit (OU) in Active Directory and update all user first and last names to uppercase. It checks for null values in the GivenName and Surname fields, reports these entries, and updates the fields if they are not null. The script uses Turkish culture settings for correct uppercase conversion.

    .PARAMETER ouPath
    Specifies the LDAP path of the Organizational Unit where the user accounts are located.

    .EXAMPLE
    PS> .\ADConvertUserNametoUpper.ps1 -ouPath "OU=Users,DC=example,DC=com"

    .NOTES
    Author: Cengiz YILMAZ
    Title: Microsoft MVP - MCT
    Created on: [5/9/2024]
    Blog: https://cengizyilmaz.net
    Version: 1.0

    .COMPONENT
    Requires ActiveDirectory module.
#>

# OU Path
$ouPath = "OU=fixcloud-test.com,OU=HC-Systems,DC=fixcloud,DC=com,DC=tr"

# Retrieve all users in the OU
$users = Get-ADUser -Filter * -SearchBase $ouPath -Property GivenName, Surname, SamAccountName

# Set the Turkish culture settings
$culture = [System.Globalization.CultureInfo]::CreateSpecificCulture("tr-TR")

# Convert and update each user's first and last name according to Turkish characters
foreach ($user in $users) {
    $updateNeeded = $false

    # Check GivenName
    if ($user.GivenName -ne $null) {
        $newGivenName = $user.GivenName.ToUpper($culture)
        Set-ADUser -Identity $user.SamAccountName -GivenName $newGivenName
    } else {
        Write-Host "GivenName değeri boş: Kullanıcı - $($user.SamAccountName)" -ForegroundColor Red
        $updateNeeded = $true
    }

    # Check Surname
    if ($user.Surname -ne $null) {
        $newSurname = $user.Surname.ToUpper($culture)
        Set-ADUser -Identity $user.SamAccountName -Surname $newSurname
    } else {
        Write-Host "Surname değeri boş: Kullanıcı - $($user.SamAccountName)" -ForegroundColor Red
        $updateNeeded = $true
    }

    # If no update was made, report that no update was done for the user
    if (-not $updateNeeded) {
        Write-Host "Kullanıcı güncellendi: $($user.SamAccountName)" -ForegroundColor Green
    }
}