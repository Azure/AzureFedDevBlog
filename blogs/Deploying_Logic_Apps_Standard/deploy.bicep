metadata moduleinfo = {
  license: 'Copyright 2024 Microsoft - Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: - The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. - THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
  summary: 'Deploys an Azure Logic App Standard SKU with private networking and using a User Assigned Managed Identity for storage access.'
  author: 'joscot'
  version: '1.0.0'
  source: 'https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference'
  parent: 'Microsoft.Web'
  group: 'core/modules'
}
/* ********************************************************************************
 * IMPORTANT
 *
 * This template assumes the following resources are already deployed:
 *
  * - A V2 storage account has been created for hosting the workflow app
  * - A virtual network and subnets for private endpoints and VNet Integration has been created
  * - Private endpoints and private DNS records have been created to point to the storage account 
  * - blob, queue and table endpoints 
  * - A user-assigned Managed Identity has been created for storage access and has been granted the following RBAC roles in the storage account:
   *   - Storage Account Contributor 
   *   - Storage Blob Data Contributor
   *   - Storage Queue Data Contributor 
   *   - Storage Table Data Contributor 
 *
 *
 ******************************************************************************** */

/* ********************************************************************************
 * PARAMETERS
 *
 * Used to control the deployment of this environment.
 *
 * ********************************************************************************/

param subscriptionId string 
param logicAppName string 
param location string
param hostingPlanName string 
param vnetPrivatePortsCount int = 2
param resourceGroupName string 
param userAssignedIdentity string
param appInsightsKey string
param vNetResourceGroupName string
param vNetName string
param peSubnetName string
param vNetIntegrationSubnetName string
param storageAccountName string

//Params for App Service Plan/App Service
param use32BitWorkerProcess bool = false
param netFrameworkVersion string = 'v6.0'
param sku string = 'WorkflowStandard'
param skuCode string = 'WS1'
param workerSize string = '3'
param workerSizeId string = '3'
param numberOfWorkers string = '1'
param ftpsState string = 'ftpsOnly'
  

resource logicApp 'Microsoft.Web/sites@2022-03-01' = {
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity}': {}
    }
  }
  name: logicAppName
  kind: 'functionapp,workflowapp'
  location: location
  tags: {}
  properties: {
    name: logicAppName
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsightsKey};EndpointSuffix=applicationinsights.us;IngestionEndpoint=https://usgovvirginia-1.in.applicationinsights.azure.us/;AADAudience=https://monitor.azure.us/;ApplicationId=5ab96a4f-b72d-419b-b0d3-a4e3e4a78162'
        }
        {
          name: 'AzureWebJobsStorage__blobServiceUri'
          value: 'https://${storageAccountName}.blob.core.usgovcloudapi.net'
        }
        {
          name: 'AzureWebJobsStorage__queueServiceUri'
          value: 'https://${storageAccountName}.queue.core.usgovcloudapi.net'
        }
        {
          name: 'AzureWebJobsStorage__tableServiceUri'
          value: 'https://${storageAccountName}.table.core.usgovcloudapi.net'
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccountName
        }
        { 
          name: 'AzureWebJobsStorage__credential'
          value: 'managedidentity' 
        }
        { 
          name: 'AzureWebJobsStorage__managedIdentityResourceId'
          value: userAssignedIdentity
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
      ]
      cors: {}
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      vnetPrivatePortsCount: vnetPrivatePortsCount
      netFrameworkVersion: netFrameworkVersion
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: '/subscriptions/${subscriptionId}/resourceGroups/${vNetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vNetName}/subnets/${vNetIntegrationSubnetName}'
    //functionsRuntimeAdminIsolationEnabled: false
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true
    httpsOnly: true
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${resourceGroupName}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
  }
  dependsOn: [
    hostingPlan
  ]
}

resource name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: logicApp
  name: 'scm'
  properties: {
    allow: false
  }
}

resource name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  parent: logicApp
  name: 'ftp'
  properties: {
    allow: false
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  tags: {}
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    maximumElasticWorkerCount: '20'
    zoneRedundant: false
  }
  sku: {
    tier: sku
    name: skuCode
  }
  dependsOn: []
}

resource wf_pep 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'wf-pep'
  location: location
  properties: {
    subnet: {
      id: '/subscriptions/${subscriptionId}/resourceGroups/${vNetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vNetName}/subnets/${peSubnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: 'wf-pep'
        properties: {
          privateLinkServiceId: logicApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}
