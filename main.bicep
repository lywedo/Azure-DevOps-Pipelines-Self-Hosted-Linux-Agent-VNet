targetScope = 'subscription'

@description('The Name of the ACI Container Group')
param containerGroupName string = 'adoshagent'

@description('Number of Self-Hosted Agent Containers to create')
param numberOfInstances int = 2

@description('Name of the Image to be pulled or created in the Registry')
param Image string = 'adoshagent'

@description('Image Version Tag')
param imageVersion string = 'latest'

@description('URL to the DevOps Org')
param ADO_Account string 

@description('Pool name for the Self-Hosted Agents in ADO')
param ADO_Pool string = 'SelfHostedACI'

@description('Name of the VNET to connect the agent containers')
param vnetName string 

@description('Name of the Resource Group containing the VNET')
param vnetRGName string 

@description('Name of the subnet in the VNET to connect the agent containers')
param subnetName string  

@description('Subnet CIDR prefix for the Container Instance subnet')
param subnetPrefix string 

@description('Number of cores assigned to each container instance')
param agentCPU int = 1

@description('The amount of Memory in GB for each container instance')
param agentMem int = 3

@description('Name of the Container Registry')
param containerRegistryName string 

@description('Resource Group of the Container Registry')
param containerRegistryRG string 

@description('Container Registry SKU')
param registrySKU string = 'Basic'

@description('Deployment Region')
param location string

@description('Name of the Key Vault')
param patToken string

@description('current repo branch if building container through source control in this template')
param sourceBranch string = 'master'

@description('URI to the code repository with the Dockerfile - define or change if forked')
param dockerSourceRepo string = 'https://github.com/everazurerest/aci-pipelines-agent-linux.git'

module vnetRG 'create-resource-group.bicep' = {
  name: 'VNetResourceGroupDeployment'
  scope: subscription()
  params: {
    resourceGroupName: vnetRGName
    location: location
  }
}

module registryRG 'create-resource-group.bicep' = if(containerRegistryRG != vnetRGName) {
  name: 'RegistryResourceGroupDeployment'
  scope: subscription()
  params: {
    resourceGroupName: containerRegistryRG
    location: location
  }
}

module network 'network.bicep' = {
  name: 'NetworkDeployment'
  scope: resourceGroup(vnetRGName)
  params: {
    vnetName: vnetName
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    location: location
  }
  dependsOn: [
    vnetRG
  ]
}

module registry 'registry.bicep' = {
  name: 'RegistryDeployment'
  scope: resourceGroup(containerRegistryRG)
  params: {
    containerRegistryName: containerRegistryName
    registrySku: registrySKU
    location: location
    dockerSourceRepo: dockerSourceRepo
    branch: sourceBranch
    image: Image
    imageVersion: imageVersion
  }
  dependsOn: containerRegistryRG == vnetRGName ? [vnetRG] : [registryRG]
}

module containerGroupDeployment 'containers.bicep' = [for i in range(0, numberOfInstances): {
  name: 'containerDeployment-${i}'
  scope: resourceGroup(containerRegistryRG)
  params: {
    containerGroupName: '${containerGroupName}${i}'
    location: location
    image: registry.outputs.image
    ADO_Account: ADO_Account
    AZP_Token: patToken
    ADO_Pool: ADO_Pool
    subnetId: network.outputs.subnetId
    agentCPU: agentCPU
    agentMem: agentMem
    containerRegistryName: containerRegistryName
    containerRegistryRG: containerRegistryRG
  }
  dependsOn: [
    registry
    network
  ]
}]



