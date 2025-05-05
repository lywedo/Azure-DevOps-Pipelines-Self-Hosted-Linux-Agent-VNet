targetScope = 'resourceGroup'

param vnetName string

param location string = resourceGroup().location

param subnetPrefix string

param subnetName string

var delegationName = 'aciVnetDelegation'

// resource vnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
//   name: vnetName
// }
resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
  
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetPrefix
    delegations: [
      {
        name: delegationName
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
      }
    ]
  }
  
}

output subnetId string = subnet.id
