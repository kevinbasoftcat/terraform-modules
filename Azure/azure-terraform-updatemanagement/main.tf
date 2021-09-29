provider "azurerm" {
  features { 
  }
}

resource "random_string" "random_string" {
  length = 5
  special = false
  lower = true
  number = true
}
resource "azurerm_resource_group" "update_management" {
  name = var.rg_name
  location = var.location
}

resource "azurerm_automation_account" "update_management" {
  name = "${var.resource_prefix}-AutoAcct-${random_string.random_string.result}"
  location = azurerm_resource_group.update_management.location
  resource_group_name = azurerm_resource_group.UpdateManagement.name
  sku_name = "Basic"
  
}

resource "azurerm_log_analytics_workspace" "update_management" {
    name = "${var.resource_prefix}-OMS-${random_string.random_string.result}"
    location = azurerm_resource_group.update_management.location
    resource_group_name = azurerm_resource_group.update_management.name
    sku = "PerGB2018"
    retention_in_days = 30
  
}

resource "azurerm_log_analytics_linked_service" "update_management" {
  resource_group_name = azurerm_resource_group.update_management.name
  workspace_id = azurerm_log_analytics_workspace.update_management.id
  read_access_id = azurerm_automation_account.update_management.id
}

resource "azurerm_log_analytics_solution" "update_management" {
  solution_name = "Updates"
  location = azurerm_resource_group.update_management.location
  resource_group_name = azurerm_resource_group.update_management.name
  workspace_resource_id = azurerm_log_analytics_workspace.update_management.id
  workspace_name = azurerm_log_analytics_workspace.update_management.name

  plan {
    publisher = "Microsoft"
    product = "OMSGallery/Updates"
  }
}

resource "azurerm_monitor_diagnostic_setting" "update_management" {
  name = "UpdateManagement"
  target_resource_id = azurerm_automation_account.update_management.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.update_management.id

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

resource "azurerm_monitor_action_group" "update_management" {
  name = "${var.resource_prefix}-PatchingAlerts"
  resource_group_name = azurerm_resource_group.update_management.name
  short_name = "${var.resource_prefix}-PA"

  email_receiver {
    name = var.emailreceivername
    email_address = var.emailreceiveremail
  }
  
}

resource "azurerm_monitor_scheduled_query_rules_alert" "update_management_alert_failed_suspended" {
  name = "${var.resource_prefix} Patching Job Status - Failed or Suspended"
  location = azurerm_resource_group.update_management.location
  resource_group_name = azurerm_resource_group.update_management.name

  action {
    action_group = [azurerm_monitor_action_group.update_management.id]
    email_subject = "Patching job has been detected as Failed or Suspended (PLEASE LOG A TICKET and assign to the Platform Microsoft Team)"
  }

  data_source_id = azurerm_log_analytics_workspace.update_management.id
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

resource "azurerm_monitor_scheduled_query_rules_alert" "update_management_alert_older_60_days" {
  name = "${var.resource_prefix} Security Patches Missing - Older than 60 Days"
  location = azurerm_resource_group.update_management.location
  resource_group_name = azurerm_resource_group.update_management.name

  action {
    action_group = [azurerm_monitor_action_group.update_management.id]
    email_subject = "Servers with security patches missing older than 60 days (PLEASE LOG A TICKET and assign to the Platform Microsoft Team)"
  }

  data_source_id = azurerm_log_analytics_workspace.update_management.id
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

resource "azurerm_monitor_scheduled_query_rules_alert" "update_management_alert_older_90_days" {
  name = "${var.resource_prefix} Security Patches Missing - Older than 90 Days"
  location = azurerm_resource_group.update_management.location
  resource_group_name = azurerm_resource_group.update_management.name

  action {
    action_group = [azurerm_monitor_action_group.update_management.id]
    email_subject = "Servers with security patches missing older than 90 days (PLEASE LOG A TICKET and assign to the Platform Microsoft Team)"
  }

  data_source_id = azurerm_log_analytics_workspace.update_management.id
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