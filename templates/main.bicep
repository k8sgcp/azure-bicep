metadata name = 'Go App Deployment (Modular with Loops & Conditionals)'
metadata description = 'Orchestrates networking, compute (with loops), and storage (conditional)'
metadata version = '1.0.0'

// ============= PARAMETERS =============
param location string = 'eastus'
param environment string = 'dev'

@minValue(1)
@maxValue(5)
param vmCount int = 1  // ← NEW: number of VMs to deploy

@allowed([
  'Standard_B1s'
  'Standard_B2s'
])
param vmSize string = 'Standard_B2s'

param adminUsername string = 'azureuser'

@secure()
param adminPassword string

param deployStorage bool = false  // ← NEW: deploy storage or not

param tags object = {}

// ============= MODULES =============

// Networking Module
module networkingModule '../modules/networking.bicep' = {
  name: 'networkingDeployment'
  params: {
    location: location
    tags: tags
    environment: environment
  }
}

// Compute Module (with vmCount loop)
module computeModule '../modules/compute.bicep' = {
  name: 'computeDeployment'
  params: {
    location: location
    environment: environment
    vmCount: vmCount  // ← PASS vmCount
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: networkingModule.outputs.subnetId
  }
}

// Storage Module (conditional)
module storageModule '../modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    environment: environment
    deployStorage: deployStorage  // ← PASS conditional flag
  }
}

// ============= OUTPUTS =============
output vmIds array = computeModule.outputs.vmIds
output vmNames array = computeModule.outputs.vmNames
output privateIpAddresses array = computeModule.outputs.privateIpAddresses
output vnetId string = networkingModule.outputs.vnetId
output nsgId string = networkingModule.outputs.nsgId
output storageAccountId string = storageModule.outputs.storageAccountId
output storageAccountName string = storageModule.outputs.storageAccountName
