output "ec2_ssm_instance_profile_id" {
  value = aws_iam_instance_profile.ec2_ssm_instance_profile.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}