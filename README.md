# Splunk HEC Stream

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