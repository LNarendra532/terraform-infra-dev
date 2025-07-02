# front end security grupt
module "frontend" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  sg_description = var.frontend_sg_description
  environment = var.environment
  sg_name = var.frontend_sg_name
    vpc_id = local.vpc_id  #vpc_id = data.aws_ssm_parameter.vpc_id.value

}
# bastion/jump server security groupId creation
module "bastion" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  sg_description = var.bastion_sg_description
  environment = var.environment
  sg_name = var.bastion_sg_name
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value
}

# catalogue server security groupId creation
module "catalogue" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  sg_description = var.bastion_sg_description
  environment = var.environment
  sg_name = var.bastion_sg_name
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value
}
module "user" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  sg_description = var.bastion_sg_description
  environment = var.environment
  sg_name = "user"
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "cart" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
 sg_description = var.bastion_sg_description
  environment = var.environment
  sg_name = "cart"
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value
}


module "shipping" {
    source = "../../terraform-aws-securitygroup"
    project = var.project
    environment = var.environment

    sg_name = "shipping"
    sg_description = "for shipping"
    vpc_id = local.vpc_id
}

module "payment" {
    source = "../../terraform-aws-securitygroup"
    
    project = var.project
    environment = var.environment

    sg_name = "payment"
    sg_description = "for payment"
    vpc_id = local.vpc_id
}


# alb- security groupId creation
module "backend_alb" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

  sg_description = "backend_alb"
  
  sg_name = "security group for backend-alb "
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "vpn" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

  sg_description = "vpn"
  
  sg_name = "security group for vpn "
    vpc_id = local.vpc_id 
    #vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "mongodb" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

  sg_description = "vpn"
  
  sg_name = "security group for mongodb "
    vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value

}
module "rabbitmq" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

  sg_description = "vpn"
  sg_name = "security group for rabbitmq "
  vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value

}

module "mysql" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

  sg_description = "vpn"
  sg_name = "security group for mysql "
  vpc_id = local.vpc_id 
     #vpc_id = data.aws_ssm_parameter.vpc_id.value

}
module "reddis" {  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  environment = var.environment

 sg_description = "vpn"
  sg_name = "security group for reddis "
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
  count = length(var.vpn_ports)
  type              = "ingress"
  from_port         = var.vpn_ports[count.index]
  to_port           = var.vpn_ports[count.index]
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}



#MONGODB
resource "aws_security_group_rule" "mongodb_vpn_ssh" {
  count = length(var.mongodb_ports_vpn)
  type              = "ingress"
  from_port         = var.mongodb_ports_vpn[count.index]
  to_port           = var.mongodb_ports_vpn[count.index]
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source VPN server
  security_group_id = module.mongodb.sg_id # destionation ALB
}

resource "aws_security_group_rule" "mongodb_catalogue" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = module.catalogue.sg_id
  security_group_id = module.mongodb.sg_id
}

resource "aws_security_group_rule" "mongodb_user" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id = module.mongodb.sg_id
}

#REDDIS
resource "aws_security_group_rule" "redis_vpn_ssh" {
  count = length(var.redis_ports_vpn)
  type              = "ingress"
  from_port         = var.redis_ports_vpn[count.index]
  to_port           = var.redis_ports_vpn[count.index] 
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.redis.sg_id
}

resource "aws_security_group_rule" "redis_user" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id = module.redis.sg_id
}

resource "aws_security_group_rule" "redis_cart" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id = module.redis.sg_id
}


#MYSQL
resource "aws_security_group_rule" "mysql_vpn_ssh" {
  count = length(var.mysql_ports_vpn)
  type              = "ingress"
  from_port         = var.mysql_ports_vpn[count.index]
  to_port           = var.mysql_ports_vpn[count.index]
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.mysql.sg_id
}

resource "aws_security_group_rule" "mysql_shipping" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id = module.mysql.sg_id
}


#RABBITMQ
# opened as part of some jira-ticket from db team
resource "aws_security_group_rule" "rabbitmq_vpn_ssh" {
  count = length(var.rabbitmq_ports_vpn)
  type              = "ingress"
  from_port         = var.rabbitmq_ports_vpn[count.index]
  to_port           = var.rabbitmq_ports_vpn[count.index]
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.rabbitmq.sg_id
}
resource "aws_security_group_rule" "rabbitmq_payment" {
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id = module.rabbitmq.sg_id
}

#CATALOGUE
# ingress rule backend_alb.sg_id,vpn.sg_id ,vpn.sg_id ,bastion.sg_id ,catalogue.sg_id
resource "aws_security_group_rule" "catalogue_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.catalogue.sg_id
}

##Cart
resource "aws_security_group_rule" "cart_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id = module.cart.sg_id
}

#Shipping
resource "aws_security_group_rule" "shipping_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id = module.shipping.sg_id
}

#Payment
resource "aws_security_group_rule" "payment_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id = module.payment.sg_id
}

#Backend ALB
resource "aws_security_group_rule" "backend_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend_alb.sg_id
}
resource "aws_security_group_rule" "backend_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "backend_alb_cart" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "backend_alb_shipping" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "backend_alb_payment" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id = module.backend_alb.sg_id
}

#Frontend
resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_frontend_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend_alb.sg_id
  security_group_id = module.frontend.sg_id
}

#Frontend ALB
resource "aws_security_group_rule" "frontend_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "frontend_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "backend_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend_alb.sg_id
}
