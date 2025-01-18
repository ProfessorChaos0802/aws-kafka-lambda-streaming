resource "aws_msk_cluster" "msk_lambda_streaming_cluster" {
  cluster_name           = "msk_lambda_streaming_cluster"
  number_of_broker_nodes = 3
  kafka_version          = "3.2.0"
  enhanced_monitoring    = "DEFAULT"

  broker_node_group_info {
    instance_type = "kafka.t3.small"
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

  tags = {
    project = var.project
    owner   = var.owner
  }
}