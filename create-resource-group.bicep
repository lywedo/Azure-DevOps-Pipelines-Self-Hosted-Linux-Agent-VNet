targetScope = 'subscription'

@description('The name of the resource group to create')
param resourceGroupName string

@description('The location of the resource group')
param location string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

output resourceGroupId string = resourceGroup.id
