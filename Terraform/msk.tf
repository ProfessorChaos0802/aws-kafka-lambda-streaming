resource "aws_msk_cluster" "msk_lambda_streaming_cluster" {
  cluster_name           = "mskLambdaStreamingCluster"
  number_of_broker_nodes = 3
  kafka_version          = "3.2.0"
  enhanced_monitoring    = "DEFAULT"

  broker_node_group_info {
    instance_type = "kafka.t3.small"

    storage_info {
      ebs_storage_info {
        volume_size = 10

        provisioned_throughput {
          enabled           = true
          volume_throughput = 250
        }
      }
    }

    client_subnets = [
      aws_subnet.aws_msk_streaming_east2a.id,
      aws_subnet.aws_msk_streaming_east2b.id,
      aws_subnet.aws_msk_streaming_east2c.id
    ]

    security_groups = [
      aws_security_group.msk_sg.id
    ]
  }

  client_authentication {
    sasl {
      iam = true
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = "true"
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_cloudwatch_group.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.msk_logs_bucket.id
        prefix  = "logs/msk-"
      }
    }
  }

  tags = {
    project = var.project
    owner   = var.owner
  }
}