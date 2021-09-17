provider "azurerm" {
  features { 
  }
}

resource "azurerm_resource_group" "UpdateManagement" {
  name = var.rgname
  location = "UK South"
}

resource "azurerm_automation_account" "UpdateManagement" {
  name = join("-", var.resourceprefix, "AA", "UpdateManagement")
  location = azurerm_resource_group.UpdateManagement.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name
  sku_name = "Basic"
  
}

resource "azurerm_log_analytics_workspace" "UpdateManagement" {
    name = "KJB-LA-UpdateManagement"
    location = azurerm_resource_group.UpdateManagement.location
    resource_group_name = azurerm_resource_group.UpdateManagement.name
    sku = "PerGB2018"
    retention_in_days = 30
  
}

resource "azurerm_log_analytics_linked_service" "UpdateManagement" {
  resource_group_name = azurerm_resource_group.UpdateManagement.name
  workspace_id = azurerm_log_analytics_workspace.UpdateManagement.id
  read_access_id = azurerm_automation_account.UpdateManagement.id
}

resource "azurerm_log_analytics_solution" "UpdateManagement" {
  solution_name = "Updates"
  location = azurerm_resource_group.UpdateManagement.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name
  workspace_resource_id = azurerm_log_analytics_workspace.UpdateManagement.id
  workspace_name = azurerm_log_analytics_workspace.UpdateManagement.name

  plan {
    publisher = "Microsoft"
    product = "OMSGallery/Updates"
  }
}

resource "azurerm_monitor_diagnostic_setting" "UpdateManagement" {
  name = "UpdateManagement"
  target_resource_id = azurerm_automation_account.UpdateManagement.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.UpdateManagement.id

  log {
    category = "JobLogs"
  }
  log {
    category = "JobStreams"
  }
  log {
    category = "DscNodeStatus"
  }

}

resource "azurerm_monitor_action_group" "UpdateManagement" {
  name = "Update Management Action Group"
  resource_group_name = azurerm_resource_group.UpdateManagement.name
  short_name = "UMAlert1"

  email_receiver {
    name = "Kevin Barlow"
    email_address = "kevinba@softcat.com"
  }
  
}

resource "azurerm_monitor_scheduled_query_rules_alert" "UpdateManagement" {
  name = "Update Management Alert 1"
  location = azurerm_resource_group.UpdateManagement.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name

  action {
    action_group = [azurerm_monitor_action_group.UpdateManagement.id]
    email_subject = "Alert 1 Email Subject"
  }

  data_source_id = azurerm_log_analytics_workspace.UpdateManagement.id
  description = "Alert 1 Description"
  query = "AzureDiagnostics | where ResourceType contains 'AUTOMATION' | where (ResultDescription contains 'Suspended' and  ResultType == 'In Progress') or (ResultType == 'Failed') or (ResultType == 'Suspended')| parse ResultDescription with * 'JobId=' JobId '] to be ' Status '. Status will be discovered from exception.' *| summarize max(TimeGenerated) by RunbookName_s, JobId_g, ResultType, ResultDescription, ChildJobId = JobId, Status"
  severity = 4
  frequency = 5
  time_window = 5

  trigger {
    operator = "GreaterThan"
    threshold = 0
  }
}
