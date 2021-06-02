# dq-tf-tableau-backup-monitor.


These Lambdas watches the S3 Bucket which lands backups for Internal and External Tableau It checks to see that files are regularly being received.

Tasks include:
- Checking S3 at selected intervals
- Checking if a file has arrived within a the specified period
- If a file has a arrived within specified period, it notes the last file received
- If a file has a NOT arrived within specified period, A Slack alert is generated
