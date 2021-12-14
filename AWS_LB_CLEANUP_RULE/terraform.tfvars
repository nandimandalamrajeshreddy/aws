#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Terraform - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

prefix                                  =           "cfcmp"
environment                             =           "prd"
region                                  =           "us-east-2"
profile                                 =           "default"
schedule_expression_at_morning          =           "cron(0 8 ? * * *)"
schedule_expression_at_night            =           "cron(0 22 ? * * *)"
backup_days								= 			7
#account_id								=			769004552675
#SnsTopic 								=			"SnapshotAlerts"