resource "aws_instance" "main" {
  ami           = "ami-034c9ca2bdde7b472"
  instance_type = "t2.micro"
  subnet_id = var.subnet_private_1a_id
  vpc_security_group_ids=[var.security_group_bastion_id]
  iam_instance_profile = var.ec2_ssm_instance_profile_id
  tags = {
    Name = "${var.environment}-bastion"
  }
}