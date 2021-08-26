FROM python:3.6.13-stretch
WORKDIR /usr/src/nubank_sync_ynab
COPY . .
RUN pip install --no-cache-dir -r requirements.txt --use-deprecated=legacy-resolver
ENTRYPOINT python nubank_sync_ynab/sync.py