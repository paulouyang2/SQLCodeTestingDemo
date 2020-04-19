<#
.SYNOPSIS
    Calls Invoke-Pester

.DESCRIPTION
    Calls Invoke-Pester and output to XML file to pass to publish result task in Azure DevOps

.PARAMETER StagingPath 
    path for output file

.PARAMETER ImageOffer 
    string of image metadata
    [{"VersionString":"Microsoft SQL Server 2012 (SP4-GDR)","Offer":"SQL2012SP4-WS2012R2","IPAddress":"51.141.188.120","Version":"11.1.200114","Skus":"Enterprise","Name":"sql-wu2-test0"}]

.EXAMPLE
    Test-SqlCode.ps1 
#>
[CmdletBinding()]
param(
    [string]$StagingPath = 'C:\temp',
    [string]$ImageOffer
)

Install-Module -Name Pester -Force -SkipPublisherCheck

$param = @{
    Script       = @{
        Path       = ".\Test-SqlCodePester.ps1"
        Parameters = @{
            ImageOffer  = $ImageOffer
        }
    }
    OutputFile   = "$StagingPath\Test-SqlCodePester.XML" 
    OutputFormat = 'NUnitXML'
}
Invoke-Pester @param
