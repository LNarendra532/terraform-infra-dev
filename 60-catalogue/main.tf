/*  target group opening on 8080 http TO SEND REQUEST TO TARGET GROUP # while creating auto-scaling group we have to choose as exisiting alb
 1.requests will goes to load balanacer 
 | 2.load balancer listens on port number 80  | 
 then load balancer will send on port 8080 to TARGET-GROUP */
resource "aws_lb_target_group" "catalogue" {
  name        = "${var.environment}-${var.project}-catalogue"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  deregistration_delay = 120  # seconds to delete the target group

  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"  # status code
    path = "/health"
    port = 8080
    timeout = 5
    unhealthy_threshold = 5
  }
}



#Creating Catalogue instances 
resource "aws_instance" "catalogue" {
  ami           =local.ami_id #data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]

  subnet_id = local.private_subnet_id
  #iam_instance_profile = "EC2RoleToFetchSSMParams"

  tags = merge(

    local.common_tags, {
      Name = "${var.project}-${var.environment}-catalogue" #interpolation
    }
  )
    
  }

  

# Null_resource - it will not create any resource but, it will connect to the instances and we can perform our actions.
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
      "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id   
  state       = "stopped"
  depends_on = [ terraform_data.catalogue ]  # Once completing the configuratoin then it will stop the ec2-instance
}


resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.environment}-${var.project}-catalogue"
  source_instance_id = aws_instance.catalogue.id

  depends_on = [ aws_ec2_instance_state.catalogue ] # After stopping the instance it will take the ami_id

    tags = merge(
    local.common_tags, {
      Name = "${var.project}-${var.environment}-catalogue" #interpolation
    })

}

# AWS command line to delete the instances
resource "terraform_data" "catalogue_delete" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  
  
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }
  depends_on = [ aws_ami_from_instance.catalogue ] 
  #destroying/terminating the terraform after taking the configured ami_id  provisioner-local-exec
}

# while performing the lauch template EBS volme and Instance will create
resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"

  image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate" # if traafic is down going to delete the instance
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  update_default_version = true # each time you update, new version will become default

  tag_specifications {
    resource_type = "instance"
    # EC2 tags created by ASG
    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
  }

  # volume tags created by ASG
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
  }

  # launch template tags
  tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
  )

}

resource "aws_autoscaling_group" "catalogue" {
  name                 = "${var.project}-${var.environment}-catalogue"
  desired_capacity   = 1
  max_size           = 10      # instances numbers min, max, desired
  min_size           = 1
  target_group_arns = [aws_lb_target_group.catalogue.arn]
  vpc_zone_identifier  = local.private_subnet_ids  # we neded to give both subnets
  health_check_grace_period = 120
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
    content{
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
    
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]   # after changing the launch template it will trigger 
    /* after changing the lauch template it will trigger  -
     then auto-scaling retrigger and it will take new lauch-template create new 
     insatnce and delete old instances. */
  }

  timeouts{
    delete = "15m"
  }
}
#aws_autoscaling_group on what basis we have to increase the insatnces
# CPU utilization goes above 75% → Auto Scaling additional instances it willcreate.
resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${var.project}-${var.environment}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

# DNS name తో request వస్తే → ఈ Target Group కి forward అవుతుంది.
resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn   # backend alb listeners
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-${var.environment}.${var.zone_name}"]

      # if we give like catalogue.backend.dev.narendaws-84s.site it will goes to target group arn
    }
  }
}