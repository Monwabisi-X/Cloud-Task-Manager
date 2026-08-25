data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- IAM role for the instances (least-privilege, no access keys in code) ---
# Attaches only SSM Session Manager access, so you can shell into instances
# in the private subnets without SSH keys or a bastion host — this is how
# you got the sh-5.2$ prompt for the docker compose command already.
resource "aws_iam_role" "app_instance" {
  name = "cloud-task-manager-app-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "cloud-task-manager-app-instance-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app_instance" {
  name = "cloud-task-manager-app-instance-profile"
  role = aws_iam_role.app_instance.name
}

# --- Launch Template ---
resource "aws_launch_template" "app" {
  name_prefix   = "cloud-task-manager-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.app_instance.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_tokens   = "required" # enforce IMDSv2
    http_endpoint = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type            = "gp3"
      encrypted              = true
      delete_on_termination  = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", {
    github_repo_url = var.github_repo_url
    app_port        = var.app_port
    db_host         = aws_db_instance.main.address
    db_port         = aws_db_instance.main.port
    db_name         = var.db_name
    db_username     = var.db_username
    # urlencode() so characters like @ : $ / in the password can't break
    # the connection-string format, independent of the bash heredoc fix.
    db_password = urlencode(var.db_password)
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "cloud-task-manager-app"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Auto Scaling Group ---
resource "aws_autoscaling_group" "app" {
  name = "cloud-task-manager-asg"

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "cloud-task-manager-app"
    propagate_at_launch = true
  }
}

# --- Auto Scaling policies (Week 4 will hook CloudWatch alarms to these) ---
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "cloud-task-manager-scale-up"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment      = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "cloud-task-manager-scale-down"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment      = -1
  cooldown               = 120
}
