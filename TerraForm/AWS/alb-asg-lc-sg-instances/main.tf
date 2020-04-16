provider "aws" {
  profile                    = var.profile
  region                     = var.aws_region 
  
}

# ----------------- Create Load Balancer -------------------

resource "aws_lb" "my-test-lb" {
  name                       = "my-test-lb"
  internal                   = false
  load_balancer_type         = "application"
  ip_address_type            = "ipv4"
  subnets                    = [var.subnet_id1, var.subnet_id2]
  security_groups            = [aws_security_group.alb-sg.id]

  # enable_deletion_protection = true

  tags = {
    Name                     = "my-test-alb"
  }
}

resource "aws_lb_target_group" "my-alb-tg" {
  health_check {
    interval                 = 30
    path                     = "/"
    protocol                 = "HTTP"
    timeout                  = 5
    healthy_threshold        = 5
    unhealthy_threshold      = 2
    matcher                  = "200-299"
  }

  name                       = "my-alb-tg"
  port                       = 80
  protocol                   = "HTTP"
  vpc_id                     = var.vpc_id
  target_type                = "instance"
}

resource "aws_lb_listener" "my-test-lb" {
  load_balancer_arn          = aws_lb.my-test-lb.arn
  port                       = "80"
  protocol                   = "HTTP"
  # port                      = "443"
  # protocol                  = "HTTPS"
  # ssl_policy                = "ELBSecurityPolicy-2016-08"
  # certificate_arn           = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type                     = "forward"
    target_group_arn         = aws_lb_target_group.my-alb-tg.arn
  }
}

resource "aws_security_group" "alb-sg" {
  name                       = "my-alb-sg"
  vpc_id                     = var.vpc_id
}

resource "aws_security_group_rule" "http_allow" {
  from_port                  = 80
  protocol                   = "tcp"
  security_group_id          = aws_security_group.alb-sg.id
  to_port                    = 80
  type                       = "ingress"
  cidr_blocks                = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_outbound_access" {
  from_port                  = 0
  protocol                   = "-1"
  security_group_id          = aws_security_group.alb-sg.id
  to_port                    = 0
  type                       = "egress"
  cidr_blocks                = ["0.0.0.0/0"]
}

# --------------------Launch Configuration---------------

resource "aws_launch_configuration" "as_conf" {
  name_prefix                = "terraform-lc-example-"
  image_id                   = var.aws_ami
  instance_type              = var.instance_type

  security_groups            = [aws_security_group.alb-sg.name]
  user_data                  = file("userdata.sh")

  lifecycle {
    create_before_destroy    = true
  }
}

# --------------------- Autoscaling Group ---------------

resource "aws_autoscaling_group" "terraform-asg-example" {
  name                       = "terraform-asg-example"
  launch_configuration       = aws_launch_configuration.as_conf.name
  min_size                   = 2
  max_size                   = 4
  # vpc_zone_identifier       =       
  availability_zones         = ["us-east-1a","us-east-1c"]
  target_group_arns          = [aws_lb_target_group.my-alb-tg.arn]
  health_check_type          = "ELB"
  health_check_grace_period  = 30
  desired_capacity           = 2
  force_delete               = true

  lifecycle {
    create_before_destroy    = true
  }
}

resource "aws_autoscaling_policy" "terraform-asg-policy" {
  name                       = "terraform-asg-policy"
  autoscaling_group_name     = aws_autoscaling_group.terraform-asg-example.name
  policy_type                = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "60"
  }
}