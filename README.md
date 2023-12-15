
# Azure Automation via IoT Device Integration

This is an example project demonstrating how integrations can be used to automate Azure-related resource creation and management. In this demo, I will be using a physical IoT Wifi button that interacts with Azure IoT Hub in order to trigger automation building an Azure VM I will use for my security workflows. 

> I purposely left certain information exposed in the Action logs so people can see more details for learning purposes. I have already remove or updated all of the Azure resources, IPs, and other pieces of data. 

This project will have three parts:
- Initial setup
- Backend setup
- VM deployment

This project will use the following technology:
- GitHub Actions
- TeXXmo IoT Wifi Button
- PowerShell 7.2
- Terraform
- Ansible
- Microsoft Azure
    - Application Insights
    - Bastion
    - Entra App Registration    
    - Function Apps    
    - IoT Hub
    - Key Vault
    - Log Analytics Workspace
    - Network Security Group
    - Storage Account
    - Virtual Network
    - Virtual Machine

## Initial Setup

> These initial tasks just need to be run once at the very beginning of the project in order to set up some dependencies. 

- In your Azure Subscription, create an [Entra App Registration Service Principal](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app). Give that service principal proper access in your subscription to build resources and add resources to Azure role assignments.

- Fork this GitHub repo to your own GitHub account. 

- In your GitHub account, setup a classic [Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic). The following scopes must be defines on the token when created:
    - Repo (all)
    - Read:org
    - Read:user

- Gather the following information below:
    - Entra ID App Registration client ID
    - Entra ID App Registration client secret
    - Entra Tenant ID
    - Azure Subscription Id
    - Username you would like to use for the VM we will create
    - Password you would like to use for the VM we will create
    - The Personal Access Token (PAT) for your GitHub account
    - A string of your choice that will be used by the IoT device sent to the Azure Function that will work like a claim password

- An initial Resource Group and Storage Account will need to be created in order to hold the Terraform state files. We will also need to populate your GitHub Repo with needed Action Secrets and Variables. Use the script [initial_setup.ps1](https://github.com/CityHallin/azure_cityhallin_secvm/blob/main/1-setup/initial_setup.ps1) to help with this process. The script will ask for you to enter the information you saved above. It will then prompt you to create the initial Azure and Github resources. For the GitHub portion, it will ask you to log into your GitHub account. The recommendation is to use HTTP, select "N" for Git authentication, and use your PAT you created earlier. 

## Backend setup

> These backend steps just need to be run once in order to setup the automation infrastructure. 

- Once the initial setup is complete, go into your GitHub account > your forked repo > Actions > click on **Deploy Backend Security VM Infrastructure**. Click on the **Run Workflow** button on the right and select **Run Workflow**. THis will create all of the backend resources for you. 
The Deploy Backend Security VM Infrastructure GitHub Action will take about 4-6 minutes to run and complete setting up all of the needed backend infrastructure. 

<img src="./readme_files/backend_cicd.png" width="800px">
<br />

- Once finished, you should see a new Resource Group called **secvm_backend** with all of your backend resources ready to go. 

<img src="./readme_files/backend_az_resources.png" width="600px">
<br />

- In your Azure Subscription, navigate to your IoT Hub resource and copy down the following information that will be used to configure your TexXXmo IoT physical device:
    - Azure IoT Hub FQDN Hostname
    - Azure IoT Hub Device Name
    - Azure IoT Hub Device Primary Key

## VM deployment

<img src="./readme_files/demo.gif" width="800px">
<br />

- Once the IoT button device is configured with your Azure IoT Hub information, you are ready to build your security VM from the automation.
    - Click the IoT button which will use your Wifi and send an HTTP event to the Azure IoT Hub. 
    - The Azure Function App will be monitoring an event service on the IoT Hub. Once it sees a new event from the IoT device, that will trigger the Azure Function. 
    - The Azure Function checks the claim secret sent by the IoT device is correct and then sends a webhook to the **Deploy Security VM** GitHub Action in your forked GitHub repo
    - **Deploy Security VM** GitHub Action uses Terraform and Ansible to deploy the VM, configure the VM with some applications, and an Azure Bastion service to remotely access the VM. 

- Since this is using Infrastructure as code (IaC), any future button clicks will just enforce everything for the VM is configured correctly via [Idempotence](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code#avoid-manual-configuration-to-enforce-consistency).

- If the VM is no longer needed, just the VM can be deleted in the Azure portal to save on cost. Once the VM is needed again, click the IoT button. The **Deploy Security VM** GitHub Action will only re-create VM resources that are not there. 
