@description('The name of the managed identity')
param managedIdentityName string

@description('Location for the managed identity')
param location string = resourceGroup().location

@description('Tags to apply to the managed identity')
param tags object = {}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tags
}

@description('The resource ID of the managed identity')
output managedIdentityId string = managedIdentity.id

@description('The principal ID of the managed identity')
output principalId string = managedIdentity.properties.principalId

@description('The client ID of the managed identity')
output clientId string = managedIdentity.properties.clientId

@description('The name of the managed identity')
output name string = managedIdentity.name
