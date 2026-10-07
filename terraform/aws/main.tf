data "aws_ssoadmin_instances" "this" {}
data "aws_caller_identity" "current" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  account_id        = data.aws_caller_identity.current.account_id
}

# These groups are created in AWS by SCIM provisioning from Entra ID, not by
# Terraform. Terraform only looks them up, so Entra stays the source of truth.
data "aws_identitystore_group" "engineers" {
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.engineers_group
    }
  }
}

data "aws_identitystore_group" "admins" {
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.admins_group
    }
  }
}

# Read-only for engineers, with a longer session.
resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ps-gavinbarbee-readonly"
  description      = "Read-only access for engineers"
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Administrator access, with a short one-hour session.
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "ps-gavinbarbee-admin"
  description      = "Administrator access for cloud admins"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Access is granted to groups, never to individual users, so joiners and
# leavers are handled entirely by group membership in Entra ID.
resource "aws_ssoadmin_account_assignment" "engineers_readonly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_type     = "GROUP"
  principal_id       = data.aws_identitystore_group.engineers.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = local.account_id

  depends_on = [aws_ssoadmin_managed_policy_attachment.readonly]
}

resource "aws_ssoadmin_account_assignment" "admins_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_type     = "GROUP"
  principal_id       = data.aws_identitystore_group.admins.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = local.account_id

  depends_on = [aws_ssoadmin_managed_policy_attachment.admin]
}
