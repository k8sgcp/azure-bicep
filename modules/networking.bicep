metadata name = 'Networking Module'
metadata description = 'VNet, Subnet, NSG'
metadata version = '1.0.0'

// ============= PARAMETERS =============
param location string
param environment string

// ============= VARIABLES =============
var vnetName = '${environment}-vnet'
var subnetName = '${environment}-subnet'
var nsgName = '${environment}-nsg'

// ============= RESOURCES =============

// NSG
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1001
          direction: 'Inbound'
        }
      }
    ]
  }
}

// VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// ============= OUTPUTS =============
output vnetId string = vnet.id
output vnetName string = vnet.name
output subnetId string = vnet.properties.subnets[0].id
output subnetName string = subnetName
output nsgId string = nsg.id
output nsgName string = nsg.name
