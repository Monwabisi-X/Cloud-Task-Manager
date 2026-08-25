variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to be used for the subnets"
  type        = map(string)
}

variable "instance_type" {
  description = "EC2 instance type for the application Auto Scaling Group"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Port the Flask/Gunicorn application listens on inside the container"
  type        = number
  default     = 5000
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
  default     = "cloudapp"
}

variable "db_username" {
  description = "Master username for the RDS PostgreSQL instance"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password for the RDS PostgreSQL instance. Do NOT commit a real value — pass via TF_VAR_db_password or a local, gitignored .tfvars file."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS, in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL major engine version for RDS. Left as just the major version (no minor) so AWS auto-selects the latest supported minor version, since specific minor versions get retired from new-instance creation over time."
  type        = string
  default     = "16"
}

variable "github_repo_url" {
  description = "Git URL the EC2 instances clone on boot to pull the application code"
  type        = string
  default     = "https://github.com/Monwabisi-X/Cloud-Task-Manager.git"
}