// PeelAway Logic: Enterprise Azure Resource Documentation Template
//
// Author: Carmen Reed
// Date: 2026-04-12
//
// PURPOSE: This Bicep template defines the Azure resources PeelAway Logic would
// provision in an enterprise deployment. Validated against Azure resource schemas; pending deployment.
// The portfolio application currently runs on:
//   - GitHub Pages (static hosting)
//   - Azure AI Search F0 free tier (manually provisioned)
//   - Anthropic Claude API (direct, no Azure OpenAI)
//
// This template exists to demonstrate:
//   1. IaC architecture knowledge (Bicep module structure, parameter files, resource dependencies)
//   2. Enterprise Azure AI resource planning (7 services, correct SKUs, dependencies documented)
//   3. The "Azure Migration Path" referenced in ADR-001 through ADR-005
//
// To provision this template against a real Azure subscription:
//   az deployment group create \
//     --resource-group peelaway-portfolio-rg \
//     --template-file azure-resources.bicep \
//     --parameters azure-resources.parameters.json

// ============================================================
// PARAMETERS
// ============================================================

@description('Azure region for all resources. East US preferred for latency to GitHub Pages CDN.')
param location string = 'eastus'

@description('Environment suffix: dev, staging, or prod.')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Base name for all resources. Used as prefix with environment suffix.')
param baseName string = 'peelaway'

@description('Azure OpenAI model deployment name.')
param aoaiDeploymentName string = 'gpt-4o'

@description('Azure OpenAI model version.')
param aoaiModelVersion string = '2024-08-06'

// ============================================================
// VARIABLES
// ============================================================

var resourceSuffix = '${baseName}-${environment}'
var tags = {
  project: 'peelaway-logic'
  environment: environment
  owner: 'carmen-reed'
  managedBy: 'bicep'
}

// ============================================================
// AZURE AI SEARCH
// Current: F0 free tier, manually provisioned as 'peelaway-search'
// Enterprise: Standard S1 with semantic ranking enabled
// ADR reference: ADR-002 (REST client pattern, migration path to SDK with Managed Identity)
// ============================================================

resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: '${resourceSuffix}-search'
  location: location
  tags: tags
  sku: {
    // F0 is the current free tier. S1 is the minimum for production semantic ranking.
    // F0 does not support semantic ranking or private endpoints.
    name: environment == 'prod' ? 'standard' : 'free'
  }
  properties: {
    replicaCount: environment == 'prod' ? 2 : 1
    partitionCount: 1
    hostingMode: 'default'
    // Semantic search requires Standard SKU
    semanticSearch: environment == 'prod' ? 'standard' : 'disabled'
    // Disable public network access in production; use private endpoint
    publicNetworkAccess: environment == 'prod' ? 'disabled' : 'enabled'
  }
}

// ============================================================
// AZURE OPENAI
// Current: Not provisioned. Anthropic Claude API used instead (see ADR-001).
// Enterprise: GPT-4o deployment with two capacity levels for cost optimization
//   - scoring-model: cost-optimized deployment (equivalent to Claude Haiku usage)
//   - tailoring-model: quality-optimized deployment (equivalent to Claude Sonnet usage)
// ============================================================

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: '${resourceSuffix}-aoai'
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: '${resourceSuffix}-aoai'
    // Disable public network access in production
    publicNetworkAccess: environment == 'prod' ? 'Disabled' : 'Enabled'
    // Restrict to Azure AD authentication only (no API key in client code)
    disableLocalAuth: environment == 'prod' ? true : false
  }
}

resource openAiScoringDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openAiAccount
  name: '${aoaiDeploymentName}-scoring'
  properties: {
    model: {
      format: 'OpenAI'
      name: aoaiDeploymentName
      version: aoaiModelVersion
    }
    // Lower capacity (TPM) for high-volume batch scoring phase
    // Equivalent to current Claude Haiku usage pattern
  }
  sku: {
    name: 'Standard'
    capacity: 30
  }
}

resource openAiTailoringDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openAiAccount
  name: '${aoaiDeploymentName}-tailoring'
  dependsOn: [openAiScoringDeployment]
  properties: {
    model: {
      format: 'OpenAI'
      name: aoaiDeploymentName
      version: aoaiModelVersion
    }
    // Higher capacity for quality-sensitive tailoring phase
    // Equivalent to current Claude Sonnet usage pattern
  }
  sku: {
    name: 'Standard'
    capacity: 60
  }
}

