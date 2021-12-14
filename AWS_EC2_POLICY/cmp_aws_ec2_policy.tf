/**********************************************************************
* Project                       	: AWS EC2 policy  & IaC Templates
*
* Module Name                   	: AWS custom EC2/policy
* Author                        	: Rajesh Nandimandalam
*
* Date created                  	: 20212110
*
* Purpose                       	: Terraform module for restricted deployments through custom policy.

* Resources Implemented      		: Custom IAM policy for EC2 instances 
*
* Revision History              	: Date        Author     			Revision (Date in YYYYMMDD format)
* 									  20212110	  Akundi Rama			20212110
*
**********************************************************************/
resource "aws_iam_policy" "policy-region" {
  name        = "${var.prefix}-${var.environment}-aws-ec2RegionRestriction-policy"
  description = "This policy will restrict user to deploy ec2 instances only in specified location"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*",
            "Condition": {
                "ForAllValues:StringEquals": {
                    "aws:RequestedRegion": [
                        "us-east-2",
                        "us-east-1"
                    ]
                }
            }
        }
    ]
}
EOT
}
resource "aws_iam_group_policy_attachment" "region" {
  group      = "${var.userGroup}"
  policy_arn = aws_iam_policy.policy-region.arn
}
resource "aws_iam_policy" "policy-instanceType" {
  name        = "${var.prefix}-${var.environment}-aws-ec2InstanceTypeRestriction-policy"
  description = "This policy will restrict user to deploy ec2 instances only with specified instanceType"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "limitedSize",
            "Effect": "Deny",
            "Action": "ec2:RunInstances",
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "ForAnyValue:StringNotLike": {
                    "ec2:InstanceType": [
                        "*.nano",
                        "*.small",
                        "*.micro",
                        "*.medium"
                    ]
                }
            }
        }
    ]
}
EOT
}
resource "aws_iam_group_policy_attachment" "instanceType" {
  group      = "${var.userGroup}"
  policy_arn = aws_iam_policy.policy-instanceType.arn
}

