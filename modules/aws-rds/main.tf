# 8 Creating DB subnet group for RDS Instances
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.postgre-db-subnet-group-name
  subnet_ids = [var.private-subnet3-id, var.private-subnet4-id]
}



# 2. 스냅샷으로부터 다중 영역(Multi-AZ) RDS 인스턴스 생성
resource "aws_db_instance" "postgre_db_instance" {
  snapshot_identifier  = var.postgre-db-snapshot-identifier
  identifier           = "my-restored-db-instance"
  instance_class       = "db.t3.micro"
  multi_az             = true
  port                 = 5432
  # 네트워킹 설정
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [var.postgre-db-sg-id]


  # 스냅샷이 이미 암호화된 경우 해당 설정을 상속받습니다.
  # 만약 스냅샷이 암호화되지 않았을 때 새로 암호화하려면 아래 두 줄을 활성화합니다.
   storage_encrypted = true
  # kms_key_id        = "alias/aws/rds" # AWS 관리형 기본 키

  # DB 인증 옵션: 암호 인증
  # 스냅샷에서 복원할 때는 사용자 이름과 암호가 스냅샷에 저장된 값을 상속받으므로
  # master_username, master_password를 지정하지 않습니다.

  # 기타 설정
  skip_final_snapshot  = true
  publicly_accessible  = false # 보안을 위해 false 권장


  tags = {
    Name = var.postgre-db-name
  }
}

















#
# # Creating Aurora RDS Cluster, username and password used only for practice, otherwise follow DevOps best practices to keep it secret
# resource "aws_rds_cluster" "aurora_cluster" {
#   cluster_identifier      = "aurora-cluster"
#   engine                  = "aurora-mysql"
#   engine_version          = "5.7.mysql_aurora.2.11.4"
#   master_username         = var.rds-username
#   master_password         = var.rds-pwd
#   backup_retention_period = 7
#   preferred_backup_window = "07:00-09:00"
#   skip_final_snapshot     = true
#   database_name           = var.db-name
#   port                    = 3306
#   db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
#   vpc_security_group_ids  = [data.aws_security_group.db-sg.id]
#   tags = {
#     Name = var.rds-name
#   }
# }
#
#
#
# # Creating RDS Cluster instance
# resource "aws_rds_cluster_instance" "primary_instance" {
#   cluster_identifier = aws_rds_cluster.aurora_cluster.id
#   identifier         = "primary-instance"
#   instance_class     = "db.t3.small"
#   engine             = aws_rds_cluster.aurora_cluster.engine
#   engine_version     = aws_rds_cluster.aurora_cluster.engine_version
# }
#
# # Creating RDS Read Replica Instance
# resource "aws_rds_cluster_instance" "read_replica_instance" {
#   count              = 1
#   cluster_identifier = aws_rds_cluster.aurora_cluster.id
#   identifier         = "read-replica-instance-${count.index}"
#   instance_class     = "db.t3.small"
#   engine             = aws_rds_cluster.aurora_cluster.engine
#
#
#   depends_on = [aws_rds_cluster_instance.primary_instance]
# }
# output "rds_dns" {
#   value = aws_rds_cluster.aurora_cluster.endpoint
# }
# output "rds_write_dns" {
#   value = aws_rds_cluster_instance.primary_instance.endpoint
# }
#
