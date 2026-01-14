@description('The name of the Azure AI Search service')
param searchServiceName string

@description('Location for Azure AI Search')
param location string = resourceGroup().location

@description('Tags to apply to Azure AI Search resources')
param tags object = {}

@description('The resource ID of the managed identity')
param managedIdentityId string

@description('The principal ID of the managed identity')
param managedIdentityPrincipalId string

resource searchService 'Microsoft.Search/searchServices@2024-03-01-preview' = {
  name: searchServiceName
  location: location
  tags: tags
  sku: {
    name: 'basic'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    networkRuleSet: {
      ipRules: []
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    disableLocalAuth: false
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}

var searchIndexDataContributorRoleId = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  name: guid(searchService.id, managedIdentityPrincipalId, searchIndexDataContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      searchIndexDataContributorRoleId
    )
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('The resource ID of the Azure AI Search service')
output searchServiceId string = searchService.id

@description('The name of the Azure AI Search service')
output searchServiceName string = searchService.name

@description('The endpoint of the Azure AI Search service')
output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'
