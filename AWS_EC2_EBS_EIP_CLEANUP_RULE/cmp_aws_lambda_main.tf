/**********************************************************************
* Project                       	: AWS EC2 Stop and Start,EIP,EBS Cleanup & IaC Templates
*
* Module Name                   	: AWS EC2 Stop and Start,EIP,EBS Cleanup
* Author                        	: Rajesh 
*
* Date created                  	: 20211115
*
* Purpose                       	: Terraform module for EC2 Stop and Start,EIP,EBS Cleanup 

* Resources Implemented      		: SNS,IAM,Lambda,CloudWatch
*
* Revision History              	: Date        Author     			Revision (Date in YYYYMMDD format)
* 									  20211115	  Akundi Rama			20211115
*
**********************************************************************/

provider "aws" {
  region                            =       var.region
  profile                           =       var.profile
}

resource "aws_iam_role" "iam_for_lambda" {
  name                              =        "${var.prefix}-${var.environment}-iam-for-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy" "arn_ec2" {
  arn                                =      var.arn_ec2
}

data "aws_iam_policy" "arn_sns" {
  arn                                =      var.arn_sns
}

data "aws_iam_policy" "arn_cw" {
  arn                                =      var.arn_cw
}

resource "aws_iam_role_policy_attachment" "policy-attach-ec2" {
  role                               =        aws_iam_role.iam_for_lambda.name
  policy_arn                         =        data.aws_iam_policy.arn_ec2.arn
}

resource "aws_iam_role_policy_attachment" "policy-attach-sns" {
  role                               =        aws_iam_role.iam_for_lambda.name
  policy_arn                         =        data.aws_iam_policy.arn_sns.arn
}

resource "aws_iam_role_policy_attachment" "policy-attach-cloudwatch" {
  role                               =        aws_iam_role.iam_for_lambda.name
  policy_arn                         =        data.aws_iam_policy.arn_cw.arn
}

resource "aws_sns_topic" "topic" {
  name = "${var.prefix}-${var.environment}-aws-cost-opt-alert-topic"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = var.protocol
  endpoint  = var.endpoint
}

resource "aws_lambda_function" "start_lambda" {
depends_on = [
  aws_sns_topic_subscription.email-target
]
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_start
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "ec2_start.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_name_start}"
  source_code_hash                   =        filebase64sha256("ec2_start.zip")

  environment {
    variables = {
      SnsTopic = aws_sns_topic.topic.arn
    }
  }
}

resource "aws_lambda_function" "stop_lambda" {
depends_on = [
  aws_sns_topic_subscription.email-target
]
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_stop
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "ec2_stop.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_name_stop}"
  source_code_hash                   =        filebase64sha256("ec2_stop.zip")

  environment {
    variables = {
      SnsTopic = aws_sns_topic.topic.arn
    }
  }
}

resource "aws_lambda_function" "ebs_volumes_list_lambda" {
depends_on = [
  aws_sns_topic_subscription.email-target
]
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_ebs_list
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "unused-ebs-vol-list.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.ebs_function_name_list}"
  source_code_hash                   =        filebase64sha256("unused-ebs-vol-list.zip")

  environment {
    variables = {
      SnsTopic = aws_sns_topic.topic.arn
      BackupDays = var.backupdays
    }
  }
}

resource "aws_lambda_function" "ebs_volumes_deletion_lambda" {
depends_on = [
  aws_sns_topic_subscription.email-target
]
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_ebs_deletion
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "unused-ebs-volumes-deletion.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.ebs_function_name_deletion}"
  source_code_hash                   =        filebase64sha256("unused-ebs-volumes-deletion.zip")

  environment {
    variables = {
      SnsTopic = aws_sns_topic.topic.arn
    }
  }
}

resource "aws_lambda_function" "eip_list_lambda" {
  depends_on = [
    aws_sns_topic_subscription.email-target
  ]
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_eip_list
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "unassigned-eip-list.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_eip_name_list}"
  source_code_hash                   =        filebase64sha256("unassigned-eip-list.zip")

  environment {
    variables = {
      SnsTopic = aws_sns_topic.topic.arn
      BackupDays = var.backupdays
    }
  }
}

resource "aws_lambda_function" "eip_deletion_lambda" {
  depends_on = [
    aws_sns_topic_subscription.email-target
  ]
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_eip_deletion
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "unassigned-eip-deletion.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_eip_name_deletion}"
  source_code_hash                   =        filebase64sha256("unassigned-eip-deletion.zip")

  environment {
    variables = {
      SnsTopic = aws_sns_topic.topic.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "at_morning" {
  name                               =        "${var.prefix}-${var.environment}-at-morning-ec2-start"
  description                        =        "EC2 Instances Strated  scheduler every monday morning at 8 AM"
  schedule_expression                =        var.schedule_ec2_start_expression_at_morning
}

resource "aws_cloudwatch_event_rule" "at_night" {
  name                               =        "${var.prefix}-${var.environment}-at-night-ec2-stop"
  description                        =        "EC2 Instances Stopped  scheduler every friday  night at 10 PM"
  schedule_expression                =        var.schedule_ec2_stop_expression_at_night
}

resource "aws_cloudwatch_event_target" "lambda_on_morning" {
    rule                             =          aws_cloudwatch_event_rule.at_morning.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-morning"
    arn                              =          aws_lambda_function.start_lambda.arn
}

resource "aws_cloudwatch_event_target" "lambda_on_night" {
    rule                             =          aws_cloudwatch_event_rule.at_night.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-night"
    arn                              =          aws_lambda_function.stop_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_start_instances" {
  statement_id                       =          var.statement_id
  action                             =          var.action
  function_name                      =          aws_lambda_function.start_lambda.function_name
  principal                          =          var.principal
  source_arn                         =          aws_cloudwatch_event_rule.at_morning.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_stop_instances" {
  statement_id                       =          var.statement_id
  action                             =          var.action
  function_name                      =          aws_lambda_function.stop_lambda.function_name
  principal                          =          var.principal
  source_arn                         =          aws_cloudwatch_event_rule.at_night.arn
}


resource "aws_cloudwatch_event_rule" "today" {
  name                               =        "${var.prefix}-${var.environment}-unused-ebs-volumes-list"
  description                        =        "Unused ebs volumes list"
  schedule_expression                =        var.schedule_ebs_expression_list
}

resource "aws_cloudwatch_event_rule" "tomorrow" {
  name                               =        "${var.prefix}-${var.environment}-unused-ebs-volumes-deletion"
  description                        =        "Unused ebs volumes deletion"
  schedule_expression                =        var.schedule_ebs_expression_deletion
}

resource "aws_cloudwatch_event_target" "lambda_on_today" {
    rule                             =          aws_cloudwatch_event_rule.today.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-today"
    arn                              =          aws_lambda_function.ebs_volumes_list_lambda.arn
}

resource "aws_cloudwatch_event_target" "lambda_on_tomorrow" {
    rule                             =          aws_cloudwatch_event_rule.tomorrow.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-tomorrow"
    arn                              =          aws_lambda_function.ebs_volumes_deletion_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_unused_ebs_volumes_list" {
  statement_id                       =          var.statement_id
  action                             =          var.action
  function_name                      =          aws_lambda_function.ebs_volumes_list_lambda.function_name
  principal                          =          var.principal
  source_arn                         =          aws_cloudwatch_event_rule.today.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_unused_ebs_volumes_deletion" {
  statement_id                       =          var.statement_id
  action                             =          var.action
  function_name                      =           aws_lambda_function.ebs_volumes_deletion_lambda.function_name
  principal                          =          var.principal
  source_arn                         =           aws_cloudwatch_event_rule.tomorrow.arn
}

resource "aws_cloudwatch_event_rule" "eip-today" {
  name                               =        "${var.prefix}-${var.environment}-unassigned-eip-list"
  description                        =        "Unassigned eip list"
  schedule_expression                =        var.schedule_eip_expression_list
}

resource "aws_cloudwatch_event_rule" "eip-tomorrow" {
  name                               =        "${var.prefix}-${var.environment}-unassigned-eip-deletion"
  description                        =        "Unassigned eip deletion"
  schedule_expression                =        var.schedule_eip_expression_deletion
}

resource "aws_cloudwatch_event_target" "eip-lambda_on_today" {
    rule                             =          aws_cloudwatch_event_rule.eip-today.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-today"
    arn                              =          aws_lambda_function.eip_list_lambda.arn
}

resource "aws_cloudwatch_event_target" "eip-lambda_on_tomorrow" {
    rule                             =          aws_cloudwatch_event_rule.eip-tomorrow.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-tomorrow"
    arn                              =          aws_lambda_function.eip_deletion_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_unassigned_eip_list" {
  statement_id                       =          var.statement_id
  action                             =          var.action
  function_name                      =          aws_lambda_function.eip_list_lambda.function_name
  principal                          =          var.principal
  source_arn                         =          aws_cloudwatch_event_rule.eip-today.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_unassigned_eip_deletion" {
  statement_id                       =          var.statement_id
  action                             =          var.action
  function_name                      =           aws_lambda_function.eip_deletion_lambda.function_name
  principal                          =          var.principal
  source_arn                         =           aws_cloudwatch_event_rule.eip-tomorrow.arn
}