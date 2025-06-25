locals {
ami_id =data.aws_ami.joindevops.id
  bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id
  public_subnet_id = split("," , data.aws_ssm_parameter.public_subnet_ids)  # convert list id1 ,id2 -->
  
 common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
}