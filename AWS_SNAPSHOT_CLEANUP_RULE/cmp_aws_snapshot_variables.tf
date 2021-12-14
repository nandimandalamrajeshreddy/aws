#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# AWS Snapshot Cleanup - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

variable "region" {
    default ="us-east-2"
}
variable "profile" {
    default ="Default"
}

variable "prefix" {
    description =   "Prefix , which needs to be appended to aws policies name "
    type        =   string
    default     =   "cfcmp"
}

variable "account_id" {
    description =   "account_id"
    type        =   number
    default     =   769004552675
}

variable "SnsTopic" {
    description =   "SnsTopic"
    type        =   string
    default     =   "SnapshotAlerts"
}

variable "BackupDays" {
    description =   "BackupDays"
    type        =   string
    default     =   "7"
}

variable "SnapDeleteTime" {
    description =   "SnapDeleteTime"
    type        =   string
    default     =   "7"
}

variable "environment" {
    description =   "Environment , which needs to be appended to aws policies name "
    type        =   string
    default     =   "prd"
}
variable "arn_ec2" {
    default = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
variable "arn_sns" {
    default = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

variable "arn_cw" {
    default = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
variable "timeout" {
    default = 300
}

variable "memory_size" {
    default = 128
}

variable "snapshot_alerts_expression" {
    default = "cron(30 12 * * ? *)"
}

variable "snapshot_deletion_expression" {
    default = "cron(30 14 * * ? *)"
}

variable "function_name_snapshot_alerts" {
  default = "snapshot-list-alert"
}

variable "function_name_snapshot_deletion" {
  default = "snapshot-deletion-action"
}

variable "handler_start" {
  default = "snapshot-list-alert.lambda_handler"
}

variable "handler_stop" {
  default = "snapshot-deletion-action.lambda_handler"
}

variable "runtime" {
  default = "python3.8"
}