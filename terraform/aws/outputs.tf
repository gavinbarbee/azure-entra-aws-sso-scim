output "permission_sets" {
  description = "Permission set names and session lengths."
  value = {
    (aws_ssoadmin_permission_set.readonly.name) = aws_ssoadmin_permission_set.readonly.session_duration
    (aws_ssoadmin_permission_set.admin.name)    = aws_ssoadmin_permission_set.admin.session_duration
  }
}

output "assignments" {
  description = "Which synced group gets which permission set."
  value = {
    (var.engineers_group) = aws_ssoadmin_permission_set.readonly.name
    (var.admins_group)    = aws_ssoadmin_permission_set.admin.name
  }
}
