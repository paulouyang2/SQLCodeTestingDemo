<#
.SYNOPSIS
    Install AZ SQL VM of the latest version of each major release using ARM template

.DESCRIPTION
    Get the images offered of the latest version of each major release and pass it as an array parameter to the ARM template
    The ARM template will install the resources needed for each element of the of the images array
    Get the IP Addresses and version string 
 
.EXAMPLE
    Install-SqlVm.ps1 

#>
[CmdletBinding()]
param(
)

$resourceGroup = 'DemoRG'
$templateFile = '.\New-SqlVmTemplate.json'
$templateParameterFile = '.\New-SqlVmTemplate.Parameters.json'
$location = 'WestUS2'
$publisher = 'MicrosoftSQLServer'
$sku = 'Enterprise'
$offerRegEx = '^SQL20[1-2][0-9].*-WS.*(?<!-byol)$'
$prefix = 'sql-wu2-test'
$vaultName = "SqlCodeTestingDemo" 
$vaultSecret = "SQLVMAdmin"
$azAutoAccount = 'azauto'

# get credential from key vault

$azAutoSecret = Get-AzKeyVaultSecret -vaultName $vaultName -name $vaultSecret
$azAutoSecure = $azAutoSecret.SecretValue
$azAutoCredential = New-Object System.Management.Automation.PSCredential $azAutoAccount, $azAutoSecure

# get image offer of the latest version of major release

Write-Host 'Getting SQL Images'

$list = Get-AzVMImageOffer -Location $location -Publisher $publisher | 
Where-Object { $_.Offer -match $offerRegEx } |
Get-AzVMImageSku |
Where-Object { $_.Skus -eq $sku } |
Get-AzVMImage |
Select-Object Version, Offer, Skus |
Group-Object { $_.Version.Substring(0, 2) } |
Select-Object @{Name = 'latest'; Expression = { $_.Group[$_.Count - 1] } } 

# convert list to array of hash tables to pass as a parameter tamplate
# otherwise get error "Unable to process template language expressions for resource"

$images = @()

$list.latest |
ForEach-Object { $i = 0 } {
    $attributes = @{ }
    $attributes.Version = $_.Version
    $attributes.Offer = $_.Offer
    $attributes.Skus = $_.Skus
    $attributes.Name = "$prefix$i"
    $images += $attributes
    $i++
}

# deploy template

Write-Host 'Deploying Template'

$params = @{
    ResourceGroupName         = $resourceGroup
    TemplateFile              = $templateFile
    TemplateParameterFile     = $templateParameterFile
    AdminPassword             = $azAutoSecure 
    SqlAuthenticationPassword = $azAutoSecure 
    Images                    = $images
}

$null = New-AzResourceGroupDeployment @params 

# get IP address and version string
# because ARM template output does not support "copy" used to install multiple resources
# example of $vmName = 'sql-wu2-test0'

Write-Host 'Getting IP Address and Version String'

$images |
ForEach-Object {
    $vmName = $_.Name
    $vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName 
    $nicName = $vm.NetworkProfile[0].NetworkInterfaces.Id.Split('/')[-1]
    $nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroup -Name $nicName 
    $ipId = $nic.IpConfigurations.PublicIpAddress.Id
    $ip = Get-AzPublicIpAddress -ResourceGroupName $resourceGroup | Where-Object { $_.Id -eq $ipId }
    
    $_.IPAddress = $ip.IpAddress

    $param = @{
        ServerInstance = $_.IPAddress 
        Credential     = $azAutoCredential 
        Query          = "select VersionString = substring(@@version,1,CHARINDEX(')',@@version))"
    }
    $r = Invoke-Sqlcmd @param
    
    $_.VersionString = $r.VersionString
}

# output var to pass to next pipeline task

$imageOffer = $images | ConvertTo-Json -Compress
Write-host "##vso[task.setvariable variable=imageOffer]$imageOffer"
Write-Output $images | Format-Table

