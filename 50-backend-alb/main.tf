module "backend_alb" {
  source = "terraform-aws-modules/alb/aws"  # opensource module
  version = "9.16.0"  #ALB Module Version
  name    = "${var.project}-${var.environment}-backend-alb" #roboshop-dev-backend-alb
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids
  security_groups = local.backend_alb_sg_id
  create_security_group = false # we are using our own secrity group  
  internal = true # for private load balancer


#https://github.com/terraform-aws-modules/terraform-aws-alb 
#
  # enable_deletion_protection = false

 
  tags = merge(

    local.common_tags, {
      Name = "${var.project}-${var.environment}-backend-alb" #interpolation
    }
  )
}
 /* 1.requests will goes to load balanacer 
 | 2.load balancer listens on port number 80  | 
 then load balancer will send on port 8080 to TARGET-GROUP */
 
#aws_lb_listener will attached to backend_alb
  resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h4>Hello <h1>NAREN</h1>  Iam Form Bacekend_Alb</h4>"
      status_code  = "200"
    }
  }
  }

  resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name    = "*.backend-dev.${var.zone_name}"
  type    = "A"

  alias {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id
    evaluate_target_health = true
    # https://github.com/terraform-aws-modules/terraform-aws-alb check ouputs
  }
}