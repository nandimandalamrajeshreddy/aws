/**********************************************************************
* Project                       	: AWS EC2 Cleanup & IaC Templates
*
* Module Name                   	: AWS EC2 Cleanup
* Author                        	: Rajesh Nandimandalam
*
* Date created                  	: 20211115
*
* Purpose                       	: Terraform module for EC2 Cleanup.

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
  name                              =        "${var.prefix}-${var.environment}-iam-for-lambda-ec2"

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

resource "aws_lambda_function" "start_lambda" {
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_start
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "ec2alert.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_name_start}"
  source_code_hash                   =        filebase64sha256("ec2alert.zip")

  environment {
    variables = {
	  
      SnsTopic = data.aws_sns_topic.topic.arn,
	  BACKUP_DAYS = var.backup_days
    }
  }
}

resource "aws_lambda_function" "stop_lambda" {
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_stop
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "ec2delete.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_name_stop}"
  source_code_hash                   =        filebase64sha256("ec2delete.zip")

  environment {
    variables = {
      SnsTopic = data.aws_sns_topic.topic.arn,
	  BACKUP_DAYS = var.backup_days
	  
    }
  }
}
resource "aws_cloudwatch_event_rule" "at_morning" {
  name                               =        "${var.prefix}-${var.environment}-ec2alert"
  description                        =        "EC2 instances list without BASEINFRA tag alert every monday morning at 8 AM"
  schedule_expression                =        var.schedule_expression_at_night
}

resource "aws_cloudwatch_event_rule" "at_night" {
  name                               =        "${var.prefix}-${var.environment}-ec2delete"
  description                        =        "EC2 instances list without BASEINFRA tag  delete every friday  night at 10 PM"
  schedule_expression                =        var.schedule_expression_at_night
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
  statement_id                       =          "AllowExecutionFromCloudWatch"
  action                             =          "lambda:InvokeFunction"
  function_name                      =          aws_lambda_function.start_lambda.function_name
  principal                          =          "events.amazonaws.com"
  source_arn                         =          aws_cloudwatch_event_rule.at_morning.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_stop_instances" {
  statement_id                       =          "AllowExecutionFromCloudWatch"
  action                             =          "lambda:InvokeFunction"
  function_name                      =           aws_lambda_function.stop_lambda.function_name
  principal                          =          "events.amazonaws.com"
  source_arn                         =           aws_cloudwatch_event_rule.at_night.arn
}