# Pester 5.0.3 does not allow parameters, use a script variable instead
# [CmdletBinding()]
# param(
#     [string]$ImageOffer 
# )

. .\Test-SqlCodeFunction.ps1

# load image and procs

$images = $ImageOffer | ConvertFrom-Json 
Write-Host $ImageOffer
$sqlCodeTests = .\Test-SqlCodeCases.ps1

# get credential from vault

$vaultName = "SqlCodeTestingDemo" 
$vaultSecret = "SQLVMAdmin"
$azAutoAccount = 'azauto'
$azAutoSecret = Get-AzKeyVaultSecret -vaultName $vaultName -name $vaultSecret
$azAutoSecure = $azAutoSecret.SecretValue
$azAutoCredential = New-Object System.Management.Automation.PSCredential $azAutoAccount, $azAutoSecure

#test proc for each image

foreach ($image in $images) {
    $common = @{
        ServerInstance = $image.IPAddress
        Database       = 'demoDB'
        Credential     = $azAutoCredential
        VersionString  = $image.VersionString.Replace(' ', '').Replace('MicrosoftSQLServer', '')
    }
    foreach ($test in $sqlCodeTests) {
        Test-SqlCode @test @common
    }
}
