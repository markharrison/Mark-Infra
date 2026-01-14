# Mark-Infra

Azure Infrastructure as Code using Bicep templates for deploying a complete cloud infrastructure stack.

## Overview

This repository contains Bicep templates and GitHub Actions workflows for deploying and managing Azure infrastructure including:

- **Managed Identity** - User-assigned identity for password-less service-to-service authentication
- **App Service** - S1 Linux plan with .NET 8 runtime (UK South)
- **Azure SQL** - Entra ID-only authentication (no SQL passwords), Basic tier (UK South)
- **Monitoring** - Log Analytics + Application Insights with diagnostic settings for App Service and SQL
- **Azure OpenAI** - GPT-4o deployment (Sweden Central)
- **Azure AI Search** - Basic tier for AI-powered search capabilities (UK South)

## Quick Start

### Prerequisites

1. An Azure subscription
2. GitHub repository with OIDC configured (see [OIDC Setup Guide](oidc.md))
3. Required GitHub secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_RESOURCE_GROUP`

### Deploy Infrastructure

1. Navigate to **Actions** in your GitHub repository
2. Select **Deploy Infrastructure** workflow
3. Click **Run workflow**
4. Fill in the required parameters:
   - Environment (dev/test/prod)
   - Base name for resources
   - Locations
   - SQL Entra ID admin credentials
5. Click **Run workflow** to start deployment

### Delete Infrastructure

1. Navigate to **Actions** in your GitHub repository
2. Select **Delete Infrastructure** workflow
3. Click **Run workflow**
4. Type `DELETE` to confirm
5. Click **Run workflow** to start deletion

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── deploy-infrastructure.yml    # Deploy workflow
│       └── delete-infrastructure.yml    # Delete workflow
├── infra/
│   └── bicep/
│       ├── main.bicep                   # Main orchestration template
│       ├── main.bicepparam              # Parameters template
│       ├── modules/                     # Bicep modules
│       │   ├── managedIdentity.bicep
│       │   ├── appService.bicep
│       │   ├── sqlServer.bicep
│       │   ├── monitoring.bicep
│       │   ├── openai.bicep
│       │   └── aiSearch.bicep
│       └── README.md                    # Bicep documentation
├── oidc.md                              # OIDC setup guide
└── README.md                            # This file
```

## Documentation

- **[Bicep Templates Documentation](infra/bicep/README.md)** - Detailed information about Bicep templates and local deployment
- **[OIDC Setup Guide](oidc.md)** - Step-by-step guide for setting up OIDC authentication between GitHub and Azure

## Features

### Security

- **Password-less Authentication**: All services use Entra ID (Azure AD) and managed identities
- **Entra ID-Only SQL**: SQL Server uses Entra ID-only authentication (no SQL passwords)
- **HTTPS Enforcement**: App Service enforces HTTPS only
- **TLS 1.2+**: Minimum TLS version enforced across all services
- **RBAC**: Role assignments follow least privilege principle
- **OIDC**: GitHub Actions use OIDC for secure authentication (no long-lived secrets)

### Monitoring & Observability

- **Centralized Logging**: All resources send logs to Log Analytics
- **Application Insights**: Integrated with App Service for application monitoring
- **Diagnostic Settings**: Enabled for App Service and SQL Database/Server
- **30-Day Retention**: Log Analytics configured with 30-day retention

### Managed Identity Integration

The user-assigned managed identity is configured with:
- **App Service**: Assigned to App Service for passwordless connections
- **Azure OpenAI**: Cognitive Services OpenAI User role
- **Azure AI Search**: Search Index Data Contributor role

## Default Configurations

### App Service
- **SKU**: S1 Standard (Linux)
- **Runtime**: .NET 8.0
- **Location**: UK South (uksouth)
- **Always On**: Enabled
- **HTTP/2**: Enabled
- **FTPS**: Disabled

### SQL Server & Database
- **Tier**: Basic
- **Location**: UK South (uksouth)
- **Authentication**: Entra ID only
- **Public Access**: Enabled (Azure services allowed)

### Azure OpenAI
- **Location**: Sweden Central (swedencentral)
- **SKU**: S0 (Standard)
- **Model**: GPT-4o (version 2024-05-13)
- **Capacity**: 10

### Azure AI Search
- **SKU**: Basic
- **Location**: UK South (uksouth)
- **Authentication**: Managed identity + API key

### Monitoring
- **Log Analytics**: PerGB2018 pricing tier
- **Retention**: 30 days
- **Application Insights**: Workspace-based

## Local Deployment

You can also deploy the infrastructure locally using Azure CLI:

```bash
# Create resource group
az group create --name rg-myapp-dev --location uksouth

# Deploy infrastructure
az deployment group create \
  --resource-group rg-myapp-dev \
  --template-file infra/bicep/main.bicep \
  --parameters baseName=myapp \
               environment=dev \
               location=uksouth \
               openAiLocation=swedencentral \
               sqlEntraAdminObjectId=<your-object-id> \
               sqlEntraAdminLogin=admin@contoso.com
```

See the [Bicep Templates Documentation](infra/bicep/README.md) for more details.

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

## Contributing

This is a personal infrastructure repository. For issues or questions, please open an issue.

## License

See [LICENSE](LICENSE) for details.
