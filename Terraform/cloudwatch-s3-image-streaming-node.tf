# resource "aws_cloudwatch_log_group" "s3_msk_node_lambda_group" {
#   name              = "/aws/lambda/${aws_lambda_function.s3_image_publisher_node.function_name}"
#   retention_in_days = 3

#   # Allow group deletion during terraform destroy
#   lifecycle {
#     prevent_destroy = false
#   }

#   tags = {
#     Name    = "AWS MSK Node Lambda Streaming S3 MSK Log Group"
#     project = var.project
#     owner   = var.owner
#   }
# }