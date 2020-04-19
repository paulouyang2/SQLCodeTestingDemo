<#
.SYNOPSIS
    Remove resources

.DESCRIPTION
    Remove the folloing resources
        service principal
        resource group
        devops project

#>

$resourceGroup = 'DemoRG'
$servicePrincipalName = 'http://SQLCodeTestingDemo'
$projectName = "SqlCodeTestingDemo"

# connect to az

az login

# remove service principal

az ad sp delete `
    --id $servicePrincipalName 

# remove the resource group

az group delete `
    --name $resourceGroup `
    --yes `
    --no-wait

# connect to devops

# copy your Azure DevOps PAT to the clipboard 
# paste the PAT in the prompt, as shown below 
#   Token: 

az devops login

# remove project

$list = az devops project list | convertfrom-json
$project = $list.value | Where-Object { $_.name -eq $projectName }

az devops project delete `
    --id $project.id `
    --yes 

