@description('The name of the SQL Server')
param sqlServerName string

@description('The name of the SQL Database')
param sqlDatabaseName string

@description('Location for SQL resources')
param location string = resourceGroup().location

@description('Tags to apply to SQL resources')
param tags object = {}

@description('The Entra ID admin object ID')
param entraAdminObjectId string

@description('The Entra ID admin login name')
param entraAdminLogin string

@description('The Entra ID admin tenant ID')
param entraAdminTenantId string = tenant().tenantId

@description('The resource ID of the Log Analytics workspace for diagnostics')
param workspaceId string

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: entraAdminLogin
      sid: entraAdminObjectId
      tenantId: entraAdminTenantId
      principalType: 'User'
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}

resource sqlServerFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlServerDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: sqlServer
  name: 'sql-server-diagnostics'
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

resource sqlDatabaseDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: sqlDatabase
  name: 'sql-database-diagnostics'
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

@description('The resource ID of the SQL Server')
output sqlServerId string = sqlServer.id

@description('The name of the SQL Server')
output sqlServerName string = sqlServer.name

@description('The fully qualified domain name of the SQL Server')
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('The resource ID of the SQL Database')
output sqlDatabaseId string = sqlDatabase.id

@description('The name of the SQL Database')
output sqlDatabaseName string = sqlDatabase.name
