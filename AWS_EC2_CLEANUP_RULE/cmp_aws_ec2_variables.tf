#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# AWS EC2 Cleanup - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

variable "region" {
    default ="us-east-2"
}
variable "profile" {
    default ="root"
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
variable "environment" {
    description =   "Environment , which needs to be appended to aws policies name "
    type        =   string
    default     =   "prd"
}
variable "backup_days" {
	default = 7
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

variable "schedule_expression_at_morning" {
    default = "cron(0 0 * * ? *)"
}

variable "schedule_expression_at_night" {
    default = "cron(0 0 * * ? *)"
}

variable "function_name_start" {
  default = "ec2alert"
}

variable "function_name_stop" {
  default = "ec2delete"
}

variable "handler_start" {
  default = "ec2alert.lambda_handler"
}

variable "handler_stop" {
  default = "ec2delete.lambda_handler"
}

variable "runtime" {
  default = "python3.7"
}