
resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = var.msk-cluster-name
  enhanced_monitoring    = "DEFAULT"
  kafka_version          = "3.8.x"
  number_of_broker_nodes = 2
  storage_mode           = "LOCAL"
  tags                   = {}

  broker_node_group_info {
    az_distribution = "DEFAULT"
    client_subnets  = [
      var.private-subnet1-id,
      var.private-subnet2-id
    ]
    instance_type   = "kafka.t3.small"
    security_groups = [
      var.msk-sg-id
    ]

    connectivity_info {
      public_access {
        type = "DISABLED"
      }
      vpc_connectivity {
        client_authentication {
          sasl {
            iam   = false
            scram = false
          }
          tls = false
        }
      }
    }

    storage_info {
      ebs_storage_info {
        volume_size = 20
        provisioned_throughput {
          enabled = false
        }
      }
    }
  }

  client_authentication {
    unauthenticated = true
    sasl {
      iam   = false
      scram = false
    }
    tls {}
  }

  configuration_info {
    arn      = "arn:aws:kafka:ap-northeast-2:490913547024:configuration/defalut-set/fd4b626c-8159-488f-8723-bee061af3d8b-3"
    revision = 2
  }

  encryption_info {
   // encryption_at_rest_kms_key_arn = "arn:aws:kms:ap-northeast-2:490913547024:key/7977fee7-0bb8-4f77-8d85-264151e6f913"
    //kms 기본키 생략
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = "msk-log"
      }
      firehose {
        enabled = false
      }
      s3 {
        enabled = false
      }
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
}
