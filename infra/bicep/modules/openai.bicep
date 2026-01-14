@description('The name of the Azure OpenAI account')
param openAiName string

@description('Location for Azure OpenAI')
param location string = 'swedencentral'

@description('Tags to apply to Azure OpenAI resources')
param tags object = {}

@description('The resource ID of the managed identity')
param managedIdentityId string

@description('The principal ID of the managed identity')
param managedIdentityPrincipalId string

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: openAiName
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    customSubDomainName: openAiName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: openAiAccount
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-05-13'
    }
  }
}

var cognitiveServicesOpenAiUserRoleId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: openAiAccount
  name: guid(openAiAccount.id, managedIdentityPrincipalId, cognitiveServicesOpenAiUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      cognitiveServicesOpenAiUserRoleId
    )
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('The resource ID of the Azure OpenAI account')
output openAiId string = openAiAccount.id

@description('The name of the Azure OpenAI account')
output openAiName string = openAiAccount.name

@description('The endpoint of the Azure OpenAI account')
output openAiEndpoint string = openAiAccount.properties.endpoint

@description('The deployment name for GPT-4o')
output gpt4oDeploymentName string = gpt4oDeployment.name
