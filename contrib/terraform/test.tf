provider "aws" {
  region = "ap-northeast-1"
}

variable "python_lib_path" {
  default = "/usr/local/lib/python3.7/site-packages"
}

module "handler_layer" {
  source     = "./aws_lambda_layer"
  layer_name = "splunk_hec_stream_handler"
  lib_path   = "${var.python_lib_path}/splunk_hec_stream"
}

module "firehose_processor" {
  source                  = "./aws_firehose"
  lib_path                = "${var.python_lib_path}/splunk_hec_stream"
  hec_endpoint            = "https://example.com"
  hec_token               = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  layer_arn               = module.handler_layer.arn
  s3_delivery_bucket_name = "XXXXXXXX"
}
