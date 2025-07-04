data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"   

  # from the /00-vpc/ module parameters.tf we should access the vpc_id for the for the sg_group
}

data "aws_ssm_parameter" "public_subnet_ids" {
 name  = "/${var.project}/${var.environment}/public_subnet_ids"

} 


data "aws_ssm_parameter" "frontend_alb_sg_id" {
 name  = "/${var.project}/${var.environment}/frontend_alb_sg_id"

} 

data "aws_ssm_parameter" "acm_certificate_arn" {
  name  = "/${var.project}/${var.environment}/acm_certificate_arn"

}