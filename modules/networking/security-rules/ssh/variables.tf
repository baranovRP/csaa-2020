###
variable "security_group_id" {
  description = "The security group id"
  type        = string
  default     = ""
}

variable "cidr_blocks" {
  description = "The list of cidr blocks"
  type        = list(string)
  default     = []
}



