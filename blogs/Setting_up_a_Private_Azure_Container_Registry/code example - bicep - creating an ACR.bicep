resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'acrabc123' // must be globally unique
  location: 'usgovvirginia' // must be a valid Azure location
  tags: {
    environment: 'production'
  } // must be a map of strings, optional but good to establish a tagging strategy
  sku: {
    name: 'Premium' // is one of: Basic, Standard, Premium, Classic.  NOTE: Must use premium to establish private endpoints.
  }
  identity: {
    type: 'SystemAssigned'
  } 
  properties: {
    adminUserEnabled: false // if true then the name of the ACR is the username to access the ACR
    publicNetworkAccess: 'disabled' // we are going to use private endpoints to make the connections
    zoneRedundancy: 'disabled' // choose your zone strategy
    networkRuleBypassOptions: 'AzureServices' // One of AzureServiecs, none.  Allow trusted Azure services to access a network restricted registry
    policies: {
      retentionPolicy: {
        days: 7
        status: 'enabled'
      }
    }
  }
}
