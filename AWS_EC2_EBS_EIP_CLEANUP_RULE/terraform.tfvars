#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Terraform - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

prefix                                          =           "cfcmp"
environment                                     =           "prd"
profile                                         =           "root"
schedule_ec2_start_expression_at_morning        =           "cron(0 8 ? * * *)"
schedule_ec2_stop_expression_at_night           =           "cron(0 11 ? * * *)"
schedule_ebs_expression_list                    =           "cron(0 8 ? * * *)"
schedule_ebs_expression_deletion                =           "cron(0 11 ? * * *)"
schedule_eip_expression_list                    =           "cron(0 8 ? * * *)"
schedule_eip_expression_deletion                =           "cron(0 11 ? * * *)"
endpoint                                        =           "Rajesh.Nandimandala@unisys.com"
backupdays                                      =           2