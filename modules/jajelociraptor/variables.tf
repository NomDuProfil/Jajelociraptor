variable "name" {
  type        = string
  default     = "jajelociraptor"
  description = "Name for the project"
}

variable "admin_whitelist" {
  type        = list(string)
  description = "IP for admin access"
}

variable "admin_username" {
  type        = string
  description = "Username for admin connexion"
}

variable "admin_email" {
  type        = string
  description = "Email admin (to receive all the information)"
}

variable "volume_size" {
  type        = number
  description = "Volume for the instance"
  default     = 8
}


variable "instance_type" {
  type        = string
  description = "Instance type for the server"
  default     = "t2.micro"
}
