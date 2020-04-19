<#
.SYNOPSIS
    Adds the resources needed required the Automated SQL Code Testing CI Pipeline

.DESCRIPTION
    Adds the following resources
        resource group
        virtual network
        network security group
        service principal
        key vault
        devops project

#>

$subscriptionName = 'your subscription name'
$subscriptionId = 'your subscription id'
$tenantId = 'your tenant id'
$location = 'WestUS2'
$resourceGroup = 'DemoRG'
$vnet = 'DemoVNET'
$nsg = 'DemoNSG'
$rule = 'AllowSQL'
$vaultName = 'SqlCodeTestingDemo'
$servicePrincipalName = 'http://SQLCodeTestingDemo'
$projectName = "SqlCodeTestingDemo"

# execute one command at a time 

# connect to az

az login

# create resource group

az group create `
    --location $location `
    --name $resourceGroup

# create vnet

az network vnet create `
    --name $vnet `
    --resource-group $resourceGroup `
    --subnet-name 'default'

# create network security group

az network nsg create `
    --name $nsg `
    --resource-group $resourceGroup 

# create rule

az network nsg rule create `
    --name $rule `
    --nsg-name $nsg `
    --priority 300 `
    --resource-group $resourceGroup `
    --access Allow `
    --destination-port-ranges 1433 `
    --direction Inbound `
    --protocol Tcp

# associate the NSG to the default subnet

az network vnet subnet update `
    --vnet-name $vnet `
    --name 'default' `
    --resource-group $resourceGroup `
    --network-security-group $nsg

# crate service principal

$servicePrincipal = az ad sp create-for-rbac `
    --name $servicePrincipalName | 
    ConvertFrom-Json

# crate key vault

az keyvault create `
    --location $location `
    --name $vaultName `
    --resource-group $resourceGroup 

# add secrets

az keyvault secret set `
    --name "SQLCodeTestingDemo" `
    --value $servicePrincipal.password `
    --vault-name $vaultName

az keyvault secret set `
    --name 'SQLVMAdmin' `
    --value "Hello123456" `
    --vault-name $vaultName

# grant access on key vault to service principal

az keyvault set-policy `
    --name $vaultName `
    --spn $servicePrincipalName `
    --secret-permissions get list

# connect to devops

# copy your Azure DevOps PAT to the clipboard 
# paste the PAT in the prompt, as shown below 
#   Token: 

az devops login

# create project

az devops project create `
    --name $projectName

# run $servicePrincipal.password and copy it to the clipboard

$servicePrincipal.Password

# create service connection

# paste the password at the prompts, as shown below
#   Azure RM service principal key:
#   Confirm Azure RM service principal key:

$service = az devops service-endpoint azurerm create `
    --azure-rm-service-principal-id $servicePrincipal.appId `
    --azure-rm-subscription-id $subscriptionId `
    --azure-rm-subscription-name $subscriptionName `
    --azure-rm-tenant-id $tenantId `
    --name $projectName `
    --project $projectName | convertfrom-json

# grant access on service connection to all pipelines

az devops service-endpoint update `
    --id $service.id `
    --project $projectName `
    --enable-for-all

# import from GitHub to Azure repo

az repos import create `
    --git-source-url 'https://github.com/paulouyang2/SQLCodeTestingDemo' `
    --repository $projectName `
    --project $projectName

# create pipelife from yaml

az pipelines create `
    --name $projectName `
    --branch 'master' `
    --repository $projectName `
    --repository-type 'tfsgit' `
    --project $projectName `
    --skip-first-run `
    --yaml-path azure-pipelines.yml 

