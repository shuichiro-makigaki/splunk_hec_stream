import json
import logging
from pathlib import Path
import os


class SplunkHECStreamHandler(logging.StreamHandler):
    class TimeKeyFilter(logging.Filter):
        def filter(self, record):
            if hasattr(record, '_time'):
                record.created = record._time
            return True

    class JSONFilter(logging.Filter):
        def filter(self, record):
            if type(record.msg) is str:
                record.msg = {'message': record.msg}
            try:
                record.msg = json.dumps(record.msg, ensure_ascii=False)
            except:
                record.msg = json.dumps(str(record.msg), ensure_ascii=False)
            return True

    def __init__(self, index="main", source=None, host=None, sourcetype="_json", stream=None):
        super().__init__(stream=stream)
        if source is None:
            source = Path(__file__).absolute()
        if host is None:
            host = os.uname()[1]
        self.name = self.__class__.__name__
        fmt = f'''{{
            "loggingHandler": "{self.name}",
            "time": %(created)f,
            "host": "{host}",
            "index": "{index}",
            "source": "{source}",
            "sourcetype": "{sourcetype}",
            "event": %(message)s
        }}'''.replace('\n', '').replace(' ', '')
        self.setFormatter(logging.Formatter(fmt))
        self.addFilter(self.JSONFilter())
        self.addFilter(self.TimeKeyFilter())
