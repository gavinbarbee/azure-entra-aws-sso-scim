variable "aws_region" {
  description = "Region where IAM Identity Center is enabled."
  type        = string
  default     = "us-east-1"
}

variable "engineers_group" {
  description = "Entra group provisioned to AWS by SCIM that gets read-only access."
  type        = string
  default     = "grp-gavinbarbee-aws-engineers"
}

variable "admins_group" {
  description = "Entra group provisioned to AWS by SCIM that gets administrator access."
  type        = string
  default     = "grp-gavinbarbee-aws-admins"
}
