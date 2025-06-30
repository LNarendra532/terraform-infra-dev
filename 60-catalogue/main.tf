#Creating Catalogue instances 
resource "aws_instance" "catalogue" {
  ami           =local.ami_id #data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]

  subnet_id = local.private_subnet_id
  #iam_instance_profile = "EC2RoleToFetchSSMParams"

  tags = merge(

    local.common_tags, {
      Name = "${var.project}-${var.environment}-catalogue-server" #interpolation
    }
  )
    
  }
# target group opening on 8080 http
resource "aws_lb_target_group" "catalogue" {
  name        = "${var.environment}-${var.project}-catalogue"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.vpc_id

  health_check {
    healthy_threshold = 2
    interval = 5
    matcher = "200-299"
    path = "/health"
    port = 8080
    timeout = 2
    unhealthy_threshold = 3
  }
}
  

# Null_resource - it will create any resource , it will connect to the instances and we can perform our actions.
resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  
  # Copies the catalogue.sh file into /tmp
  provisioner "file" {
    source      = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/catalogue.sh",
      "sudo sh /tmp/catalogue.sh catalogue"
    ]
  }
}

