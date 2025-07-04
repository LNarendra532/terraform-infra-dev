locals {
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)# minimum two required
    frontend_alb_sg_id =data.aws_ssm_parameter.frontend_alb_sg_id.value
    acm_certificate_arn = data.aws_ssm_parameter.acm_certificate_arn


     common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
}