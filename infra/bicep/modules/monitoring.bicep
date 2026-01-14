@description('The name of the Log Analytics workspace')
param workspaceName string

@description('The name of the Application Insights instance')
param appInsightsName string

@description('Location for monitoring resources')
param location string = resourceGroup().location

@description('Tags to apply to monitoring resources')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

@description('The resource ID of the Log Analytics workspace')
output workspaceId string = logAnalyticsWorkspace.id

@description('The resource ID of the Application Insights instance')
output appInsightsId string = applicationInsights.id

@description('The instrumentation key of the Application Insights instance')
output appInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('The connection string of the Application Insights instance')
output appInsightsConnectionString string = applicationInsights.properties.ConnectionString

@description('The name of the Log Analytics workspace')
output workspaceName string = logAnalyticsWorkspace.name

@description('The name of the Application Insights instance')
output appInsightsName string = applicationInsights.name
