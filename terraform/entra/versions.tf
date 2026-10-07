terraform {
  required_version = ">= 1.6"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Authenticates with the Azure CLI session:
#   az login --tenant <lab tenant>.onmicrosoft.com --allow-no-subscriptions
# No client secret is created or stored for this lab.
provider "azuread" {}
