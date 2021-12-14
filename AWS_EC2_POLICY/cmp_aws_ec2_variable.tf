#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# EC2 custom policy - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
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
variable "userGroup" {
    description =   "UserGroup , on which the ploicy to be applied "
    type        =   string
    default     =   "Test-policy-group"
}