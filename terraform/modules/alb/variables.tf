variable "environment" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "subnet_public_1a_id" {
  type        = string
}

variable "subnet_public_1c_id" {
  type        = string
}

variable "security_group_alb_id" {
  type        = string
}

variable "cert_lb_arn" {
  type        = string
}