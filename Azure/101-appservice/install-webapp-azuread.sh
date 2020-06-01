#!/bin/bash
# Parameter 1 resourceGroupName 
# Parameter 2 region 
# Parameter 3 prefixName 
# Parameter 4 azureADSubscriptionID 
# Parameter 5 azureSubscriptionID
# Parameter 6 aksVMSize
# Parameter 7 webAppSku
resourceGroupName=$1
region=$2
prefixName=$3 
tenantName=$4 
azureADSubscriptionID=$5
azureSubscriptionID=$6
webAppSku=$7

# ./install-webapp-azuread.sh TestNodeJSWebAppAzureADrg easus2 testnodewebapp M365x175592 faa1b9e5-22ff-4238-8fb5-5a4d73c49d47 e5c9fc83-fbd0-4368-9cb6-1b5823479b6d S1

#######################################################
#- function used to writelog in a log file
#######################################################
#############################################################################
WriteLog()
{
	echo "$1"
	echo "$1" >> ./install-webapp-azuread.log
}
#######################################################
#- function used to get first line in a text file
#######################################################
#############################################################################
function Get-FirstLine()
{
        local file=$1

        while read p; do
                echo $p
                return
        done < $file
		echo ''
}

#############################################################
#- function used to get the password value in a result file
#############################################################
function Get-Password()
{
	local file=$1

	while read p; do 
		echo $p
		declare -a array=($(echo $p | tr ':' ' '| tr ',' ' '| tr '"' ' '))
		if [ ${#array[@]} > 1 ]; then
		  	if [ ${array[0]} = "password" ]; then
				echo ${array[1]}
				return
			fi
		fi
	done < $file
	echo ''
}
#######################################################
#- function used to check OS 
#######################################################
#############################################################################
check_os() {
    grep ubuntu /proc/version > /dev/null 2>&1
    isubuntu=${?}
    grep centos /proc/version > /dev/null 2>&1
    iscentos=${?}
    grep redhat /proc/version > /dev/null 2>&1
    isredhat=${?}	
	if [ -f /etc/debian_version ]; then
    isdebian=0
	else
	isdebian=1	
    fi

	if [ $isubuntu -eq 0 ]; then
		OS=Ubuntu
		VER=$(lsb_release -a | grep Release: | sed  's/Release://'| sed -e 's/^[ \t]*//' | cut -d . -f 1)
	elif [ $iscentos -eq 0 ]; then
		OS=Centos
		VER=$(cat /etc/centos-release)
	elif [ $isredhat -eq 0 ]; then
		OS=RedHat
		VER=$(cat /etc/redhat-release)
	elif [ $isdebian -eq 0 ];then
		OS=Debian  # XXX or Ubuntu??
		VER=$(cat /etc/debian_version)
	else
		OS=$(uname -s)
		VER=$(uname -r)
	fi
	
	ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

	WriteLog "OS=$OS version $VER Architecture $ARCH"
}
if [ -z "$resourceGroupName" ]; then
   WriteLog 'resourceGroupName not set'
   exit 1
fi
if [ -z "$region" ]; then
   WriteLog 'region not set'
   exit 1
fi
if [ -z "$prefixName" ]; then
   WriteLog 'prefixName not set'
   exit 1
fi
if [ -z "$tenantName" ]; then
   WriteLog 'tenantName not set'
   exit 1
fi
if [ -z "$azureADSubscriptionID" ]; then
   WriteLog 'Azure AD SubscriptionID not set'
   exit 1
fi
if [ -z "$azureSubscriptionID" ]; then
   WriteLog 'Azure SubscriptionID not set'
   exit 1
fi
if [ -z "$webAppSku" ]; then
   WriteLog 'Web App Sku not set'
   exit 1
fi

environ=`env`
WriteLog "Environment before installation: $environ"

WriteLog "Installation script is starting for resource group: $resourceGroupName with prefixName: $prefixName cpu: $cpuCores memory: $memoryInGb AKS VM Size: $aksVMSize and AKS node count: $aksNodeCount"
check_os
if [ $iscentos -ne 0 ] && [ $isredhat -ne 0 ] && [ $isubuntu -ne 0 ] && [ $isdebian -ne 0 ];
then
    WriteLog "unsupported operating system"
    exit 1 
else

## azureADSubscriptionID = 'faa1b9e5-22ff-4238-8fb5-5a4d73c49d47'
## azureSubscriptionID = 'e5c9fc83-fbd0-4368-9cb6-1b5823479b6d'
appName=$prefixName'web'
appUri='https://'$appName'.azurewebsites.net/'
dnsName=$appName'.azurewebsites.net'
appGuid='12345678-34cd-498f-9d9f-123456781237'
appGuid=`uuidgen`
apiUri='api://'$appGuid 
appRedirectUri=$appUri'signin-oidc'
appDeploymentName=$appName'dep'

## githubrepo = 'https://github.com/flecoqui/TestNodeJSWebAppAzureAD.git'
## githubbranch = 'master'


WriteLog "Installation script is starting for resource group: "$resourceGroupName" with prefixName: "$prefixName" azureADSubscriptionID: "$azureADSubscriptionID 
WriteLog "Login to Azure AD"
WriteLog "az login"
az login
WriteLog "az account set --subscription "$azureADSubscriptionID
az account set --subscription $azureADSubscriptionID
echo  '[{ "additionalProperties": null,"resourceAccess": [{"additionalProperties": null, "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d", "type": "Scope"}],"resourceAppId": "00000003-0000-0000-c000-000000000000"}]' > ./manifestaccess.json

## WriteLog "Removing the Application"
## WriteLog "az ad app delete --id "$appGuid
### az ad app delete --id $apiUri

WriteLog "Registering Application for id: "$appGuid
WriteLog "az ad app create --id "$appGuid"  --display-name "$appName" --native-app false --identifier-uris "$apiUri" --reply-urls "$appRedirectUri" --required-resource-accesses '@manifestaccess.json' --oauth2-allow-implicit-flow true --available-to-other-tenants true "
az ad app create  --id $appGuid --display-name $appName  --native-app false --identifier-uris  $apiUri --reply-urls $appRedirectUri --required-resource-accesses '@manifestaccess.json' --oauth2-allow-implicit-flow true --available-to-other-tenants true 
WriteLog "az ad app update --id "$apiUri" --set logoutUrl="$appUri
az ad app update --id $apiUri --set logoutUrl=$appUri
WriteLog "az ad app show --id "$apiUri" --query appId --output tsv > appid.txt"
az ad app show --id $apiUri --query appId --output tsv > appid.txt
appID=$(Get-FirstLine ./appid.txt) 
# appID=$appID.replace("`n","").replace("`r","")
az ad app credential reset --id $apiUri --append  --output tsv > apppassword.txt
appPassword=$(Get-Password ./apppassword.txt) 
WriteLog "Parameters to deploy the Web App - AppId: "$appID" Password: "$appPassword" apiUri: "$apiUri" redirectUri: "$appRedirectUri" logoutUri: "$appUri
read -p "Press any key to continue"


WriteLog "Login to Azure Subscription"
WriteLog "az login"
az login
WriteLog "az account set --subscription "$azureSubscriptionID
az account set --subscription $azureSubscriptionID

WriteLog "Creating Resource Group: $resourceGroupName"
WriteLog 
az group create \
    --subscription $azureSubscriptionID \
    --name $resourceGroupName \
    --location $region \
    --output table

WriteLog "Installation script is starting for resource group: "$resourceGroupName" with prefixName: "$prefixName 
WriteLog "Creating Web App supporting Azure AD Authentication" 
WriteLog "az deployment group create -g "$resourceGroupName" -n "$appDeploymentName" --template-file azuredeploy.json --parameter namePrefix="$prefixName" webAppSku="$webAppSku" configClientID="$appID" configTenantName="$tenantName" configRedirectUrl="$appRedirectUri" configSignOutUrl="$appUri"   configClientSecret="$appPassword"    --verbose -o json "
az deployment group create -g $resourceGroupName -n $appDeploymentName --template-file azuredeploy.json --parameter namePrefix=$prefixName webAppSku=$webAppSku   configTenantName=$tenantName configRedirectUrl=$appRedirectUri configSignOutUrl=$appUri    configClientID=$appID configClientSecret=$appPassword   --verbose -o json 
WriteLog "az deployment group show -g "$resourceGroupName" -n "$appDeploymentName" --query properties.outputs"
az deployment group show -g $resourceGroupName -n $appDeploymentName --query properties.outputs

WriteLog "Public DNS Name: " $dnsName

WriteLog "curl -d '{\""name\"":\""0123456789\""}' -H \""Content-Type: application/json\""  -X POST   http://"$dnsName"/api/values"

writeLog "Open the following url with your browser to test the authentication: https://"$dnsName"/"
WriteLog "Installation completed !" 


fi
exit 0 
