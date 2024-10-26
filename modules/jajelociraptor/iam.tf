data "aws_iam_policy_document" "jajelociraptor_s3_ses_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.jajelociraptor_s3_bucket.arn}",
      "${aws_s3_bucket.jajelociraptor_s3_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["arn:aws:ses:${data.aws_region.aws_region_information.name}:${data.aws_caller_identity.aws_information.account_id}:identity/${aws_ses_email_identity.jajelociraptor_email_admin.email}"]
  }

  statement {
    actions = [
      "ses:GetIdentityVerificationAttributes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "jajelociraptor_ec2_role" {
  name = "jajelociraptor_${var.name}_ec2_s3_ses_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "jajelociraptor_s3_ses_policy" {
  name   = "jajelociraptor_${var.name}_s3_ses_policy"
  role   = aws_iam_role.jajelociraptor_ec2_role.id
  policy = data.aws_iam_policy_document.jajelociraptor_s3_ses_policy.json
}

resource "aws_iam_policy_attachment" "jajelociraptor_ssm_role_attach" {
  name       = "jajelociraptor_${var.name}_ssm_role_attach"
  roles      = [aws_iam_role.jajelociraptor_ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jajelociraptor_ec2_instance_profile" {
  name = "jajelociraptor_${var.name}_ec2_instance_profile"
  role = aws_iam_role.jajelociraptor_ec2_role.name
}
