resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id  
   # we are storing the vpc_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_subnet_ids"
  type  = "StringList"
  value = join("," , module.vpc.public_subnet_ids)  
   # we are storing the subnet_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project}/${var.environment}/private_subnet_ids"
  type  = "StringList"  # it will store like   id1 , id2   <---   ["id1" , "id2"]
  value = join("," , module.vpc.private_subnet_ids)  
   # we are storing the subnet_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project}/${var.environment}/database_subnet_ids"
  type  = "StringList"
  value = join("," , module.vpc.database_subnet_ids)  
   # we are storing the subnet_id in ssm paramerter by using the "aws_ssm_parameter" resource 
}