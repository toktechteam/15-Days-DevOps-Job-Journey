variable "region" {}
variable "profile" {}

variable "key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
  default     = ""  # Empty string as default
}