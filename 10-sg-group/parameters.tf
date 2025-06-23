resource "aws_ssm_parameter" "frontend_sg_id" {
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.frontend.sg_id
   # we are storing the vpc_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}