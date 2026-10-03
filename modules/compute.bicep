metadata name = 'Compute Module'
metadata description = 'VMs and NICs (with loop support)'
metadata version = '1.0.0'

// ============= PARAMETERS =============
param location string
param environment string
param vmCount int = 1  // ← NEW: how many VMs to deploy

@allowed([
  'Standard_B1s'
  'Standard_B2s'
])
param vmSize string

param adminUsername string

@secure()
param adminPassword string

param subnetId string

// ============= VARIABLES =============
var tags = {
  environment: environment
  app: 'go-app'
  managedBy: 'Bicep'
}

// ============= RESOURCES =============

// NICs (loop)
resource nics 'Microsoft.Network/networkInterfaces@2023-05-01' = [for i in range(0, vmCount): {
  name: '${environment}-nic-${i}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

// VMs (loop)
resource vms 'Microsoft.Compute/virtualMachines@2023-07-01' = [for i in range(0, vmCount): {
  name: '${environment}-vm-${i}'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${environment}-vm-${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nics[i].id
        }
      ]
    }
  }
}]

// ============= OUTPUTS =============
output vmIds array = [for i in range(0, vmCount): vms[i].id]
output vmNames array = [for i in range(0, vmCount): vms[i].name]
output privateIpAddresses array = [for i in range(0, vmCount): nics[i].properties.ipConfigurations[0].properties.privateIPAddress]
