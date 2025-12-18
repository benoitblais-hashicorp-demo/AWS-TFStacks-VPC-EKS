variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "delete" {
  type    = bool
  default = false
}