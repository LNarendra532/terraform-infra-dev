data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"   

  # from the /00-vpc/ module parameters.tf we should access the vpc_id for the for the sg_group
}

data "aws_ssm_parameter" "private_subnet_ids" {
 name  = "/${var.project}/${var.environment}/private_subnet_ids"

} 


data "aws_ssm_parameter" "backend_alb_sg_id" {
 name  = "/${var.project}/${var.environment}/backend_alb_sg_id"

} 