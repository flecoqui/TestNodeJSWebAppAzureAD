# Deployment of a Web App  hosted on Azure App Service

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fflecoqui%2FTestNodeJSWebAppAzureAD%2Fmaster%2FAzure%2F101-appservice%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fflecoqui%2FTestNodeJSWebAppAzureAD%2Fmaster%2FAzure%2F101-appservice%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy from Github a Node JS based Web Application hosted on Azure App Service. Moreover, the Web Application will be directly deployed from github towards Azure App Service.

# DEPLOYING THE WEB APP ON AZURE APP SERVICE

## PRE-REQUISITES
First you need an Azure subscription.
You can subscribe here:  https://azure.microsoft.com/en-us/free/ . </p>
Moreover, we will use Azure CLI v2.0 to deploy the resources in Azure.
You can install Azure CLI on your machine running Linux, MacOS or Windows from here: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest 



## CREATE RESOURCE GROUP:
First you need to create the resource group which will be associated with this deployment. For this step, you can use Azure CLI v1 or v2.

* **Azure CLI 1.0:** azure group create "ResourceGroupName" "RegionName"

* **Azure CLI 2.0:** az group create an "ResourceGroupName" -l "RegionName"

For instance:

    azure group create TestNodeJSWebAppAzureADrg eastus2

    az group create -n TestNodeJSWebAppAzureADrg -l eastus2

## DEPLOY THE SERVICES:

### DEPLOY WEB APP ON APP SERVICE:
You can deploy Azure Function, Azure App Service and Virtual Machine using ARM (Azure Resource Manager) Template and Azure CLI v1 or v2

* **Azure CLI 1.0:** azure group deployment create "ResourceGroupName" "DeploymentName"  -f azuredeploy.json -e azuredeploy.parameters.json*

* **Azure CLI 2.0:** az group deployment create -g "ResourceGroupName" -n "DeploymentName" --template-file "templatefile.json" --parameters @"templatefile.parameter..json"  --verbose -o json

For instance:

    azure deployment group create TestNodeJSWebAppAzureADrg TestNodeJSWebAppAzureADdep -f azuredeploy.json -e azuredeploy.parameters.json -vv

    az deployment group create -g TestNodeJSWebAppAzureADrg -n TestNodeJSWebAppAzureADdep --template-file azuredeploy.json --parameter @azuredeploy.parameters.json --verbose -o json


When you deploy the service you can define the following parameters:</p>
* **namePrefix:** The name prefix which will be used for all the services deployed with this ARM Template</p>
* **WebAppSku:** The WebApp Sku Capacity, by default F1</p>
* **repoURL:** The github repository url</p>
* **repoAppPath:** The github relative path to the App Service to deploy</p>
* **branch:** The branch name in the repository</p>
* **configClientID:** The Client ID used for the Azure AD Authentication</p>
* **configClientSecret:** The Client Secret used for the Azure AD Authentication</p>
* **configTenantName:** The Tenant Name used for the Azure AD Authentication</p>
* **configRedirectUrl:** TheRedirect Url used for the Azure AD Authentication</p>
* **configSignOutUrl:** The SignOut Url used for the Azure AD Authentication</p>


All the parameters required for the Azure AD authentication can be automatically created using the following script or bash files:
* **Windows Powershell:** install-webapp-azuread-windows.ps1 </p>
* **Linux Bash:** install-webapp-azuread.sh </p>

Those files are called using the following parameters:
* **Azure resource group :** The Azure Resource group where the App Service will be deployed</p>
* **Azure region :** The Azure Region where the resources wil be deployed</p>
* **namePrefix:** The name prefix which will be used for all the services deployed with this ARM Template</p>
* **Tenant Name:** The Tenant Name for the authentication TenantNagitme.onmicrosoft.com </p>
* **Azure Subscription ID for Azure AD:** The Azure Subscription ID associated with the Azure AD used for the authentication </p>
* **Azure Subscription ID for Azure App Service:** The Azure Subscription ID associated with the App Serivce  </p>
* **WebAppSku:** The WebApp Sku Capacity, by default F1</p>

For instance:

.\install-webapp-azuread-windows.ps1 TestNodeJSWebAppAzureADrg eastus2 testnodewebapp M365x175592 faa1b9e5-22ff-4238-8fb5-5a4d73c49d47 e5c9fc83-fbd0-4368-9cb6-1b5823479b6d S1

./install-webapp-azuread-windows.sh TestNodeJSWebAppAzureADrg eastus2 testnodewebapp M365x175592 faa1b9e5-22ff-4238-8fb5-5a4d73c49d47 e5c9fc83-fbd0-4368-9cb6-1b5823479b6d S1


Those scripts required two authentication phases one with the Azure  Subscription ID associated with the Azure AD and one with the Azure Subscription ID associated with the App Service. 

# TEST THE WEB APP:

## TEST THE WEB APP WITH YOUR INTERNET BROWSER

* **1.** Open the url:  https://<namePrefix>web.azurewebsites.net/ 
* **2.** Click on the "Log In" link
* **3.** Enter your Azure AD credentials
* **4.** Once you are authentified you can click on the Account link to display the claims related to your accont.
* **5.** Click on the "Log Out" link
</p>


# DELETE THE WEB APP 


## DELETE THE RESOURCE GROUP:

* **Azure CLI 1.0:**      azure group delete "ResourceGroupName" "RegionName"

* **Azure CLI 2.0:**  az group delete -n "ResourceGroupName" "RegionName"

For instance:

    azure group delete TestNodeJSWebAppAzureADrg eastus2

    az group delete -n TestNodeJSWebAppAzureADrg 


# Next Steps

1. Integration with Web Api integrated with Azure AD   
