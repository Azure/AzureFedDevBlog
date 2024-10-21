@description('User Assigned Identity id value in the format /subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}')
param userAssignedIdentity string

@description('Name of the container group')
param containerGroupName string

@description('Location for all resources.')
param location string

@description('Name of the container')
param containerName string

@description('Image for the container to pull on start in the form of <registry>/<image>:<tag>')
param containerImage string

@description('CPU count for the container')
param containerCpuCount int

@description('Memory count for the container in GB')
param containerMemoryCount int

@description('Azure DevOps URL in the format https://dev.azure.com/{collection}')
param AzDO_URL string

@description('Azure DevOps PAT')
@secure()
param AzDO_TOKEN string

@description('Azure DevOps Agent Name')
param AzDO_AGENT_NAME string

@description('Azure DevOps Agent Pool')
param AzDO_POOL string

@description('Subnet ID for the container instance')
param Subnet_ID string

@description('DNS Servers for the container instance')
param DNS_Servers array

@description('DNS Search Domain for the container instance')
param DNS_Search_Domain string

@description('Azure Container Registry Login Server URL')
param ACR_LOGIN_SERVER string

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity}': {}
    }
  }
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: containerImage
          ports: [
            {
              port: 443
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: containerCpuCount
              memoryInGB: containerMemoryCount
            }
          }
          environmentVariables: [
            {
              name: 'AZP_URL'
              value: AzDO_URL
            }
            {
              name: 'AZP_TOKEN'
              value: AzDO_TOKEN
            }
            {
              name: 'AZP_AGENT_NAME'
              value: AzDO_AGENT_NAME
            }
            {
              name: 'AZP_POOL'
              value: AzDO_POOL
            }
            {
              name: 'FEED_ACCESSTOKEN'
              value: AzDO_TOKEN
            }
          ]
        }
      }
    ]
    imageRegistryCredentials: [
      {
        server: ACR_LOGIN_SERVER
        identity: userAssignedIdentity
      }
    ]
    ipAddress: {
      ports: [
        {
          port: 443
          protocol: 'TCP'
        }
      ]
      type: 'private'
    }
    subnetIds: [
      {
        id: Subnet_ID
      }
    ]
    osType: 'Linux'
    dnsConfig: {
      nameServers: DNS_Servers
      
      searchDomains: DNS_Search_Domain
    }
  }
}