// ============================================================
// AZURE STATIC WEB APPS
// Current: GitHub Pages (see ADR-005 for migration path)
// Enterprise: Standard tier with staging slots, custom domain, API routes
// The API routes enable Managed Identity auth to Azure AI Search (eliminating client-side API key)
// ============================================================

resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: '${resourceSuffix}-swa'
  location: location
  tags: tags
  sku: {
    // Free tier for dev; Standard for staging/prod (required for staging slots and custom domains)
    name: environment == 'prod' ? 'Standard' : 'Free'
    tier: environment == 'prod' ? 'Standard' : 'Free'
  }
  properties: {
    repositoryUrl: 'https://github.com/carmenreed/PeelAway-Logic'
    branch: environment == 'prod' ? 'main' : environment
    buildProperties: {
      appLocation: '/'
      apiLocation: 'api'
      outputLocation: 'build'
    }
  }
  identity: {
    // System-assigned Managed Identity for API routes to authenticate to Azure AI Search
    // Eliminates the query-key-in-client-bundle pattern documented in ADR-002
    type: 'SystemAssigned'
  }
}

// Grant the Static Web App's identity read access to Azure AI Search
resource searchReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  name: guid(staticWebApp.id, searchService.id, 'Search Index Data Reader')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1407120a-92aa-4202-b7e9-c0e197c71c8f')
    principalId: staticWebApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================
// AZURE COSMOS DB
// Current: localStorage (browser) for job persistence (see PROJECT_EVOLUTION.md Chapter 3)
// Enterprise: Cosmos DB for multi-device sync, team access, and cross-session history
// Container structure mirrors the current localStorage schema
// ============================================================

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: '${resourceSuffix}-cosmos'
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: environment == 'prod' ? true : false
      }
    ]
    // Serverless for personal/portfolio use; provisioned throughput for production scale
    capabilities: environment == 'prod' ? [] : [{ name: 'EnableServerless' }]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    // Disable key-based auth in production; use Managed Identity
    disableLocalAuth: environment == 'prod' ? true : false
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
  parent: cosmosAccount
  name: 'peelaway-db'
  properties: {
    resource: { id: 'peelaway-db' }
  }
}

resource jobsContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  parent: cosmosDatabase
  name: 'jobs'
  properties: {
    resource: {
      id: 'jobs'
      // Partition by userId for multi-user future; single user uses a fixed partition key
      partitionKey: { paths: ['/userId'], kind: 'Hash' }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [{ path: '/*' }]
        excludedPaths: [{ path: '/rawDescription/*' }]
      }
    }
  }
}

// ============================================================
// AZURE DATA FACTORY
// Current: Manual search trigger in the React UI
// Enterprise: Scheduled pipeline for automated daily job ingestion
// Runs the Search phase on a timer, writes results to Cosmos DB for review sessions
// ============================================================

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: '${resourceSuffix}-adf'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // Public network access disabled in prod; use private endpoint
    publicNetworkAccess: environment == 'prod' ? 'Disabled' : 'Enabled'
  }
}

// ============================================================
// APPLICATION INSIGHTS
// Current: No monitoring or telemetry
// Enterprise: Unified telemetry across all services
// Custom events for pipeline phase completion, scoring latency, tailoring quality
// ============================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${resourceSuffix}-logs'
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: environment == 'prod' ? 90 : 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${resourceSuffix}-ai'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    RetentionInDays: environment == 'prod' ? 90 : 30
  }
}

// ============================================================
// KEY VAULT
// Current: Environment variables for API key management
// Enterprise: Key Vault for any secrets that cannot use Managed Identity
//   (third-party API keys: Adzuna, JSearch)
// Azure OpenAI and Azure AI Search use Managed Identity, not Key Vault
// ============================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${resourceSuffix}-kv'
  location: location
  tags: tags
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    // Disable public access in production
    publicNetworkAccess: environment == 'prod' ? 'Disabled' : 'Enabled'
    networkAcls: {
      defaultAction: environment == 'prod' ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// ============================================================
// OUTPUTS
// ============================================================

output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'
output openAiEndpoint string = openAiAccount.properties.endpoint
output staticWebAppDefaultHostname string = staticWebApp.properties.defaultHostname
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output keyVaultUri string = keyVault.properties.vaultUri
output cosmosEndpoint string = cosmosAccount.properties.documentEndpoint
