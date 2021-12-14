/**********************************************************************
* Project                       	: S3 Lifecycle Policy
*
* Module Name                   	: AWS S3 bucket Lifecycle Policy
* Author                        	: Rajesh Nandimandalam
*
* Date created                  	: 20211115
*
* Purpose                       	: Terraform module for S3 Lifecycle Policy.

* Resources Implemented      		  : Cloudtrail,S3 
*
* Revision History              	: Date        Author     			Revision (Date in YYYYMMDD format)
* 									  20211115	  Akundi Rama			20211115
*
**********************************************************************/

provider "aws" {
  region                            =       var.region
  profile                           =       var.profile
  access_key                     =       "AKIA3GDB6IHRXSWCO37P"
  secret_key               =       "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"
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
data "aws_iam_policy" "arn_s3" {
  arn                                =      var.arn_s3
}

data "aws_iam_policy" "arn_cw" {
  arn                                =      var.arn_cw
}
data "aws_iam_policy" "arn_cwfl" {
  arn                                =      var.arn_cwfl
}

resource "aws_iam_role_policy_attachment" "policy-attach-s3" {
  role                               =        aws_iam_role.iam_for_lambda.name
  policy_arn                         =        data.aws_iam_policy.arn_s3.arn
}

resource "aws_iam_role_policy_attachment" "policy-attach-cloudwatch" {
  role                               =        aws_iam_role.iam_for_lambda.name
  policy_arn                         =        data.aws_iam_policy.arn_cw.arn
}
resource "aws_iam_role_policy_attachment" "policy-attach-cloudwatchfulllog" {
  role                               =        aws_iam_role.iam_for_lambda.name
  policy_arn                         =        data.aws_iam_policy.arn_cwfl.arn
}

resource "aws_lambda_function" "s3_lambda" {
  role                               =        aws_iam_role.iam_for_lambda.arn
  handler                            =        var.handler_s3
  timeout                            =        var.timeout 
  memory_size                        =        var.memory_size
  runtime                            =        var.runtime
  filename                           =        "s3-lifecycle-transition-policy.zip"
  function_name                      =        "${var.prefix}-${var.environment}-${var.function_name_s3}"
  source_code_hash                   =        filebase64sha256("s3-lifecycle-transition-policy.zip")

}
resource "aws_cloudwatch_event_rule" "s3_lifecycle_rule" {
  name                               =        "${var.prefix}-${var.environment}-s3-lifecycle-rule"
  description                        =        "This rule will apply s3 lifecycle policy on newly created resources"

    event_pattern = <<PATTERN
		{
		  "source": [
			"aws.s3"
		  ],
		  "detail-type": [
			"AWS API Call via CloudTrail"
		  ],
		  "detail": {
			"eventSource": [
			  "s3.amazonaws.com"
			],
			"eventName": [
			    "CreateBucket"  
			]
		  }
		}
	PATTERN
}


resource "aws_cloudwatch_event_target" "s3_lifecycle_target" {
    rule                             =          aws_cloudwatch_event_rule.s3_lifecycle_rule.name
    target_id                        =          "${var.prefix}-${var.environment}-S3-lambda-lifecycle"
    arn                              =          aws_lambda_function.s3_lambda.arn
}


resource "aws_lambda_permission" "s3_lifecycle_action" {
  statement_id                       =          "AllowExecutionFromCloudWatch"
  action                             =          "lambda:InvokeFunction"
  function_name                      =          aws_lambda_function.s3_lambda.function_name
  principal                          =          "events.amazonaws.com"
  source_arn                         =          aws_cloudwatch_event_rule.s3_lifecycle_rule.arn
}
