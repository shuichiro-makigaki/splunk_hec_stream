variable "lib_path" {}

variable "hec_endpoint" {}

variable "hec_token" {}

variable "layer_arn" {}

variable "s3_delivery_bucket_name" {}

variable "iam_role_name" {
  default = "splunk_hec_stream"
}

variable "log_group_name" {
  default = "/aws/kinesisfirehose/splunk_hec_stream"
}

variable "s3_delivery_log_stream_name" {
  default = "S3Delivery"
}

variable "splunk_delivery_log_stream_name" {
  default = "SplunkDelivery"
}

variable "log_retention_in_days" {
  default = 7
}

variable "function_name" {
  default = "splunk_hec_stream_processor"
}

variable "function_timeout" {
  default = 60
}

variable "hec_acknowledgment_timeout" {
  default = 180
}

variable "retry_duration" {
  default = 0
}

variable "number_of_retries" {
  default = 0
}

variable "buffer_size_in_mbs" {
  default = 1
}

variable "buffer_interval_in_seconds" {
  default = 60
}

variable "stream_name" {
  default = "splunk_hec_stream"
}

data "aws_region" "current" {}

resource "aws_s3_bucket" "firehose_processor" {
  bucket = var.s3_delivery_bucket_name
}

resource "aws_iam_role" "firehose_processor" {
  name               = var.iam_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "firehose_processor" {
  name = var.log_group_name
  retention_in_days = var.log_retention_in_days
}

data "archive_file" "firehose_processor" {
  type = "zip"
  source_file = "${var.lib_path}/contrib/aws_firehose_splunk_hec_stream_processor.py"
  output_path = "aws_firehose_splunk_hec_stream_processor.zip"
}

resource "aws_lambda_function" "firehose_processor" {
  filename = data.archive_file.firehose_processor.output_path
  function_name = var.function_name
  handler = "aws_firehose_splunk_hec_stream_processor.lambda_handler"
  source_code_hash = data.archive_file.firehose_processor.output_base64sha256
  runtime = "python3.7"
  role = aws_iam_role.firehose_processor.arn
  timeout = var.function_timeout
  layers = [var.layer_arn]
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_processor" {
  name = var.stream_name
  destination = "splunk"

  s3_configuration {
    role_arn = aws_iam_role.firehose_processor.arn
    bucket_arn = aws_s3_bucket.firehose_processor.arn
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.firehose_processor.name
      log_stream_name = var.s3_delivery_log_stream_name
    }
  }

  splunk_configuration {
    hec_endpoint = var.hec_endpoint
    hec_token = var.hec_token
    hec_acknowledgment_timeout = var.hec_acknowledgment_timeout
    retry_duration = var.retry_duration
    hec_endpoint_type = "Event"

    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"

        parameters {
          parameter_name = "LambdaArn"
          parameter_value = "${aws_lambda_function.firehose_processor.arn}:$LATEST"
        }
        parameters {
          parameter_name = "NumberOfRetries"
          parameter_value = var.number_of_retries
        }
        parameters {
          parameter_name = "RoleArn"
          parameter_value = aws_iam_role.firehose_processor.arn
        }
        parameters {
          parameter_name = "BufferSizeInMBs"
          parameter_value = var.buffer_size_in_mbs
        }
        parameters {
          parameter_name = "BufferIntervalInSeconds"
          parameter_value = var.buffer_interval_in_seconds
        }
      }
    }

    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.firehose_processor.name
      log_stream_name = var.splunk_delivery_log_stream_name
    }
  }
}
