
# Provides an SES email identity resource
resource "aws_ses_email_identity" "mdm_email_identity" {
  email = var.mdm_email_from_address
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_user" "user" {
  name = "MDMNewsNotificationIAMUser"
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

# Attaches a Managed IAM Policy to SES Email Identity resource
data "aws_iam_policy_document" "policy_document" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }
}

# Provides an IAM policy attached to a user.
resource "aws_iam_policy" "policy" {
  name   = "mdm_email_policy"
  policy = data.aws_iam_policy_document.policy_document.json
}

# Attaches a Managed IAM Policy to an IAM user
resource "aws_iam_user_policy_attachment" "user_policy" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}

# IAM user credentials output
output "smtp_username" {
  value = aws_iam_access_key.access_key.id
}

output "smtp_password" {
  value     = aws_iam_access_key.access_key.ses_smtp_password_v4
  sensitive = true
}