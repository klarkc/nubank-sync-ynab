FROM python:3.6.13-stretch
WORKDIR /usr/src/nubank_sync_ynab
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt --use-deprecated=legacy-resolver
# RUN pip install setuptools
COPY . .
RUN pip install .
COPY nubank_sync_ynab/logging.json /usr/local/lib/python3.6/site-packages/nubank_sync_ynab/
ENTRYPOINT python /usr/local/lib/python3.6/site-packages/nubank_sync_ynab/sync.py