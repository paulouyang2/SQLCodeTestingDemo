<#
.SYNOPSIS
    Remove SQL VMs and it dependencies

.DESCRIPTION
    Remove SQL VMs and it dependencies (disks, networkInterfaces, storageAccounts)
 
.EXAMPLE
    Remove-SqlVm.ps1 

#>
[CmdletBinding()]
param(
)

# remove virtualMachines with tag first, then other resources (disks, networkInterfaces, storageAccounts)
# retry for timeouts like this error
# Remove-AzResource : Operation failed because a request timed out.

$retryCount = 0
$stopLoop = $false

while (-not $stopLoop)
{
    try{
        Get-AzResource -TagName 'Project' -TagValue 'SqlCodeTest' -ResourceType 'Microsoft.Compute/virtualMachines' |
        ForEach-Object {Remove-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceName $_.Name -ResourceType $_.ResourceType -Force}
        Get-AzResource -TagName 'Project' -TagValue 'SqlCodeTest' -ResourceType 'Microsoft.Compute/disks' |
        ForEach-Object {Remove-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceName $_.Name -ResourceType $_.ResourceType -Force}
        Get-AzResource -TagName 'Project' -TagValue 'SqlCodeTest' -ResourceType 'Microsoft.Network/networkInterfaces' |
        ForEach-Object {Remove-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceName $_.Name -ResourceType $_.ResourceType -Force}
        Get-AzResource -TagName 'Project' -TagValue 'SqlCodeTest' -ResourceType 'Microsoft.Network/publicIPAddresses' |
        ForEach-Object {Remove-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceName $_.Name -ResourceType $_.ResourceType -Force}
        Get-AzResource -TagName 'Project' -TagValue 'SqlCodeTest' -ResourceType 'Microsoft.Storage/storageAccounts' |
        ForEach-Object {Remove-AzResource -ResourceGroupName $_.ResourceGroupName -ResourceName $_.Name -ResourceType $_.ResourceType -Force}
        $stopLoop = $true
    }
    catch{
        $e = $_ | Select-Object -ExpandProperty InvocationInfo
        $m = $_.Exception.Message.TrimEnd().Replace("'","") + ", " + $e.ScriptLineNumber.ToString() + ", " + $e.OffsetInLine.ToString()
        if ($m -contains 'Operation failed because a request timed out')
        {
            $retryCount ++
            if ($retryCount -gt 3)
            {
                $stopLoop = $true
                $m = $m + 'Could not remove resource after 3 retries'
                throw $m
            }
        }
        else {
            throw $m
        }
    }
}
