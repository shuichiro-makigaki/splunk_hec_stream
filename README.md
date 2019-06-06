# Splunk HEC Stream

Python streaming logging handler for Splunk HEC

---

This handler is NOT an event sender.
The handler itself does not involve forwarding to Splunk HEC endpoint.

This means that log sources don't have to be concerned about buffering, transforming and retrying.
These functions are responsible for log forwarding services (such as AWS Kinesis Firehose, Fluentd, Logstash, etc.).

## Use case

* Forward logs from AWS Lambda functions to Splunk 
    * Send events to Splunk HEC endpoint via AWS Kinesis Firehose and CloudWarch Logs
* Use with log collector such as Fluentd and Logstash
    * Read events from log files and process them by log collector

## How to install

```
pip3 install splunk-hec-stream
```

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
# You can overwrite logged time by _time extra key (that must be float)
logging.info({"key": "value"}, extra={'_time': datetime.utcnow().timestamp()})
```

This example codes put following logs to stdout:

```json
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.617483,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"key1": "value1"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.617758,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"message": "test"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.617904,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"message": "test\nln"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557301830.618075,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"message": "{\"key1\": \"value1\"}"}}
{"loggingHandler":"SplunkHECStreamHandler","time":1557269430.618213,"host":"aws:lambda","index":"main","source":"splunk-logger-test","sourcetype":"_json","event":{"key": "value"}}
```

By forwarding these JSON lines to Splunk HEC endpoint, Splunk can read and store them as events.

## Use with AWS Lambda

This package is useful to forward logs of AWS Lambda to Splunk.

1. Lambda functions put logs to CloudWatch,
1. Subscription Filter forwards them to Firehose,
1. and the Firehose forwards them to Splunk.

### 1. Configure AWS Kinesis Firehose to send events to Splunk HEC endpoint

`splunk_hec_stream/firehose_processor.py` can be used for event processor lambda.

### 2. Configure CloudWatch Logs subscription filter, and send the filtered events to the Firehose stream

`loggingHandler` key is used to filter logs that forward to Splunk HEC endpoint.
