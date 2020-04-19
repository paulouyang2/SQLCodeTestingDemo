<#
.SYNOPSIS
    Install SQL Server objects

.DESCRIPTION
    Loop through a predefined source directory in alphabetical order
    .\scripts
        Databases
        Tables
        Triggers
        Functions
        Procedures

    Execute the scripts in dependency order

.PARAMETER ImageOffer 
    string of image metadata
    [{"VersionString":"Microsoft SQL Server 2012 (SP4-GDR)","Offer":"SQL2012SP4-WS2012R2","IPAddress":"51.141.188.120","Version":"11.1.200114","Skus":"Enterprise","Name":"sql-wu2-test0"}]

.EXAMPLE
    Install-SqlCode.ps1 
#>

[CmdletBinding()]
param(
    [string]$ImageOffer = '[{"VersionString":"Microsoft SQL Server 2012 (SP4-GDR)","Offer":"SQL2012SP4-WS2012R2","IPAddress":"51.141.188.120","Version":"11.1.200114","Skus":"Enterprise","Name":"sql-wu2-test0"},{"VersionString":"Microsoft SQL Server 2014 (SP3-CU4)","Offer":"sql2014sp3-ws2012r2","IPAddress":"52.156.135.29","Version":"12.21.200114","Skus":"enterprise","Name":"sql-wu2-test1"},{"VersionString":"Microsoft SQL Server 2016 (SP2-CU10)","Offer":"sql2016sp2-ws2019","IPAddress":"52.156.80.136","Version":"13.2.191028","Skus":"enterprise","Name":"sql-wu2-test2"},{"VersionString":"Microsoft SQL Server 2017 (RTM-CU18)","Offer":"sql2017-ws2019","IPAddress":"52.250.120.15","Version":"14.1.200114","Skus":"enterprise","Name":"sql-wu2-test3"},{"VersionString":"Microsoft SQL Server 2019 (RTM-GDR)","Offer":"sql2019-ws2019","IPAddress":"51.143.2.234","Version":"15.0.200114","Skus":"enterprise","Name":"sql-wu2-test4"}]'
)

function Invoke-ScriptObject {
    [CmdletBinding()]
    param(
        [string]$IPAddress,
        [string[]]$Objects,
        [pscredential]$Credential
    )
    $params = @{
        ServerInstance = $IPAddress 
        Credential     = $Credential
        QueryTimeout   = 300 
    }

    foreach ($object in $Objects) {
        try {
            Invoke-Sqlcmd @params -InputFile $object 
        }
        catch {
            $e = $_ | Select-Object -ExpandProperty InvocationInfo
            $m = $_.Exception.Message.TrimEnd().Replace("'", "") + ", " + $e.ScriptLineNumber.ToString() + ", " + $e.OffsetInLine.ToString()
    
            if ($m.Contains('There is already an object named') -or $m.Contains('already exists')) {
                Write-Host "Ignoring 'There is already an object named' $object"
            }
            else {
                throw $m
            }            
        }
        
    }
}

function Invoke-ScriptGrouping {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]  
        [string]$IPAddress,
        [hashtable]$Objects,
        [pscredential]$Credential
    )
    process {
        Write-Host $IPAddress
        $params = @{
            IPAddress  = $IPAddress
            Credential = $Credential
        }
        
        # execute the scrips in dependency order

        Invoke-ScriptObject @params -Objects $Objects['Databases']
        Invoke-ScriptObject @params -Objects $Objects['Tables']
        Invoke-ScriptObject @params -Objects $Objects['Triggers']
        Invoke-ScriptObject @params -Objects $Objects['Functions']
        Invoke-ScriptObject @params -Objects $Objects['Procedures']
    }
}

# set to stop for Invoke-SqlCmd error handling

$ErrorActionPreference = "Stop"

$vaultName = "SqlCodeTestingDemo" 
$vaultSecret = "SQLVMAdmin"
$azAutoAccount = 'azauto'

# get credential from key vault

$azAutoSecret = Get-AzKeyVaultSecret -vaultName $vaultName -name $vaultSecret
$azAutoSecure = $azAutoSecret.SecretValue
$azAutoCredential = New-Object System.Management.Automation.PSCredential $azAutoAccount, $azAutoSecure

# set hash table with script names

$objects = @{ }
$folders = Get-ChildItem -Path './Scripts' -Directory
foreach ($folder in $folders) {
    $scripts = @()
    $files = Get-ChildItem -Path $folder.FullName -Filter '*.sql'
    foreach ($file in $files) {
        $scripts += @('./Scripts/' + $folder.Name + '/' + $file.name)
    }
    $objects += @{$folder.Name = $scripts }
}

# install scripts for each image offer

$images = $ImageOffer | ConvertFrom-Json 
$images | Invoke-ScriptGrouping -Objects $objects -Credential $azAutoCredential

