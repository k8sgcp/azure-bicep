using '../templates/main.bicep'

param location = 'centralindia'

param environment = 'dev'

param vmCount = 1

param vmSize = 'Standard_B1s'

param adminUsername = 'azureuser'

param adminPassword = 'DevPass123!Secure'

param deployStorage = false

param tags = {
  environment: 'dev'
}
