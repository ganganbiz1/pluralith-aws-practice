variable "environment" {
  type        = string
}

variable "subnet_private_1a_id" {
  type        = string
}

variable "subnet_private_1c_id" {
  type        = string
}

variable "security_group_ecs_id" {
  type        = string
}

variable "aws_lb_target_group_arn" {
  type        = string
}

variable "ecs_execution_role_arn" {
  type        = string
}
