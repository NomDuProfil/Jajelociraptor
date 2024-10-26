resource "aws_ses_email_identity" "jajelociraptor_email_admin" {
  email = var.admin_email
}
