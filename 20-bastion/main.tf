resource "aws_instance" "bastion" {
  ami           =local.ami_id #data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id]

  subnet_id = local.public_subnet_id

  tags = merge(

    local.common_tags, {
      Name = "${var.project}-${var.environment}-Bastion-server" #interpolation
    }
  )
    
  }
