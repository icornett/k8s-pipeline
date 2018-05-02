variable "project_name" {
  description = "The project name for your resources"
}

variable "environment_name" {
  description = "The environment name that you're trying to deploy"
}

variable "azure_region" {
  description = "The region in Azure that you're trying to deploy to"
}

variable "account_tier" {
  description = "Choose either standard (HDD) or Premium (SSD) storage"
  default     = "standard"
}

variable "account_replication_type" {
  description = "The replication type you'd like to deploy.  Globally Redudant Storage (GRS), Locally Redundant Storage (LRS), or Zone Redundancy (ZRS)"
  default     = "LRS"
}
