metadata name = 'Storage Module'
metadata description = 'Storage Account and Blob Container'
metadata version = '1.0.0'

// ============= PARAMETERS =============
param location string
param environment string
param deployStorage bool = true  // ← NEW: whether to deploy storage

// ============= VARIABLES =============
var storageAccountName = '${replace(environment, '-', '')}${uniqueString(resourceGroup().id)}'
var tags = {
  environment: environment
  managedBy: 'Bicep'
}

// ============= RESOURCES =============

// Storage Account (conditional)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (deployStorage) {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// ============= OUTPUTS =============
output storageAccountId string = deployStorage ? storageAccount.id : ''
output storageAccountName string = deployStorage ? storageAccount.name : ''
