
#usage install-webapp-azuread-windows.ps1 resourceGroupName prefixName tenantName azureADSubscriptionID azureSubscriptionID webAppSku 
# az group create -n TestNodeJSWebAppAzureADrg -l eastus2
# install-webapp-azuread-windows.ps1 TestNodeJSWebAppAzureADrg testnodewebapp M365x175592 faa1b9e5-22ff-4238-8fb5-5a4d73c49d47 e5c9fc83-fbd0-4368-9cb6-1b5823479b6d S1

param
(
      [string]$resourceGroupName = $null,
      [string]$prefixName = $null,
      [string]$tenantName = $null,
      [string]$azureADSubscriptionID = $null,
      [string]$azureSubscriptionID = $null,
      [string]$webAppSku = $null
)
function WriteLog($msg)
{
Write-Host $msg
$msg >> install-webapp-azuread-windows.log
}

if($prefixName -eq $null) {
     WriteLog "Installation failed prefixName parameter not set "
     throw "Installation failed prefixName parameter not set "

}
if($resourceGroupName -eq $null) {
     WriteLog "Installation failed resourceGroupName parameter not set "
     throw "Installation failed resourceGroupName parameter not set "
}
if($tenantName -eq $null) {
     WriteLog "Installation failed Azure AD tenantName parameter not set "
     throw "Installation failed Azure AD tenantName parameter not set "

}
if($azureADSubscriptionID -eq $null) {
     WriteLog "Installation failed azureADSubscriptionID parameter not set "
     throw "Installation failed azureADSubscriptionID parameter not set "
}

if($webAppSku -eq $null) {
     WriteLog "Installation  WebAppSku parameter not set, set to S1 "
     $webAppSku='S1'
}

if($azureSubscriptionID -eq $null) {
     WriteLog ("Installation azureSubscriptionID parameter not set, set to  " + $azureADSubscriptionID)
}

function WriteLog($msg)
{
    Write-Host $msg
    $msg >> install-webapp-azuread-windows.log
}
function Get-Password($file)
{
    foreach($line in (Get-Content $file  ))
    {
	    $nline = $line.Split(':", ',[System.StringSplitOptions]::RemoveEmptyEntries)
	    if($nline.Length -gt 1) 
	    {
  	    if($nline[0] -eq "password")
  	        {
		        return $nline[1]
      		        break
  	        }
  	    }
    }
    return $null
}
function Get-PublicIP($file)
{
    foreach($line in (Get-Content $file  ))
    {
	    $nline = $line.Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries)
	    if($nline.Length -gt 3) 
	    {
  	    if($nline[1] -eq "LoadBalancer")
  	        {
		        return $nline[3]
      		        break
  	        }
  	    }
    }
    return $null
}
#$azureADSubscriptionID = 'faa1b9e5-22ff-4238-8fb5-5a4d73c49d47'
#$azureSubscriptionID = 'e5c9fc83-fbd0-4368-9cb6-1b5823479b6d'
$appName = $prefixName + "web"
$appUri = "https://" + $appName + ".azurewebsites.net/"
$dnsName = $appName + ".azurewebsites.net"
$appGuid = '12345678-34cd-498f-9d9f-123456781237'
$appGuid = [guid]::NewGuid()
$apiUri = "api://" + $appGuid 
$appRedirectUri = $appUri + "signin-oidc"
$appDeploymentName =$appName + "dep"
#$githubrepo = 'https://github.com/flecoqui/TestNodeJSWebAppAzureAD.git'
#$githubbranch = 'master'

WriteLog ("Installation script is starting for resource group: " + $resourceGroupName + " with prefixName: " + $prefixName + " azureADSubscriptionID: " + $azureADSubscriptionID )
WriteLog ("Login to Azure AD")
WriteLog ("az login")
az login
WriteLog ("az account set --subscription " +  $azureADSubscriptionID)
az account set --subscription $azureADSubscriptionID
Write-Output  '[{ "additionalProperties": null,"resourceAccess": [{"additionalProperties": null, "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d", "type": "Scope"}],"resourceAppId": "00000003-0000-0000-c000-000000000000"}]' > ./manifestaccess.json
#WriteLog ("Removing the Application (if exists)")
#WriteLog ("az ad app delete --id " + $appGuid)
#az ad app delete --id $apiUri
WriteLog ("Registering Application for id: " + $appGuid)
WriteLog ("az ad app create --id " + $appGuid + "  --display-name " + $appName +" --native-app false --identifier-uris " + $apiUri + " --reply-urls " + $appRedirectUri + " --required-resource-accesses '@manifestaccess.json' --oauth2-allow-implicit-flow true --available-to-other-tenants true ")
az ad app create  --id $appGuid --display-name $appName  --native-app false --identifier-uris  $apiUri --reply-urls $appRedirectUri --required-resource-accesses '@manifestaccess.json' --oauth2-allow-implicit-flow true --available-to-other-tenants true 
WriteLog ("az ad app update --id " + $apiUri + " --set logoutUrl=" + $appUri)
az ad app update --id $apiUri --set logoutUrl=$appUri
WriteLog ("az ad app show --id " + $apiUri + " --query appId --output tsv > appid.txt")
az ad app show --id $apiUri --query appId --output tsv > appid.txt
$appID = Get-Content .\appid.txt -Raw 
$appID = $appID.replace("`n","").replace("`r","")
az ad app credential reset --id $apiUri --append  > apppassword.txt
$appPassword  = Get-Password .\apppassword.txt 
WriteLog ("Parameters to deploy the Web App - AppId: " + $appID + " Password: " + $appPassword + " apiUri: " + $apiUri + " redirectUri: " + $appRedirectUri + " logoutUri: " + $appUri)
pause


WriteLog ("Login to Azure Subscription")
WriteLog ("az login")
az login
WriteLog ("az account set --subscription " +  $azureSubscriptionID)
az account set --subscription $azureSubscriptionID

WriteLog ("Installation script is starting for resource group: " + $resourceGroupName + " with prefixName: " + $prefixName )
WriteLog ("Creating Web App supporting Azure AD Authentication") 
WriteLog ("az deployment group create -g " + $resourceGroupName + " -n " + $appDeploymentName + " --template-file azuredeploy.json --parameter namePrefix="+$prefixName+" webAppSku="+$webAppSku+" configClientID=" + $appID + " configClientSecret=" + $appPassword + "  configTenantName=" + $tenantName + " configRedirectUrl=" + $appRedirectUri + " configSignOutUrl=" + $appUri + "   --verbose -o json ")
az deployment group create -g $resourceGroupName -n $appDeploymentName --template-file azuredeploy.json --parameter namePrefix=$prefixName webAppSku=$webAppSku   configClientSecret=$appPassword  configTenantName=$tenantName configRedirectUrl=$appRedirectUri configSignOutUrl=$appUri    configClientID=$appID --verbose -o json 
WriteLog ("az deployment group show -g " + $resourceGroupName + " -n " + $appDeploymentName + " --query properties.outputs")
az deployment group show -g $resourceGroupName -n $appDeploymentName --query properties.outputs

WriteLog ("Public DNS Name: " +$dnsName) 

writelog ("curl -d '{""name"":""0123456789""}' -H ""Content-Type: application/json""  -X POST   http://" + $dnsName + "/api/values")

writelog ("Open the following url with your browser to test the authentication: https://" + $dnsName + "/")

WriteLog "Installation completed !" 

