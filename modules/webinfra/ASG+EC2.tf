data "aws_availability_zones" "all" {}


# Create ASG policy - Target is set at 80% CPU Load. At above 80%, instances will be spun up
resource "aws_autoscaling_policy" "co-test-policy" {
  name                   = "co-asg-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.co_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

# Create the ASG and set limitations
resource "aws_autoscaling_group" "co_asg" {
  name = "co-asg"
  launch_configuration = aws_launch_configuration.co_lc.id
  availability_zones = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 10

  load_balancers = ["${aws_elb.co_elb.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "co-ASG"
    propagate_at_launch = true
  }
}

# Create launch configuration for the ASG instances
resource "aws_launch_configuration" "co_lc" {
  name = "co-lc"
  image_id = "ami-04122be15033aa7ec"
  instance_type = "t2.nano"
  key_name = var.key_name
  security_groups = [aws_security_group.co_lc-sg.id]

  iam_instance_profile = var.iam_instance_profile

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              sudo service httpd start
              sudo chkconfig httpd on
              sudo aws s3 sync s3://${var.s3_bucket}/var/www/html/ /var/www/html/
              hostname -f >> /var/www/html/ping.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Create security group that's applied the launch configuration
resource "aws_security_group" "co_lc-sg" {
  name = "co-lc-sg"

  # Inbound HTTP from anywhere (adjust dependent on security requirements)
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create the ELB
resource "aws_elb" "co_elb" {
  name = "co-elb"
  security_groups = [aws_security_group.co-elb-sg.id]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    #target = "TCP:${var.server_port}"
    target = "HTTP:${var.server_port}/ping.html"
  }

  # Incoming HTTP Request listener
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }
}


# Security Group Creation for ELB
resource "aws_security_group" "co-elb-sg" {
  name = "co-elb-sg"

  # Allow all outbound (adjust dependent on security requirements)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere (adjust dependent on security requirements)
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
