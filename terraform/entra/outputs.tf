output "user_principal_names" {
  description = "Sign-in names for the three lab users."
  value       = { for k, u in azuread_user.lab : k => u.user_principal_name }
}

output "group_names" {
  description = "Groups to assign to the AWS IAM Identity Center enterprise app."
  value       = [azuread_group.aws_engineers.display_name, azuread_group.aws_admins.display_name]
}

output "user_passwords" {
  description = "Read with: terraform output -json user_passwords"
  value       = { for k, p in random_password.user : k => p.result }
  sensitive   = true
}
