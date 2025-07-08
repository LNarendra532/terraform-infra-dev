resource "aws_instance" "bastion" {
  ami           =local.ami_id #data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id]

  subnet_id = local.public_subnet_id

   # need more for terraform - OTher will get space usage eroor
  root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
  }


  tags = merge(

    local.common_tags, {
      Name = "${var.project}-${var.environment}-Bastion-server" #interpolation
    }
  )
    
  }


  resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]
  
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.redis.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y yum-utils",
      "sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo",
      "sudo yum -y install terraform"
      
    ]
  }
}
