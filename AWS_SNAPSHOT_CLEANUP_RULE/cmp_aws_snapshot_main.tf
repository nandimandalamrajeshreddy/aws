/**********************************************************************
* Project                       	: AWS Snapshot Cleanup & IaC Templates
*
* Module Name                   	: AWS Snapshot Cleanup
* Author                        	: Rajesh Nandimandalam
*
* Date created                  	: 20211115
*
* Purpose                       	: Terraform module for Snapshot Cleanup.

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
  name                              =        "${var.prefix}-${var.environment}-iam-for-snapshotlambda"

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

resource "aws_lambda_function" "snapshot-alert" {
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_start
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "snapshot-list-alert.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_name_snapshot_alerts}"
  source_code_hash                   =        filebase64sha256("snapshot-list-alert.zip")

  environment {
    variables = {
     SNS_TOPIC = data.aws_sns_topic.topic.arn
	 BACKUP_DAYS = var.BackupDays
	 SNAP_DELETE_TIME = var.SnapDeleteTime
    }
  }
}

resource "aws_lambda_function" "snapshot-action" {
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_stop
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "snapshot-deletion-action.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_name_snapshot_deletion}"
  source_code_hash                   =        filebase64sha256("snapshot-deletion-action.zip")

  environment {
    variables = {
     SNS_TOPIC = data.aws_sns_topic.topic.arn
    }
  }
}
resource "aws_cloudwatch_event_rule" "snapshot-alert" {
  name                               =        "${var.prefix}-${var.environment}-snapshot-alert-rule"
  description                        =        "Snapshots alerts  scheduler everyday at 10 AM IST"
  schedule_expression                =        var.snapshot_alerts_expression
}

resource "aws_cloudwatch_event_rule" "snapshot-delete" {
  name                               =        "${var.prefix}-${var.environment}-snapshot-delete-rule"
  description                        =        "Snapshots deletion  scheduler everyday at 5 PM IST"
  schedule_expression                =         var.snapshot_deletion_expression
}

resource "aws_cloudwatch_event_target" "alert_event" {
    rule                             =          aws_cloudwatch_event_rule.snapshot-alert.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-snapalert"
    arn                              =          aws_lambda_function.snapshot-alert.arn
}

resource "aws_cloudwatch_event_target" "action_event" {
    rule                             =          aws_cloudwatch_event_rule.snapshot-delete.name
    target_id                        =          "${var.prefix}-${var.environment}-cw-lambda-snapaction"
    arn                              =          aws_lambda_function.snapshot-action.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_send_snapshot_alerts" {
  statement_id                       =          "AllowExecutionFromCloudWatch"
  action                             =          "lambda:InvokeFunction"
  function_name                      =          aws_lambda_function.snapshot-alert.function_name
  principal                          =          "events.amazonaws.com"
  source_arn                         =          aws_cloudwatch_event_rule.snapshot-alert.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_for_snapshot_action" {
  statement_id                       =          "AllowExecutionFromCloudWatch"
  action                             =          "lambda:InvokeFunction"
  function_name                      =           aws_lambda_function.snapshot-action.function_name
  principal                          =          "events.amazonaws.com"
  source_arn                         =           aws_cloudwatch_event_rule.snapshot-delete.arn
}