data "aws_ami" "joindevops" {

  most_recent      = true
  owners           = ["973714476881"]

  filter {
        name   = "name"
        values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
        name   = "root-device-type"
        values = ["ebs"]
    }
     filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ssm_parameter" "mongodb_sg_id" {
 name  = "/${var.project}/${var.environment}/mongodb_sg_id"  

  # from the /10-sg-group/ module parameters.tf we should access the vpc_id for the for the sg_group

}


data "aws_ssm_parameter" "database_subnet_ids" {
 name  = "/${var.project}/${var.environment}/database_subnet_ids"  

  # from the /00-vpc/ module parameters.tf we should access the vpc_id for the for the sg_group
}

data "aws_ssm_parameter" "redis_sg_id" {
  name = "/${var.project}/${var.environment}/redis_sg_id"
}

data "aws_ssm_parameter" "mysql_sg_id" {
  name = "/${var.project}/${var.environment}/mysql_sg_id"
}

data "aws_ssm_parameter" "rabbitmq_sg_id" {
  name = "/${var.project}/${var.environment}/rabbitmq_sg_id"
}

data "aws_ssm_parameter" "database_subnet_ids" {
  name = "/${var.project}/${var.environment}/database_subnet_ids"
}

data "aws_ssm_parameter" "mysql_root_password" {
  name = "/${var.project}/mysql/mysql_root_password"
}

# data "aws_ssm_parameter" "mysql_root_password" {
#   name = "${roboshop/mysql/mysql_root_password}"
#   with_decryption = true
# }

# /roboshop/mysql/mysql_root_password