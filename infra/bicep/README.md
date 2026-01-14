# Azure Infrastructure as Code - Bicep Templates

This directory contains Bicep templates for deploying a complete Azure infrastructure stack including:

- **Managed Identity**: User-assigned identity for password-less service-to-service authentication
- **App Service**: S1 Linux plan with .NET 8 runtime
- **Azure SQL**: Entra ID-only authentication (no SQL passwords), Basic tier
- **Monitoring**: Log Analytics + Application Insights with diagnostic settings
- **Azure OpenAI**: GPT-4o deployment in Sweden Central
- **Azure AI Search**: Basic tier for AI-powered search capabilities

## Directory Structure

```
infra/bicep/
├── main.bicep              # Main orchestration template
├── main.bicepparam         # Parameter file (template)
├── modules/
│   ├── managedIdentity.bicep   # User-assigned managed identity
│   ├── appService.bicep        # App Service Plan + App Service
│   ├── sqlServer.bicep         # SQL Server + Database + Diagnostics
│   ├── monitoring.bicep        # Log Analytics + Application Insights
│   ├── openai.bicep            # Azure OpenAI + GPT-4o deployment
│   └── aiSearch.bicep          # Azure AI Search service
└── README.md               # This file
```

## Prerequisites

- Azure CLI installed and authenticated
- Bicep CLI installed (comes with Azure CLI)
- An Azure subscription with appropriate permissions
- Entra ID admin credentials for SQL Server

## Resource Naming Convention

Resources are named using the pattern: `{baseName}-{environment}-{resourceType}`

Example for `baseName=myapp` and `environment=dev`:
- Managed Identity: `myapp-dev-mi`
- App Service Plan: `myapp-dev-asp`
- App Service: `myapp-dev-app`
- SQL Server: `myapp-dev-sql`
- SQL Database: `myapp-dev-sqldb`
- Log Analytics: `myapp-dev-law`
- Application Insights: `myapp-dev-ai`
- Azure OpenAI: `myapp-dev-openai`
- AI Search: `myapp-dev-search`

## Default Locations

- **App Service & SQL**: UK South (`uksouth`)
- **Azure OpenAI**: Sweden Central (`swedencentral`)
- **Other Resources**: UK South (can be overridden)

All locations can be overridden using parameters.

## Parameters

### Required Parameters

- `baseName`: Base name for all resources (e.g., `myapp`)
- `sqlEntraAdminObjectId`: The Entra ID admin object ID for SQL Server authentication
- `sqlEntraAdminLogin`: The Entra ID admin login name (e.g., `admin@contoso.com`)

### Optional Parameters

- `environment`: Environment name (default: `dev`)
- `location`: Location for App Service and SQL (default: `uksouth`)
- `openAiLocation`: Location for Azure OpenAI (default: `swedencentral`)
- `tags`: Custom tags to apply to resources

## Local Deployment

### Step 1: Update Parameters

Edit `main.bicepparam` and update the required parameters:

```bicep
using './main.bicep'

param baseName = 'myapp'
param environment = 'dev'
param location = 'uksouth'
param openAiLocation = 'swedencentral'
param sqlEntraAdminObjectId = '<your-entra-admin-object-id>'
param sqlEntraAdminLogin = 'admin@contoso.com'
```

To get your Entra ID object ID:
```bash
az ad user show --id admin@contoso.com --query id -o tsv
```

### Step 2: Create Resource Group

```bash
az group create --name rg-myapp-dev --location uksouth
```

### Step 3: Deploy the Infrastructure

```bash
az deployment group create \
  --resource-group rg-myapp-dev \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Or with inline parameters:

```bash
az deployment group create \
  --resource-group rg-myapp-dev \
  --template-file main.bicep \
  --parameters baseName=myapp \
               environment=dev \
               location=uksouth \
               openAiLocation=swedencentral \
               sqlEntraAdminObjectId=<object-id> \
               sqlEntraAdminLogin=admin@contoso.com
```

### Step 4: View Deployment Outputs

```bash
az deployment group show \
  --resource-group rg-myapp-dev \
  --name main \
  --query properties.outputs
```

## GitHub Actions Deployment

This repository includes GitHub Actions workflows for automated deployment:

- **Deploy Infrastructure**: `.github/workflows/deploy-infrastructure.yml`
- **Delete Infrastructure**: `.github/workflows/delete-infrastructure.yml`

See [oidc.md](../../oidc.md) for instructions on setting up OIDC authentication between GitHub and Azure.

## Validating Templates

### Build (Compile)

```bash
bicep build main.bicep --stdout --no-restore
```

### Format

```bash
bicep format main.bicep
```

### Lint

```bash
bicep lint main.bicep
```

## Deployed Resources

### Managed Identity

A user-assigned managed identity that is used by:
- App Service (for passwordless connections)
- Azure OpenAI (with Cognitive Services OpenAI User role)
- Azure AI Search (with Search Index Data Contributor role)

### App Service

- **SKU**: S1 Standard (Linux)
- **Runtime**: .NET 8.0
- **Features**:
  - HTTPS only
  - Always On enabled
  - HTTP/2 enabled
  - TLS 1.2 minimum
  - FTPS disabled
  - Application Insights integration
  - Diagnostic settings to Log Analytics

### SQL Server & Database

- **Tier**: Basic
- **Authentication**: Entra ID only (no SQL passwords)
- **Features**:
  - Public network access enabled (with Azure services allowed)
  - Diagnostic settings for server and database
  - Logs sent to Log Analytics

### Monitoring

- **Log Analytics**: PerGB2018 pricing tier, 30-day retention
- **Application Insights**: Workspace-based, integrated with App Service

### Azure OpenAI

- **Location**: Sweden Central
- **SKU**: S0 (Standard)
- **Deployment**: GPT-4o (version 2024-05-13, capacity 10)
- **Features**:
  - Managed identity authentication
  - Role assignment for managed identity

### Azure AI Search

- **SKU**: Basic
- **Features**:
  - Managed identity authentication
  - Role assignment for managed identity
  - API key authentication enabled

## Security Considerations

1. **No Secrets**: All authentication uses Entra ID (Azure AD) and managed identities
2. **Entra ID Only**: SQL Server uses Entra ID-only authentication
3. **HTTPS Only**: App Service enforces HTTPS
4. **TLS 1.2+**: Minimum TLS version enforced
5. **Diagnostic Logging**: All resources send logs to Log Analytics
6. **RBAC**: Role assignments follow least privilege principle

## Cleanup

To delete all resources:

```bash
az group delete --name rg-myapp-dev --yes --no-wait
```

Or use the GitHub Actions workflow: **Delete Infrastructure**

## Troubleshooting

### Bicep Build Errors

If you encounter build errors, ensure you have the latest Bicep version:

```bash
az bicep upgrade
```

### Deployment Failures

Check deployment logs:

```bash
az deployment group show \
  --resource-group rg-myapp-dev \
  --name main \
  --query properties.error
```

### SQL Authentication Issues

Ensure the Entra ID admin object ID and login are correct:

```bash
az ad user show --id admin@contoso.com
```

## Support

For issues or questions, please open an issue in the repository.
