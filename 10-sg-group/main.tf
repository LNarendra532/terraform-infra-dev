# front end security grupt
module "frontend" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  description = var.frontend_sg_description
  environment = var.environment
  sg_name = var.frontend_sg_name
    vpc_id = local.vpc_id  #vpc_id = data.aws_ssm_parameter.vpc_id.value

}
# bastion/jump server security groupId creation
module "bastion" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  description = var.bastion_sg_description
  environment = var.environment
  sg_name = var.bastion_sg_name
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value

}

# alb- security groupId creation
module "backend_alb" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

  description = "backend_alb"
  
  sg_name = "security group for backend-alb "
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "vpn" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

  description = "vpn"
  
  sg_name = "security group for vpn "
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value

}
# Bastoin/jump host accepting connection from my laptop
resource "aws_security_group_rule" "bastion_laptop_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = module.bastion.sg_id
}
#backend alb accepting connection from bastoin host on port 80
resource "aws_security_group_rule" "backend_alb_connection_from_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id      = module.bastion.sg_id
  security_group_id = module.backend_alb.sg_id
}


#VPN ports to connet to private hosts 22, 443,1194,943
resource "aws_security_group_rule" "vpn_ssh_https_1194_443" {
  count = length(vpn.ports)
  type              = "ingress"
  from_port         = var.vpn_ports[count.index]
  to_port           = var.vpn_ports[count.index]
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}



