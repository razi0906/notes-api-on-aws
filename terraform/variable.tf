variable "product" {
  type        = string
  default     = "crowdstrike_audits"
  description = "Project/Product name WRT the resources"
}

variable "environment" {
  type        = string
  description = "environment value to be used in the resource tags"
}

variable "default_tags" {
  type        = map(string)
  description = "default tags for all the resources"
}

variable "project_prefix" {
  type    = string
  default = "cyber"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
