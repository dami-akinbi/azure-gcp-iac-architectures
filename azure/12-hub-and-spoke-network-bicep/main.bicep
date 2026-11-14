param environment string
param location string = resourceGroup().location

// 1. Hub Virtual Network (Central Connectivity & Shared Services)
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-hub-${environment}'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: { addressPrefix: '10.0.0.0/27' }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: { addressPrefix: '10.0.1.0/26' }
      }
      {
        name: 'snet-shared-services'
        properties: { addressPrefix: '10.0.2.0/24' }
      }
    ]
  }
}

// 2. Spoke 1 Virtual Network (Application Tier)
resource spokeAppVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-spoke-app-${environment}'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.1.0.0/16'] }
    subnets: [
      {
        name: 'snet-workload'
        properties: { addressPrefix: '10.1.1.0/24' }
      }
    ]
  }
}

// 3. Spoke 2 Virtual Network (Database Tier)
resource spokeDataVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-spoke-data-${environment}'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.2.0.0/16'] }
    subnets: [
      {
        name: 'snet-database'
        properties: { addressPrefix: '10.2.1.0/24' }
      }
    ]
  }
}

// 4. Bidirectional Peering: Hub <-> Spoke App
resource hubToSpokeApp 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: 'peer-hub-to-spoke-app'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteVirtualNetwork: { id: spokeAppVnet.id }
  }
}

resource spokeAppToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: spokeAppVnet
  name: 'peer-spoke-app-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: { id: hubVnet.id }
  }
}

// 5. Bidirectional Peering: Hub <-> Spoke Data (Sequenced to avoid VNet lock conflicts)
resource hubToSpokeData 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: 'peer-hub-to-spoke-data'
  dependsOn: [
    hubToSpokeApp
    spokeAppToHub
  ]
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: { id: spokeDataVnet.id }
  }
}

resource spokeDataToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: spokeDataVnet
  name: 'peer-spoke-data-to-hub'
  dependsOn: [
    hubToSpokeApp
    spokeAppToHub
  ]
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: { id: hubVnet.id }
  }
}

output hubVnetId string = hubVnet.id
output spokeAppVnetId string = spokeAppVnet.id
output spokeDataVnetId string = spokeDataVnet.id
