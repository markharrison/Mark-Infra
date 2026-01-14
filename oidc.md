# Setting up OIDC Authentication between GitHub and Azure

This guide explains how to configure OpenID Connect (OIDC) authentication to enable GitHub Actions workflows to securely authenticate with Azure without using long-lived secrets.

## Prerequisites

- An Azure subscription with appropriate permissions to create resources
- Owner or User Access Administrator role on the Azure subscription
- A GitHub repository with appropriate permissions

## Step 1: Create an Azure AD Application

1. Open the Azure Portal and navigate to **Azure Active Directory** (now called **Microsoft Entra ID**)

2. Go to **App registrations** and click **New registration**

3. Configure the application:
   - **Name**: `GitHub-Actions-OIDC` (or a name of your choice)
   - **Supported account types**: Select "Accounts in this organizational directory only"
   - Click **Register**

4. Note the following values from the application overview page:
   - **Application (client) ID**
   - **Directory (tenant) ID**

## Step 2: Configure Federated Credentials

1. In your App registration, navigate to **Certificates & secrets**

2. Click on the **Federated credentials** tab

3. Click **Add credential**

4. Select **GitHub Actions deploying Azure resources**

5. Configure the federated credential:
   - **Organization**: Your GitHub username or organization name (e.g., `markharrison`)
   - **Repository**: Your repository name (e.g., `Mark-Infra`)
   - **Entity type**: Select based on your needs:
     - **Branch**: For deployments from a specific branch (e.g., `main`)
     - **Environment**: For deployments to a specific GitHub environment (recommended)
     - **Pull request**: For PR-based deployments
     - **Tag**: For tag-based deployments
   
   For environment-based deployments:
   - **Environment name**: `dev` (or your environment name)
   
   - **Name**: A descriptive name (e.g., `GitHub-Actions-Dev`)
   
6. Click **Add**

7. Repeat steps 3-6 for additional environments (test, prod) if needed

## Step 3: Assign Azure Permissions

1. Navigate to your **Azure Subscription**

2. Click **Access control (IAM)**

3. Click **Add** > **Add role assignment**

4. Select the role you need:
   - **Contributor**: For deploying and managing resources
   - **Owner**: If you need to assign roles to managed identities

5. Click **Next**

6. Click **Select members** and search for your application name (`GitHub-Actions-OIDC`)

7. Select the application and click **Select**

8. Click **Review + assign**

## Step 4: Create Resource Group (Optional)

You can pre-create the resource group or let the workflow create it:

```bash
az group create --name <resource-group-name> --location uksouth
```

## Step 5: Configure GitHub Secrets

1. Navigate to your GitHub repository

2. Go to **Settings** > **Secrets and variables** > **Actions**

3. Click **New repository secret** and add the following secrets:

   - `AZURE_CLIENT_ID`: The Application (client) ID from Step 1
   - `AZURE_TENANT_ID`: The Directory (tenant) ID from Step 1
   - `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
   - `AZURE_RESOURCE_GROUP`: The name of your resource group (e.g., `rg-myapp-dev`)

## Step 6: Configure GitHub Environments (Optional but Recommended)

For environment-based deployments with additional protection:

1. Go to **Settings** > **Environments**

2. Click **New environment**

3. Enter environment name (e.g., `dev`, `test`, `prod`)

4. Configure environment protection rules (optional):
   - **Required reviewers**: Add reviewers for production deployments
   - **Wait timer**: Add a delay before deployment
   - **Deployment branches**: Restrict which branches can deploy

5. Add environment secrets (same as Step 5, but scoped to the environment)

## Step 7: Verify the Configuration

1. Navigate to **Actions** in your GitHub repository

2. Run the **Deploy Infrastructure** workflow manually

3. Select the environment and provide required parameters

4. The workflow should authenticate successfully using OIDC

## Troubleshooting

### Authentication Fails

- Verify that the Client ID, Tenant ID, and Subscription ID are correct
- Check that the federated credential is configured for the correct repository and entity type
- Ensure the service principal has the necessary permissions on the subscription

### Permission Denied

- Verify that the service principal has the Contributor or Owner role on the subscription or resource group
- Check that the role assignment has propagated (may take a few minutes)

### Federated Credential Not Found

- Ensure the entity type matches your workflow trigger (e.g., environment name matches)
- Verify the repository name is in the format `owner/repo`

## Security Best Practices

1. **Use Environments**: Configure GitHub environments with protection rules for production deployments

2. **Least Privilege**: Grant only the minimum required permissions to the service principal

3. **Separate Service Principals**: Use different service principals for different environments

4. **Audit Logs**: Regularly review Azure AD sign-in logs and Azure Activity Logs

5. **Rotate Credentials**: While OIDC doesn't use long-lived secrets, periodically review and update federated credentials

## Additional Resources

- [Azure AD Workload Identity Federation](https://docs.microsoft.com/azure/active-directory/develop/workload-identity-federation)
- [GitHub Actions - Configuring OpenID Connect in Azure](https://docs.github.com/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Azure RBAC Documentation](https://docs.microsoft.com/azure/role-based-access-control/)
