module "frontend" {  # front end security grupt
  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  description = var.frontend_sg_description
  environment = var.environment
  sg_name = var.frontend_sg_name
    vpc_id = local.vpc_id  #vpc_id = data.aws_ssm_parameter.vpc_id.value

}

module "bastion" {  # bastion/jump server security groupId
  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  description = var.bastion_sg_description
  environment = var.environment
  sg_name = var.bastion_sg_name
    vpc_id = local.vpc_id  #vpc_id = data.aws_ssm_parameter.vpc_id.value

}

resource "aws_security_group_rule" "bation_laptop_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Replace with your specific CIDR block
  # security_group_id = aws_security_group.example.id # Or your security group ID
  security_group_id = module.bastion.sg_id
}


