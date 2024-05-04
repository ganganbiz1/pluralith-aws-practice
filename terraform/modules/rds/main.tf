resource "aws_db_subnet_group" "aurora" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = [var.subnet_private_1a_id, var.subnet_private_1c_id]

  tags = {
    Name = "${var.environment}-rds-subnet-group"
  }
}

resource "aws_db_parameter_group" "this" {
  name = "${var.environment}-parameters-aurora-mysql80"
  family = "aurora-mysql8.0"

  parameter {
    name = "slow_query_log"
    value = "1"
  }
  parameter {
    name = "long_query_time"
    value = "1"
  }
  parameter {
    name = "log_queries_not_using_indexes"
    value = "1"
  }
  parameter {
    name = "max_connections"
    value = "2000"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${var.environment}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.1" # Aurora MySQL 8.0のバージョン
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [var.security_group_rds_id]
  master_username         = "admin"
  master_password         = "tmppassword" # passwordの管理は別途対応
  skip_final_snapshot     = true
  depends_on = [aws_db_parameter_group.this]
}

resource "aws_rds_cluster_instance" "aurora_primary_instance" {
  identifier          = "${var.environment}-aurora-primary-instance"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.t3.medium"
  engine              = "aurora-mysql"
  engine_version      = "8.0.mysql_aurora.3.04.1"
  db_parameter_group_name = aws_db_parameter_group.this.name
  depends_on = [aws_db_parameter_group.this]
}

resource "aws_rds_cluster_instance" "aurora_replica_instance" {
  identifier          = "${var.environment}-aurora-replica-instance"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.t3.medium"
  engine              = "aurora-mysql"
  engine_version      = "8.0.mysql_aurora.3.04.1"
  db_parameter_group_name = aws_db_parameter_group.this.name
  promotion_tier      = 15
  depends_on = [aws_db_parameter_group.this]
}
