module "frontend_alb" {
  source = "terraform-aws-modules/alb/aws"  # opensource module
  version = "9.16.0"  #ALB Module Version
  name    = "${var.project}-${var.environment}-frontend-alb" #roboshop-dev-frontend-alb
  vpc_id  = local.vpc_id
  subnets = local.public_subnet_ids
  security_groups = local.frontend_alb_sg_id
  create_security_group = false # we are using our own secrity group  
  internal = false #  false means public load balancer


#https://github.com/terraform-aws-modules/terraform-aws-alb 
#
  # enable_deletion_protection = false

 
  tags = merge(

    local.common_tags, {
      Name = "${var.project}-${var.environment}-frontend-alb" #interpolation
    }
  )
}
 /* 1.requests will goes to load balanacer 
 | 2.load balancer listens on port number 80  | 
 then load balancer will send on "port-443" to  */
 
#aws_lb_listener will attached to frontend_alb
  resource "aws_lb_listener" "frontend_alb" {
  load_balancer_arn = module.frontend_alb.arn
  port              = "444"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.acm_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h4>Hello <h1>NAREN</h1>  Iam Form frontend_Alb</h4>"
      status_code  = "200"
    }
  }
  }

  resource "aws_route53_record" "frontend_alb" {
  zone_id = var.zone_id
  name    = "${var.environment}.${var.zone_name}"   #  *.narendaws-84s.site - cert name
  type    = "A"

  alias {
    name                   = module.frontend_alb.dns_name
    zone_id                = module.frontend_alb.zone_id
    evaluate_target_health = true
    # https://github.com/terraform-aws-modules/terraform-aws-alb check ouputs
  }
}