param AzureRegionName string = 'usgovvirginia'

resource pe 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-acrabc123'
  location: AzureRegionName
  properties: {
    subnet: {
      id: pSubnetResourceId
    }
    ipConfigurations: [
      {
        name: 'acr-cfg-acrabc123'
        properties: {
          privateIPAddress: pAcrPrivateIpAddress
          groupId: 'registry'
          memberName: 'registry'
        }
      }
      {
        name: 'acrdata-cfg-acrabc123'
        properties: {
          privateIPAddress: pAcrDataPrivateIpAddress
          groupId: 'registry'
          memberName: 'registry_data_usgovvirginia'
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: 'pls-acrabc123'
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
  }
