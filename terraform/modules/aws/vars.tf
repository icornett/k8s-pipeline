variable "AWS_ACCESS_KEY" {
  type        = "string"
  description = "Access credential for AWS"
}

variable "AWS_SECRET_KEY" {
  type        = "string"
  description = "Secret credential for AWS"
}

variable "AWS_REGION" {
  type        = "string"
  default     = "us-west-2"
  description = "Region to deploy assets to, defaults to US West 2 (Oregon)"
}
