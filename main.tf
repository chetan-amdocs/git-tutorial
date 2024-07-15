resource "azurerm_resource_group" "myrg" {
  name     = "${var.client}-${var.prefix}-${var.resouregroupname}"
  location = var.location
}

resource "random_string" "myrandstr" {
  length  = 16
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_storage_account" "mystg01" {
  name                     = random_string.myrandstr.result
  resource_group_name      = azurerm_resource_group.myrg.name
  location                 = var.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2" #Added default TLS version that it takes. Not supported in all regions.
  shared_access_key_enabled       = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  network_rules {
    virtual_network_subnet_ids = [azurerm_subnet.mysubnet01.id]
    default_action             = "Deny"
    ip_rules                   = ["10.0.0.5"]
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }
}

resource "azurerm_storage_container" "mycont01" {
  name                  = "${var.client}-${var.prefix}-mycont021"
  storage_account_name  = azurerm_storage_accaount.mystg01.name
  container_access_type = "private"
  #encryption_scope_override_enabled = true

}

resource "azurerm_storage_blob" "myblob01" {
  name                   = abc.txt
  storage_account_name   = azurerm_storage_accaount.mystg01.name
  storage_container_name = azurerm_storage_container.mycont01.name
  type                   = "Block"
}

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "MyEndPoint"
  resource_group_name = var.resouregroupname
  location            = var.location
  subnet_id           = azurerm_subnet.mysubnet01.id

  private_service_connection {
    name                           = "privateserviceconn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.mystg01.id
    subresource_names              = ["blob"]
  }

}


