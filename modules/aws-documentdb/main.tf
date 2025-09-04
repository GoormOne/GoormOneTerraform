resource "aws_db_subnet_group" "docdb_subnet_group" {
  name       = var.document-db-sg-name
  subnet_ids = [data.aws_subnet.private-subnet3.id, data.aws_subnet.private-subnet4.id]
}


resource "aws_docdb_cluster_parameter_group" "custom_docdb_group" {
  family = "docdb5.0" # 클러스터의 엔진 패밀리와 일치해야 합니다.
  name = "my-custom-docdb-group"
  parameter {
    name  = "tls"
    value = "disabled"
  }

  parameter {
    name  = "audit_logs"
    value = "enabled" # 예시: 감사 로그를 활성화
  }
  parameter {
    name  = "change_stream_log_retention_duration"
    value = "10800" # 기본값인 10800초 (3시간) 설정
  }
  parameter {
    name  = "default_collection_compression"
    value = "disabled" # 기본값
  }
  parameter {
    name  = "profiler"
    value = "enabled"
  }
  parameter {
    name  = "profiler_sampling_rate"
    value = "1.0"
  }
  parameter {
    name  = "profiler_threshold_ms"
    value = "100" # 100ms보다 긴 쿼리를 로깅 (기본값)
  }
  parameter {
    name  = "ttl_monitor"
    value = "disabled" # 예시: TTL 모니터 활성화
  }
}

# main.tf 또는 docdb.tf
resource "aws_docdb_cluster" "existing_cluster" {
  cluster_identifier = "groom-documentdb"
  engine = "docdb"
  engine_version = "5.0.0"
  backup_retention_period = 7
  availability_zones = [
    "ap-northeast-2a",
    "ap-northeast-2c"
  ]

  db_subnet_group_name = aws_db_subnet_group.docdb_subnet_group.name

  vpc_security_group_ids  = [data.aws_security_group.document-db-sg.id]

  master_username = var.document-db-username
  master_password = var.document-db-pwd

  port = 27017
  enabled_cloudwatch_logs_exports = []
  skip_final_snapshot = true
  preferred_backup_window = "00:00-00:30"
  preferred_maintenance_window = "mon:15:08-mon:15:38"
  deletion_protection = false
  storage_encrypted = false
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.custom_docdb_group.name
  tags = {
    Name = var.document-db-name
  }

  depends_on = [aws_docdb_cluster_parameter_group.custom_docdb_group]
}

resource "aws_docdb_cluster_instance" "primary_instance" {
  identifier = "groom-documentdb"
  cluster_identifier = aws_docdb_cluster.existing_cluster.id
  instance_class = "db.t3.medium"
  availability_zone = "ap-northeast-2a"
  auto_minor_version_upgrade = true
  preferred_maintenance_window = "fri:14:32-fri:15:02"
  promotion_tier = 0

  copy_tags_to_snapshot = false
  tags = {}//일단 비워둠

  depends_on = [aws_docdb_cluster.existing_cluster]
}






