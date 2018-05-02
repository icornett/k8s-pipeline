resource "azurerm_resource_group" "group" {
  name     = "${var.project_name}-${var.environment_name}"
  location = "${var.azure_region}"
}

resource "azurerm_storage_account" "state_storage" {
  name                     = "${var.project_name}-state"
  resource_group_name      = "${azurerm_resource_group.group.name}"
  location                 = "${var.azure_region}"
  account_tier             = "${var.account_tier}"
  account_kind             = "BlobStorage"
  account_replication_type = "${var.account_replication_type}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "state_container" {
  name                  = "tfstate"
  resource_group_name   = "${azurerm_resource_group.group.name}"
  storage_account_name  = "${azurerm_storage_account.group.name}"
  container_access_type = "blob"

  lifecycle {
    prevent_destroy = true
  }
}
