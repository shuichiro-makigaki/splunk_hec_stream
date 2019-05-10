# Splunk HEC Stream

This is a streaming logging handler for Splunk HEC and is NOT an event sender of Splunk HEC endpoint.

Streaming logging handler is useful for some usecases:

* Use with AWS Lambda
    * Send events to Splunk HEC endpoint via AWS Kinesis Firehose and CloudWarch Logs subscription filter
* Use with log colllector such as Fluentd and Logstash
    * Read events from log files and process them by log collector

## Example

```python
import logging
import json
from datetime import datetime

from splunk_hec_stream.logging import SplunkHECStreamHandler


logging.basicConfig(
    level=logging.INFO,
    handlers=[SplunkHECStreamHandler("main", "splunk-logger-test", "aws:lambda", "_json")]
)

logging.info({"key1": "value1"})
logging.info("test")
logging.info('''test
ln''')
logging.info(json.dumps({"key1": "value1"}))
# You can overwrite logging time by _time extra key (must be float)
logging.info({"key": "value"}, extra={'_time': datetime.utcnow().timestamp()})
```

This code shows following logs to stdout:

```json
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.617483,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"key1": "value1"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.617758,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"message": "test"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.617904,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"message": "test\nln"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.618075,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"message": "{\"key1\": \"value1\"}"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557269430.618213,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"key": "value"}}
```

Splunk HEC endpoint can read them as events.

## Use with AWS Lamnda

### 1. Configure AWS Kinesis Firehose to send events to Splunk HEC endpoint

`splunk_hec_stream/firehose_processor.py` can be used for stream processor lambda.

### 2. Configure CloudWatch Logs subscription filter, and send the evnets to the AWS Kinesis Firehose stream

`splunk_hec_stream` adds `loggingHandler` key to events, and the key is used for filtering only Splunk HEC events.
