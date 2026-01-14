@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the App Service')
param appServiceName string

@description('Location for App Service resources')
param location string = resourceGroup().location

@description('Tags to apply to App Service resources')
param tags object = {}

@description('The resource ID of the managed identity')
param managedIdentityId string

@description('The Application Insights connection string')
param appInsightsConnectionString string

@description('The resource ID of the Log Analytics workspace for diagnostics')
param workspaceId string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  tags: tags
  kind: 'app,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
      ]
    }
  }
}

resource appServiceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appService
  name: 'app-service-diagnostics'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('The resource ID of the App Service Plan')
output appServicePlanId string = appServicePlan.id

@description('The resource ID of the App Service')
output appServiceId string = appService.id

@description('The name of the App Service')
output appServiceName string = appService.name

@description('The default hostname of the App Service')
output appServiceHostname string = appService.properties.defaultHostName
