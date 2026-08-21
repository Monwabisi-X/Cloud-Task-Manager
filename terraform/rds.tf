resource "aws_db_subnet_group" "main" {
  name = "cloud-task-manager-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "cloud-task-manager-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "cloud-task-manager-db"
  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = false
  publicly_accessible = false

  # Dev/portfolio settings. For a real production workload, set these
  # to true/appropriate retention and take a final snapshot instead.
  skip_final_snapshot       = true
  deletion_protection       = false
  backup_retention_period   = 1
  auto_minor_version_upgrade = true

  tags = {
    Name = "cloud-task-manager-db"
  }
}
