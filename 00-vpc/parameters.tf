resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id  
   # we are storing the vpc_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}