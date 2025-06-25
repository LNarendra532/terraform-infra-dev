resource "aws_ssm_parameter" "frontend_sg_id" {
  name  = "/${var.project}/${var.environment}/frontend_sg_id"
  type  = "String"
  value = module.frontend.sg_id 
  # sg_id is exposes as output.tf /terraform-aws-securitygroup/output.tf
   # we are storing the frontend_sg_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}

resource "aws_ssm_parameter" "bastion_sg_id" {
  name  = "/${var.project}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = module.bastion.sg_id 
  # sg_id is exposes as output.tf /terraform-aws-securitygroup/output.tf check in output.tf
   # we are storing the frontend_sg_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}