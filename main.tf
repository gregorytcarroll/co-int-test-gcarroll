#---------------------------------#
# Checkout Demo                   #
#                                 #
# Deploys two webservers to AWS   #
#---------------------------------#

# Configure AWS connection, secrets are in terraform.tfvars
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Get availability zones for the region specified in var.region
data "aws_availability_zones" "all" {}

# Create autoscaling policy -> target at a 70% average CPU load
resource "aws_autoscaling_policy" "co-test-policy" {
  name                   = "co-asg-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.co-asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Create an autoscaling group
resource "aws_autoscaling_group" "co-asg" {
  name = "co-asg"
  launch_configuration = aws_launch_configuration.co-lc.id
  availability_zones = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 10

  load_balancers = ["${aws_elb.co-elb.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "co-ASG"
    propagate_at_launch = true
  }
}

# Create launch configuration
resource "aws_launch_configuration" "co-lc" {
  name = "co-lc"
  image_id = "ami-04122be15033aa7ec"
  instance_type = "t2.nano"
  key_name = var.key_name
  security_groups = [aws_security_group.co-lc-sg.id]

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

# Create the ELB
resource "aws_elb" "co-elb" {
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

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }
}

# Create security group that's applied the launch configuration
resource "aws_security_group" "co-lc-sg" {
  name = "co-lc-sg"

  # Inbound HTTP from anywhere
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
    cidr_blocks = [var.my_ip/32]
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

# Create security group that's applied to the ELB
resource "aws_security_group" "co-elb-sg" {
  name = "co-elb-sg"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
