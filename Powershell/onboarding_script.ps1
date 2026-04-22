$users = Import-Csv "C:\Scripts\users.csv"

foreach ($user in $users) {
    # 1. Gather the data from the CSV row
    $fullname = "$($user.FirstName) $($user.LastName)"
    $username = $user.Username
    $ouPath   = "OU=$($user.OU),DC=afrotechzone,DC=local"
    $targetGroup = $user.Group  

    # 2. Create the User
    New-ADUser `
        -Name $fullname `
        -SamAccountName $username `
        -Path $ouPath `
        -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) `
        -Enabled $true

    # 3. Add the User to the Security Group
    # We use the $username we just created and the $targetGroup from the CSV
    Add-ADGroupMember -Identity $targetGroup -Members $username
}
