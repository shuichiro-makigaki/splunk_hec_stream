import unittest
from io import StringIO
import logging
import gzip
import base64
import json

from splunk_hec_stream.firehose_processor import lambda_handler
from splunk_hec_stream.logging import SplunkHECStreamHandler


class TestFirehoseProcessor(unittest.TestCase):
    def setUp(self) -> None:
        self.stream = StringIO()
        self.logger = logging.getLogger('test')
        self.logger.setLevel(logging.INFO)
        self.logger.handlers = []
        self.logger.addHandler(SplunkHECStreamHandler(stream=self.stream))
        self.logger.info({"key": "value"})
        message = self.stream.getvalue()
        data = json.dumps({'logEvents': [{'message': message}]}).encode()
        self.event = {
            'records': [
                {
                    'data': base64.b64encode(gzip.compress(data)),
                    'recordId': 'record_id'
                }
            ]
        }

    def test_processor1(self):
        d = lambda_handler(self.event, None)
        self.assertIn('records', d)
        self.assertIn('recordId', d['records'][0])
        self.assertIn('data', d['records'][0])
        data = json.loads(base64.b64decode(d['records'][0]['data']).decode())
        self.assertEqual(data["index"], "main")
        self.assertNotIn("loggingHandler", data)
        self.assertEqual(data["sourcetype"], "_json")
        self.assertIn("source", data)
        self.assertIn("time", data)
        self.assertIn("host", data)
        self.assertDictEqual(data["event"], {"key": "value"})

