provider "azurerm" {
  features {}
  subscription_id = "6e6a0710-d058-4210-9324-90596b9f3759"
}

resource "azurerm_resource_group" "rg" {
  name     = "aks-rg"
  location = "East US 2"
}

resource "azurerm_container_registry" "acr" {
  name                = "myacryashj"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myAKSCluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
