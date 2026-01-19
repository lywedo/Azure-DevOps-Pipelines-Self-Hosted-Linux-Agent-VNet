targetScope = 'resourceGroup'

param vnetName string

param location string = resourceGroup().location

param subnetPrefix string

param subnetName string

// Not used when referencing existing VNet, but kept for backwards compatibility
param addressPrefixes array = []

// Set to true to use an existing VNet instead of creating a new one
param useExistingVnet bool = true

var delegationName = 'aciVnetDelegation'

// Reference existing VNet (does not modify the VNet itself, preserves all existing subnets)
resource existingVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = if (useExistingVnet) {
  name: vnetName
}

// Create new VNet only if useExistingVnet is false
resource newVnet 'Microsoft.Network/virtualNetworks@2024-01-01' = if (!useExistingVnet) {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
  }
}

// Add subnet to the VNet (works with both existing and new VNet)
// This only creates/updates this specific subnet, does NOT affect other subnets
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: subnetName
  parent: existingVnet
  properties: {
    addressPrefix: subnetPrefix
    delegations: [
      {
        name: delegationName
        properties: {
          serviceName: 'Microsoft.ContainerInstance/containerGroups'
        }
      }
    ]
  }
}

output subnetId string = subnet.id
