#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# AWS S3 Lifecycle Policy - Variables
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
variable "environment" {
    description =   "Environment , which needs to be appended to aws policies name "
    type        =   string
    default     =   "prd"
}
variable "arn_s3" {
    default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

variable "arn_cw" {
    default = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
variable "arn_cwfl" {
    default = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
variable "timeout" {
    default = 300
}

variable "memory_size" {
    default = 128
}


variable "function_name_s3" {
  default = "s3-lifecycle-transition-policy"
}

variable "handler_s3" {
  default = "s3-lifecycle-transition-policy.lambda_handler"
}
variable "runtime" {
  default = "python3.9"
}