targetScope = 'resourceGroup'

@description('The base name for all resources')
param baseName string

@description('The environment name (e.g., dev, test, prod)')
param environment string = 'dev'

@description('Location for the App Service and SQL resources')
param location string = 'uksouth'

@description('Location for Azure OpenAI resources')
param openAiLocation string = 'swedencentral'

@description('The Entra ID admin object ID for SQL Server')
param sqlEntraAdminObjectId string

@description('The Entra ID admin login name for SQL Server')
param sqlEntraAdminLogin string

@description('Tags to apply to all resources')
param tags object = {
  environment: environment
  managedBy: 'bicep'
}

var resourceNames = {
  managedIdentity: '${baseName}-${environment}-mi'
  appServicePlan: '${baseName}-${environment}-asp'
  appService: '${baseName}-${environment}-app'
  sqlServer: '${baseName}-${environment}-sql'
  sqlDatabase: '${baseName}-${environment}-sqldb'
  logAnalytics: '${baseName}-${environment}-law'
  appInsights: '${baseName}-${environment}-ai'
  openAi: '${baseName}-${environment}-openai'
  aiSearch: '${baseName}-${environment}-search'
}

module managedIdentity 'modules/managedIdentity.bicep' = {
  name: 'managedIdentity-deployment'
  params: {
    managedIdentityName: resourceNames.managedIdentity
    location: location
    tags: tags
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deployment'
  params: {
    workspaceName: resourceNames.logAnalytics
    appInsightsName: resourceNames.appInsights
    location: location
    tags: tags
  }
}

module sqlServer 'modules/sqlServer.bicep' = {
  name: 'sqlServer-deployment'
  params: {
    sqlServerName: resourceNames.sqlServer
    sqlDatabaseName: resourceNames.sqlDatabase
    location: location
    tags: tags
    entraAdminObjectId: sqlEntraAdminObjectId
    entraAdminLogin: sqlEntraAdminLogin
    workspaceId: monitoring.outputs.workspaceId
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService-deployment'
  params: {
    appServicePlanName: resourceNames.appServicePlan
    appServiceName: resourceNames.appService
    location: location
    tags: tags
    managedIdentityId: managedIdentity.outputs.managedIdentityId
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    workspaceId: monitoring.outputs.workspaceId
  }
}

module openai 'modules/openai.bicep' = {
  name: 'openai-deployment'
  params: {
    openAiName: resourceNames.openAi
    location: openAiLocation
    tags: tags
    managedIdentityId: managedIdentity.outputs.managedIdentityId
    managedIdentityPrincipalId: managedIdentity.outputs.principalId
  }
}

module aiSearch 'modules/aiSearch.bicep' = {
  name: 'aiSearch-deployment'
  params: {
    searchServiceName: resourceNames.aiSearch
    location: location
    tags: tags
    managedIdentityId: managedIdentity.outputs.managedIdentityId
    managedIdentityPrincipalId: managedIdentity.outputs.principalId
  }
}

@description('The resource ID of the managed identity')
output managedIdentityId string = managedIdentity.outputs.managedIdentityId

@description('The principal ID of the managed identity')
output managedIdentityPrincipalId string = managedIdentity.outputs.principalId

@description('The client ID of the managed identity')
output managedIdentityClientId string = managedIdentity.outputs.clientId

@description('The name of the App Service')
output appServiceName string = appService.outputs.appServiceName

@description('The default hostname of the App Service')
output appServiceHostname string = appService.outputs.appServiceHostname

@description('The fully qualified domain name of the SQL Server')
output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn

@description('The name of the SQL Database')
output sqlDatabaseName string = sqlServer.outputs.sqlDatabaseName

@description('The Application Insights instrumentation key')
output appInsightsInstrumentationKey string = monitoring.outputs.appInsightsInstrumentationKey

@description('The Application Insights connection string')
output appInsightsConnectionString string = monitoring.outputs.appInsightsConnectionString

@description('The endpoint of the Azure OpenAI account')
output openAiEndpoint string = openai.outputs.openAiEndpoint

@description('The deployment name for GPT-4o')
output gpt4oDeploymentName string = openai.outputs.gpt4oDeploymentName

@description('The endpoint of the Azure AI Search service')
output searchServiceEndpoint string = aiSearch.outputs.searchServiceEndpoint
