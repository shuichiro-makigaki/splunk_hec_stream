from pathlib import Path
from setuptools import setup


setup(
    name='splunk_hec_stream',
    version='0.2',
    packages=['splunk_hec_stream'],
    url='https://github.com/shuichiro-makigaki/splunk_hec_stream',
    license='MIT License',
    author='Shuichiro MAKIGAKI',
    author_email='shuichiro.makigaki@gmail.com',
    description='Splunk HEC Stream',
    long_description=Path("README.md").read_text(),
    long_description_content_type="text/markdown"
)
