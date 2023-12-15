
<#
    .SYNOPSIS
    Initial Setup Script

    .DESCRIPTION
    This PowerShell script is meant to run on your local machine for the actions below. This script only needs to be 
    run once at the beginning of the project to set up the Github repo with needed secrets and vars, as well as the 
    backend Azure Resource Group and Storage Account. 

    .NOTES
    Required for this script to run:
    - Azure App Registration already created with a secret. The App Registration needs to have owner rights on your subscription as it assigns access roles. 
    - Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
    - GitHub CLI: https://github.com/cli/cli#installation

#>

#Default parameters for backend resources.
Write-Host "`nAdding default parameters" -ForegroundColor Yellow
$project = "secvm"
$terraformSaRgName = "$($project)-backend"
$terraformSaName = "tfsa$(Get-Random -Minimum 1000000 -Maximum 9999999)"
$terraformSaContainerName = "tfstate"

#Only use the following regions right now as the Bastion Developer SKU preview is locked to them.
#northcentralus, westcentralus, westus, northeurope
$region = "northcentralus"

#Prompts for other parameters that need to be user provided.
Write-Host "`nPrompting for more info" -ForegroundColor Yellow
$entraClientId = Read-Host "`nEnter Entra App Registration Client ID" -AsSecureString
$entraClientSecret = Read-Host "`nEnter Entra App Registration Client Secret" -AsSecureString
$entraTenantId = Read-Host "`nEnter Entra Tenant ID" -AsSecureString
$azureSubscriptionId = Read-Host "`nEnter Azure Subscription ID" -AsSecureString
$vmUsername = Read-Host "`nEnter VM Username" -AsSecureString
$vmPassword = Read-Host "`nEnter VM Password" -AsSecureString
$githubPAT = Read-Host "`nEnter GitHub PAT" -AsSecureString
$iotClaim = Read-Host "`nEnter the claim password that will be used for the IoT device" -AsSecureString

#Storage Account creation
Write-Host "`nRun Azure Storage Account setup for backend services? (y/n)" -ForegroundColor Yellow
$saSetupPrompt = Read-Host " "
If ($saSetupPrompt -eq "y") {

    #Azure login
    Write-Host "`nLog into your Azure account" -ForegroundColor Yellow
    $azlogin = az login  | ConvertFrom-Json
    $azSubSet = az account set --subscription `
        "$(ConvertFrom-SecureString `
            -SecureString  $azureSubscriptionId `
            -AsPlainText `
          )" | ConvertFrom-Json

    #Create Storage Account resources
    Write-Host "`nCreating Resource Group" -ForegroundColor Yellow
    $rg = az group create `
        --name $terraformSaRgName `
        --location $region | ConvertFrom-Json

    Write-Host "`nCreating Storage Account" -ForegroundColor Yellow
    $sa = az storage account create `
        --name $terraformSaName `
        --resource-group $($rg.Name) `
        --location $($rg.location) `
        --sku Standard_LRS `
        --kind StorageV2 `
        --allow-blob-public-access false | ConvertFrom-Json

    Write-Host "`nCreating Blob Container" -ForegroundColor Yellow
    $container = az storage container create `
         --name $terraformSaContainerName `
         --account-name $($sa.name) `
         --resource-group $($rg.Name) `
         --auth-mode login
}

#GitHub Secrets and Variables
Write-Host "`nRun GitHub Secrets and Variables Setup? (y/n)" -ForegroundColor Yellow
$githubSetupPrompt = Read-Host " "
If ($githubSetupPrompt -eq "y") {

    #CD into repo that will need these secrets and vars
    $repoFolder = Read-Host "`nEnter folder path to the cloned local repo"
    Set-Location -Path $repoFolder

    #Log into GitHub via CLI
    Write-Host "`nGitHub Login" -ForegroundColor Yellow
    gh auth login --hostname GitHub.com

    #Set GitHub Secrets
    Write-Host "`nCreating GitHub Secrets" -ForegroundColor Yellow
    gh secret set ENTRA_CLIENT_ID --body "$(ConvertFrom-SecureString -SecureString  $entraClientId -AsPlainText)"
    gh secret set ENTRA_CLIENT_SECRET --body "$(ConvertFrom-SecureString -SecureString  $entraClientSecret -AsPlainText)"
    gh secret set ENTRA_TENANT_ID --body "$(ConvertFrom-SecureString -SecureString  $entraTenantId -AsPlainText)"
    gh secret set AZURE_SUBSCRIPTION_ID --body "$(ConvertFrom-SecureString -SecureString  $azureSubscriptionId -AsPlainText)"
    gh secret set VM_USERNAME --body "$(ConvertFrom-SecureString -SecureString  $vmUsername -AsPlainText)"
    gh secret set VM_PASSWORD --body "$(ConvertFrom-SecureString -SecureString  $vmPassword -AsPlainText)"
    gh secret set TERRAFORM_SA_RG_NAME --body "$($terraformSaRgName)"
    gh secret set TERRAFORM_SA_NAME --body "$($terraformSaName)"
    gh secret set TERRAFORM_SA_CONTAINER_NAME --body "$($terraformSaContainerName)"
    gh secret set GH_PAT --body "$(ConvertFrom-SecureString -SecureString  $githubPAT -AsPlainText)"
    gh secret set IOT_CLAIM --body "$(ConvertFrom-SecureString -SecureString  $iotClaim -AsPlainText)"

    # Set GitHub Variables
    Write-Host "`nCreating GitHub Variables" -ForegroundColor Yellow
    gh variable set PROJECT --body "$($project)"
    gh variable set REGION --body "$($region)"
}
