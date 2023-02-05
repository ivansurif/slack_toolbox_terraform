resource "azurerm_function_app" "functions" {
  for_each                   = local.function_apps
  name                       = each.key
  location                   = azurerm_resource_group.rg[each.value["resource_group_name"]].location
  resource_group_name        = azurerm_resource_group.rg[each.value["resource_group_name"]].name
  app_service_plan_id        = data.terraform_remote_state.common_services.outputs.app_service_plan_id
  storage_account_name       = local.storage_account_name
  storage_account_access_key = local.primary_blob_access_key
  os_type                    = "linux"
  version                    = "~3"


  app_settings = merge(
    {
      APPINSIGHTS_INSTRUMENTATIONKEY = data.terraform_remote_state.common_services.outputs.insights_instrumentation_key
    },
    each.value["app_settings"],
    { for key, secret in each.value["secrets"] : key => "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=${secret})" }
  )

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on        = each.value["always_on"]
    linux_fx_version = each.value["linux_fx_version"]
    scm_type         = "LocalGit"
  }
}


resource "azurerm_function_app" "functions_files_upload" {
  for_each                   = local.function_apps_files_upload
  name                       = each.key
  location                   = data.terraform_remote_state.common_services.outputs.resource_group_location
  resource_group_name        = each.value["resource_group_name"]
  app_service_plan_id        = data.terraform_remote_state.common_services.outputs.app_service_plan_id_files_upload
  storage_account_name       = local.storage_account_name
  storage_account_access_key = local.primary_blob_access_key
  os_type                    = "linux"
  version                    = "~3"


  app_settings = merge(
    {
      APPINSIGHTS_INSTRUMENTATIONKEY : lookup(local.insight_instrumentation_keys_files_upload, each.value["resource_group_name"], "Value not found")
    },
    each.value["app_settings"],
    { for key, secret in each.value["secrets"] : key => "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=${secret})" }
  )
  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on        = each.value["always_on"]
    linux_fx_version = each.value["linux_fx_version"]
    scm_type         = "LocalGit"
  }
}


resource "azurerm_function_app" "skf-ai-data" {
  for_each                   = local.function_apps_skf_ai_data
  name                       = each.key
  location                   = data.terraform_remote_state.common_services.outputs.resource_group_location
  resource_group_name        = each.value["resource_group_name"]
  app_service_plan_id        = data.terraform_remote_state.common_services.outputs.app_service_plan_id_files_upload
  storage_account_name       = local.storage_account_name
  storage_account_access_key = local.primary_blob_access_key
  os_type                    = "linux"
  version                    = "~3"


  app_settings = merge(
    {
      APPINSIGHTS_INSTRUMENTATIONKEY : lookup(local.insight_instrumentation_keys_files_upload, each.value["resource_group_name"], "Value not found")
    },
    each.value["app_settings"],
    { for key, secret in each.value["secrets"] : key => "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=${secret})" }
  )

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on        = each.value["always_on"]
    linux_fx_version = each.value["linux_fx_version"]
    scm_type         = "LocalGit"
  }
}

resource "azurerm_key_vault_access_policy" "function_app_policies" {
  for_each     = local.function_apps
  key_vault_id = local.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app.functions[each.key].identity[0].principal_id

  secret_permissions = [
    "Get",
  ]
  key_permissions     = []
  storage_permissions = []
}

resource "azurerm_key_vault_access_policy" "function_app_policies_files_upload" {
  for_each     = local.function_apps_files_upload
  key_vault_id = local.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app.functions_files_upload[each.key].identity[0].principal_id

  secret_permissions = [
    "Get",
  ]
  key_permissions     = []
  storage_permissions = []
}

resource "azurerm_key_vault_access_policy" "function_app_policies_skf_ai_data" {
  for_each     = local.function_apps_skf_ai_data
  key_vault_id = local.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app.skf-ai-data[each.key].identity[0].principal_id

  secret_permissions = [
    "Get",
  ]
  key_permissions     = []
  storage_permissions = []
}