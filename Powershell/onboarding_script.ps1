# --- Active Directory Bulk User Onboarding Script ---
# This script reads user data from a CSV file and creates corresponding accounts in AD.

# Step 1: Import the data from the CSV file. 
# The variable $users now acts as a table containing all the information from the file.
$users = Import-Csv "C:\Scripts\users.csv"

# Step 2: Loop through each row in the CSV. 
# $user represents the single person the script is currently processing.
foreach ($user in $users) {
    
    # 1. GATHER DATA & PREPARE VARIABLES
    # The '$($user.Property)' syntax is a "sub-expression." It tells PowerShell to 
    # look inside the $user object and grab the specific text from that column.
    
    $fullname = "$($user.FirstName) $($user.LastName)"
    $username = $user.Username
    
    # This creates the 'Distinguished Name' path. 
    # It tells AD exactly which folder (OU) and domain the user belongs to.
    $ouPath   = "OU=$($user.OU),DC=afrotechzone,DC=local"
    
    # Identifying the target security group for this specific user.
    $targetGroup = $user.Group  

    # 2. CREATE THE USER ACCOUNT
    # The backtick (`) is a line-continuation character. 
    # It allows us to list parameters vertically so the code is easier to read.
    New-ADUser `
        -Name $fullname `
        -GivenName $user.FirstName `
        -Surname $user.LastName `
        -SamAccountName $username `
        -UserPrincipalName "$username@afrotechzone.local" `
        -Path $ouPath `
        -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) `
        -Enabled $true # This ensures the account is 'Active' immediately upon creation.

    # 3. GROUP ASSIGNMENT
    # Now that the user exists, we 'invite' them into their departmental security group.
    # -Identity: The group name from the CSV.
    # -Members: The username we just created.
    Add-ADGroupMember -Identity $targetGroup -Members $username
}
