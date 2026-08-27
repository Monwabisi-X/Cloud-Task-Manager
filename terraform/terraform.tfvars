aws_region = "af-south-1"

vpc_cidr = "10.0.0.0/16"

availability_zones = {
  az_a = "af-south-1a"
  az_b = "af-south-1b"
}

instance_type        = "t3.micro"
app_port             = 5000
asg_min_size         = 2
asg_max_size         = 4
asg_desired_capacity = 2

db_name           = "cloudapp"
db_username       = "postgres"
db_instance_class = "db.t3.micro"

dockerhub_image = "monwabisix/cloud-task-manager"
github_repo     = "Monwabisi-X/Cloud-Task-Manager"
github_branch   = "main"

# db_password is intentionally NOT set here. This file is version-controlled
# It is set instead with:
#   export TF_VAR_db_password="your-strong-password-here"
