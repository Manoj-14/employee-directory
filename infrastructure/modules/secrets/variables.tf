variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable secret_name {
    type        = string
  description = "name of the secret"
}

variable secret_string {
  type        = string
  description = "private key"
}
