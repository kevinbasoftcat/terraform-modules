provider "azurerm" {
  features { 
  }
}

resource "random_string" "randomstring" {
  length = 5
  special = false
  lower = true
  number = true
}
resource "azurerm_resource_group" "UpdateManagement" {
  name = var.rgname
  location = "UK South"
}

resource "azurerm_automation_account" "UpdateManagement" {
  name = "${var.resourceprefix}-AutoAcct-${random_string.randomstring.result}"
  location = azurerm_resource_group.UpdateManagement.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name
  sku_name = "Basic"
  
}

resource "azurerm_log_analytics_workspace" "UpdateManagement" {
    name = "${var.resourceprefix}-OMS-${random_string.randomstring.result}"
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
  name = "${var.resourceprefix}-PatchingAlerts"
  resource_group_name = azurerm_resource_group.UpdateManagement.name
  short_name = "${var.resourceprefix}-PA"

  email_receiver {
    name = "Kevin Barlow"
    email_address = "kevinba@softcat.com"
  }
  
}

resource "azurerm_monitor_scheduled_query_rules_alert" "UpdateManagementAlertFailedSuspended" {
  name = "${var.resourceprefix} Patching Job Status - Failed or Suspended"
  location = azurerm_resource_group.UpdateManagement.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name

  action {
    action_group = [azurerm_monitor_action_group.UpdateManagement.id]
    email_subject = "Patching job has been detected as Failed or Suspended (PLEASE LOG A TICKET and assign to the Platform Microsoft Team)"
  }

  data_source_id = azurerm_log_analytics_workspace.UpdateManagement.id
  description = "Emails an alert when a automated patching job returns as failed or suspended"
  query = "AzureDiagnostics | where ResourceType contains 'AUTOMATION' | where (ResultDescription contains 'Suspended' and  ResultType == 'In Progress') or (ResultType == 'Failed') or (ResultType == 'Suspended')| parse ResultDescription with * 'JobId=' JobId '] to be ' Status '. Status will be discovered from exception.' *| summarize max(TimeGenerated) by RunbookName_s, JobId_g, ResultType, ResultDescription, ChildJobId = JobId, Status"
  severity = 4
  frequency = 5
  time_window = 5

  trigger {
    operator = "GreaterThan"
    threshold = 0
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert" "UpdateManagementAlertOlder60days" {
  name = "${var.resourceprefix} Security Patches Missing - Older than 60 Days"
  location = azurerm_resource_group.UpdateManagement.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name

  action {
    action_group = [azurerm_monitor_action_group.UpdateManagement.id]
    email_subject = "Servers with security patches missing older than 60 days (PLEASE LOG A TICKET and assign to the Platform Microsoft Team)"
  }

  data_source_id = azurerm_log_analytics_workspace.UpdateManagement.id
  description = "Emails an alert when servers with security patches older than 60 days are detected"
  query = "UpdateSummary | where OldestMissingSecurityUpdateInDays > 60 | summarize by Computer, TotalUpdatesMissing | render barchart kind=unstacked"
  severity = 4
  frequency = 1440
  time_window = 1440
  throttling = 10000

  trigger {
    operator = "GreaterThan"
    threshold = 0
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert" "UpdateManagementAlertOlder90days" {
  name = "${var.resourceprefix} Security Patches Missing - Older than 90 Days"
  location = azurerm_resource_group.UpdateManagement.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name

  action {
    action_group = [azurerm_monitor_action_group.UpdateManagement.id]
    email_subject = "Servers with security patches missing older than 90 days (PLEASE LOG A TICKET and assign to the Platform Microsoft Team)"
  }

  data_source_id = azurerm_log_analytics_workspace.UpdateManagement.id
  description = "Emails an alert when servers with security patches older than 90 days are detected"
  query = "UpdateSummary | where OldestMissingSecurityUpdateInDays > 90 | summarize by Computer, TotalUpdatesMissing | render barchart kind=unstacked"
  severity = 4
  frequency = 1440
  time_window = 1440
  throttling = 10000

  trigger {
    operator = "GreaterThan"
    threshold = 0
  }
}