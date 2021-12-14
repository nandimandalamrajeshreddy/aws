#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Terraform - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

prefix                                  =           "cfcmp"
environment                             =           "prd"
region                                  =           "us-east-2"
profile                                 =           "Default"
snapshot_alerts_expression          	=           "cron(30 16 * * ? *)"
snapshot_deletion_expression            =           "cron(30 23 * * ? *)"
BackupDays								=			"7"
SnapDeleteTime							=			"7"