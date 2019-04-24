import logging
import json
from io import StringIO
import unittest


from splunk_hec_stream.logging import SplunkHECStreamHandler


class TestHandler1(unittest.TestCase):
    def setUp(self) -> None:
        self.stream = StringIO()
        self.logger = logging.getLogger('test')
        self.logger.setLevel(logging.INFO)
        self.logger.handlers = []
        self.logger.addHandler(SplunkHECStreamHandler(stream=self.stream))

    def test_handler1(self):
        self.logger.info({"key1": "value1"})
        j = json.loads(self.stream.getvalue())
        self.assertEqual(j["index"], "main")
        self.assertIn("source", j)
        self.assertIn("time", j)
        self.assertIn("host", j)
        self.assertEqual(j["loggingHandler"], "SplunkHECStreamHandler")
        self.assertEqual(j["sourcetype"], "_json")
        self.assertDictEqual(j["event"], {"key1": "value1"})

    def test_handler2(self):
        self.logger.info("test")
        j = json.loads(self.stream.getvalue())
        self.assertDictEqual(j["event"], {"message": "test"})

    def test_handler3(self):
        self.logger.info('''test
ln''')
        j = json.loads(self.stream.getvalue())
        self.assertDictEqual(j["event"], {"message": "test\nln"})

    def test_handler4(self):
        self.logger.info(json.dumps({"key": "value"}))
        j = json.loads(self.stream.getvalue())
        self.assertDictEqual(j["event"], {"message": "{\"key\": \"value\"}"})

    def test_handler5(self):
        self.logger.info({"key": "value"}, extra={'_time': 1555548439.791797})
        j = json.loads(self.stream.getvalue())
        self.assertEqual(j["time"], 1555548439.791797)
        self.assertDictEqual(j["event"], {"key": "value"})

    def test_handler6(self):
        self.logger.info("寿限無、寿限無")
        j = json.loads(self.stream.getvalue())
        self.assertDictEqual(j["event"], {"message": "寿限無、寿限無"})


class TestHandler2(unittest.TestCase):
    def setUp(self) -> None:
        self.stream = StringIO()
        self.logger = logging.getLogger('test')
        self.logger.setLevel(logging.INFO)
        self.logger.handlers = []
        self.logger.addHandler(
            SplunkHECStreamHandler("sandbox", "splunk-logger-test", "aws:lambda", "_json", self.stream))

    def test_handler1(self):
        self.logger.info({"key1": "value1"})
        j = json.loads(self.stream.getvalue())
        self.assertEqual(j["index"], "sandbox")
        self.assertEqual(j["source"], "splunk-logger-test")
        self.assertEqual(j["host"], "aws:lambda")
        self.assertEqual(j["loggingHandler"], "SplunkHECStreamHandler")
        self.assertEqual(j["sourcetype"], "_json")
        self.assertDictEqual(j["event"], {"key1": "value1"})
