# dq-tf-tableau-backup-monitor


These Lambdas watch the S3 Bucket which holds the backups for Internal and External Tableau.
It checks to see that the backup files are regularly appearing.

Tasks include:
- Checking S3 at selected intervals
- Checking if a file has arrived within a specified period
- If a file has arrived within specified period, it notes the last file received
- If a file has NOT arrived within specified period, a Slack alert is generated
