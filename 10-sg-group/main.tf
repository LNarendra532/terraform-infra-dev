module "frontend" {
  
  source = "../../terraform-aws-securitygroup"
  project = var.project
  description = var.frontend_sg_description
  environment = var.environment
  sg_name = var.frontend_sg_name
    vpc_id = local.vpc_id


}

