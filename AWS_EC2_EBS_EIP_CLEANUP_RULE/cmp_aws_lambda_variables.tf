#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# AWS EC2 Start and Stop,EIP,EBS Cleanup - Variables
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

variable "schedule_ec2_start_expression_at_morning" {
    default = "cron(0 0 * * ? *)"
}

variable "schedule_ec2_stop_expression_at_night" {
    default = "cron(0 0 * * ? *)"
}

variable "function_name_start" {
  default = "ec2-start"
}

variable "function_name_stop" {
  default = "ec2-stop"
}

variable "handler_start" {
  default = "ec2_start.start_lambda_handler"
}

variable "handler_stop" {
  default = "ec2_stop.stop_lambda_handler"
}

variable "handler_ebs_list" {
  default = "unused-ebs-vol-list.lambda_handler"
}

variable "handler_ebs_deletion" {
  default = "unused-ebs-volumes-deletion.lambda_handler"
}

variable "schedule_ebs_expression_list" {
    default = "cron(0 0 * * ? *)"
}

variable "schedule_ebs_expression_deletion" {
    default = "cron(0 0 * * ? *)"
}

variable "runtime" {
  default = "python3.7"
}
variable "protocol" {
default = "email"
}

variable "endpoint" {
type =  string
default = "Rajesh.Nandimandala@unisys.com"
  
}

variable "statement_id" {
default = "AllowExecutionFromCloudWatch"
}

variable "action" {
default = "lambda:InvokeFunction"
}

variable "principal" {
default = "events.amazonaws.com"
}

variable "ebs_function_name_list" {
  default = "ebs-volumes-list"
}

variable "ebs_function_name_deletion" {
  default = "ebs-volumes-deletion"
}

variable "schedule_eip_expression_list" {
    default = "cron(0 0 * * ? *)"
}

variable "schedule_eip_expression_deletion" {
    default = "cron(0 0 * * ? *)"
}

variable "function_eip_name_list" {
  default = "unassigned-eip-list"
}

variable "function_eip_name_deletion" {
  default = "unassigned-eip-deletion"
}

variable "handler_eip_list" {
  default = "unassigned-eip-list.lambda_handler"
}

variable "handler_eip_deletion" {
  default = "unassigned-eip-deletion.lambda_handler"
}

variable "backupdays" {
  default = "resource deletion days"
}