from splunk_hec_stream.firehose_processor import lambda_handler as lh


def lambda_handler(event, context):
    return lh(event, context)
