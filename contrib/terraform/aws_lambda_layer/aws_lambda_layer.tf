variable "lib_path" {}

variable "layer_name" {
  default = "splunk_hec_stream"
}

locals {
  layer_files = ["__init__.py", "firehose_processor.py", "logging.py"]
}

resource "local_file" "layer_files" {
  count    = length(local.layer_files)
  content  = file("${var.lib_path}/${local.layer_files[count.index]}")
  filename = "splunk_hec_stream_lambda_layer/python/splunk_hec_stream/${local.layer_files[count.index]}"
}

data "archive_file" "layer_files" {
  depends_on  = [local_file.layer_files]
  type        = "zip"
  source_dir  = "splunk_hec_stream_lambda_layer"
  output_path = "splunk_hec_stream_lambda_layer.zip"
}

resource "aws_lambda_layer_version" "layer" {
  filename            = data.archive_file.layer_files.output_path
  layer_name          = var.layer_name
  compatible_runtimes = ["python3.6", "python3.7"]
  description         = "Splunk HEC Stream Handler"
  source_code_hash    = data.archive_file.layer_files.output_base64sha256
}

output "arn" {
  value = aws_lambda_layer_version.layer.arn
}