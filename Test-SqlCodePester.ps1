<#
.SYNOPSIS
    Test query execution using Pester framework

.DESCRIPTION
    Loop through each query in the .\ProcHashTable.ps1 and test that the actual should be the expected result
    The following tests can be made
    expectedRowsEq
    expectedRowsGt
    expectedColumnNames
    expectedValues
    queryStateBefore
    expectedStateBefore
    queryStateAfter
    expectedStateAfter

.PARAMETER ImageOffer 
    string of image metadata
    [{"VersionString":"Microsoft SQL Server 2012 (SP4-GDR)","Offer":"SQL2012SP4-WS2012R2","IPAddress":"51.141.188.120","Version":"11.1.200114","Skus":"Enterprise","Name":"sql-wu2-test0"}]

.EXAMPLE
    Test-SqlCodePester.ps1 
#>
[CmdletBinding()]
param(
    [string]$ImageOffer = '[{"VersionString":"Microsoft SQL Server 2012 (SP4-GDR)","Offer":"SQL2012SP4-WS2012R2","IPAddress":"51.141.189.81","Version":"11.1.200114","Skus":"Enterprise","Name":"sql-wu2-test0"},{"VersionString":"Microsoft SQL Server 2014 (SP3-CU4)","Offer":"sql2014sp3-ws2012r2","IPAddress":"51.141.160.179","Version":"12.21.200114","Skus":"enterprise","Name":"sql-wu2-test1"}]'
)

function Test-Procedure {
    [CmdletBinding()]
    param(
        $procedure,
        $arguments,
        $VersionString,
        $IPAddress,
        $database,
        $expectedRowsEq,
        $expectedRowsGt,
        $expectedColumnNames,
        $expectedValues,
        $queryStateBefore,
        $expectedStateBefore,
        $queryStateAfter,
        $expectedStateAfter,
        [PSCredential]$azAutoCredential       
    )

    describe "$VersionString.$($database).$($procedure)" {
        try {
            $errorMessage = $null
            $before = @()
            $results = @()
            $param = @{
                ServerInstance = $IPAddress
                Database       = $database 
                Credential     = $azAutoCredential
                ErrorAction    = 'Stop'
            }
            if ($null -ne $queryStateBefore) {
                $before = @(Invoke-Sqlcmd @param -Query $queryStateBefore)
            }
            $results = @(Invoke-Sqlcmd @param -Query "$($procedure) $($arguments)")
            if ($null -ne $queryStateAfter) {
                $after = @(Invoke-Sqlcmd @param -Query $queryStateAfter)
            }
        }
        catch {
            $errorMessage = $_
        }
        it 'Errors' {
            $errorMessage | Should -Be $null
        }
        if ($null -ne $expectedStateBefore) {
            it 'State Before' { 
                $before[0].ItemArray | Should -Be $expectedStateBefore
            }
        }
        if ($null -ne $expectedRowsEq) {
            it 'Number of Rows in Output' {
                $results.count | Should -Be $expectedRowsEq
            }
        }
        if ($null -ne $expectedRowsGt) {
            it 'Number of Rows in Output' {
                $results.count | Should -BeGreaterThan $expectedRowsGt
            }
        }
        if ($null -ne $expectedColumnNames) {
            it 'Column Names in Output' { 
                $expectedColumnNames | 
                Compare-Object $results[0].table.columns.columnname | 
                Should -Be $null
            }
        }
        if ($null -ne $expectedValues) {
            it 'Values in Output' { 
                $expectedValues |
                ForEach-Object { if ($results[0].ItemArray -notcontains $_) { $_ } } |
                Should -Contain $null
            }
        }
        if ($null -ne $expectedStateAfter) {
            it 'State After' { 
                $after[0].ItemArray | Should -Be $expectedStateAfter
            }
        }
    }
}

# load image and procs

$images = $ImageOffer | ConvertFrom-Json 
$procs = .\ProcHashTable.ps1

$vaultName = "SqlCodeTestingDemo" 
$vaultSecret = "SQLVMAdmin"
$azAutoAccount = 'azauto'

# get credential from vault

\$azAutoSecret = Get-AzKeyVaultSecret -vaultName $vaultName -name $vaultSecret
$azAutoSecure = $azAutoSecret.SecretValue
$azAutoCredential = New-Object System.Management.Automation.PSCredential $azAutoAccount, $azAutoSecure

#test proc for each image

foreach ($image in $images) {
    foreach ($proc in $procs) {
        $param = @{
            IPAddress        = $image.IPAddress
            VersionString    = $image.VersionString.Replace(' ', '').Replace('MicrosoftSQLServer', '')
            azAutoCredential = $azAutoCredential
        }
        Test-Procedure @proc @param
    }
}
