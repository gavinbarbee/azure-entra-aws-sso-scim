# The tenant's initial .onmicrosoft.com domain, so no domain is hard-coded.
data "azuread_domains" "initial" {
  only_initial = true
}

locals {
  domain = data.azuread_domains.initial.domains[0].domain_name

  users = {
    engineer = {
      upn_prefix = "${var.name_prefix}-awseng"
      given_name = "Avery"
      surname    = "Engineer"
      department = "Engineering"
    }
    cloudadmin = {
      upn_prefix = "${var.name_prefix}-awsadmin"
      given_name = "Casey"
      surname    = "Cloudadmin"
      department = "IT"
    }
    noaccess = {
      upn_prefix = "${var.name_prefix}-awsnoaccess"
      given_name = "Morgan"
      surname    = "Finance"
      department = "Finance"
    }
  }
}

resource "random_password" "user" {
  for_each         = local.users
  length           = 20
  special          = true
  override_special = "!#%*-_"
}

# AWS IAM Identity Center requires first name, last name, and display name
# on every provisioned user, so all three are always set.
resource "azuread_user" "lab" {
  for_each = local.users

  user_principal_name   = "${each.value.upn_prefix}@${local.domain}"
  mail                  = "${each.value.upn_prefix}@${local.domain}"
  display_name          = "${each.value.given_name} ${each.value.surname}"
  given_name            = each.value.given_name
  surname               = each.value.surname
  department            = each.value.department
  password              = random_password.user[each.key].result
  force_password_change = false
}

# Only these two groups are assigned to the AWS app, so only their members
# are provisioned. Morgan Finance is in neither and must never reach AWS.
resource "azuread_group" "aws_engineers" {
  display_name     = "grp-${var.name_prefix}-aws-engineers"
  description      = "Read-only access to the AWS account through IAM Identity Center."
  security_enabled = true
  members          = [azuread_user.lab["engineer"].object_id]
}

resource "azuread_group" "aws_admins" {
  display_name     = "grp-${var.name_prefix}-aws-admins"
  description      = "Administrator access to the AWS account through IAM Identity Center."
  security_enabled = true
  members          = [azuread_user.lab["cloudadmin"].object_id]
}
