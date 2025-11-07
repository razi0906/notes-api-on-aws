locals {
  # merging additional tags to default_tags from tfvars
  default_tags = merge(
    var.default_tags, { environment = var.environment, product = var.product }
  )
}