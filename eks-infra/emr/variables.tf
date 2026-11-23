variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "name_prefix" {
  description = "Name part to be attached to module resources."
  type        = string
  default     = "virtual-emr"
}

variable "tags" {
  description = "Resources tags."
  type        = map(string)
  default = {
    team = "devops"
  }
}