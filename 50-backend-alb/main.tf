module "backend_alb" {
  source = "terraform-aws-modules/alb/aws"  # opensource module
  version = "9.16.0"
  name    = "${var.project}-${var.environment}-backend-alb" #roboshop-dev-backend-alb
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids
  security_groups = local.backend_alb_sg_id
  create_security_group = false # we are using our own secrity group  
  internal = true # for privarte load balancer

 
  tags = merge(

    local.common_tags, {
      Name = "${var.project}-${var.environment}-backend-alb" #interpolation
    }
  )
}

#aws_lb_listener will attached to backend_alb
  resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h4>Hello Iam Form Bacekend_Alb</h4>"
      status_code  = "200"
    }
  }
  }