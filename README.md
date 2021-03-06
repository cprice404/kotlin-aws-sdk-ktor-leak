# README

## Reproduction steps
1. Create an S3 bucket to store the zip file generated by the `upload-artifacts.sh` script (or use one you already have)
2. Create an SQS queue and note the queue URL.
3. On your system, run `./upload-artifacts.sh <name-of-s3-bucket`. This presumes you have AWS credentials set up in your current shell
4. Launch an EC2 instance in your AWS account with appropriate permissions attached (easiest is Admin)
5. SSH/Use SSM to access your EC2 instance.
6. Run the following commands in a `screen` or `tmux` session:
```shell
aws s3 cp s3://<YOUR_S3_BUCKET_NAME>/sdk-leak-artifacts.zip sdk-leak-artifacts.zip
unzip sdk-leak-artifacts.zip -d sdk-leak-artifacts
cd sdk-leak-artifacts
./run.sh <SOME_SQS_QUEUE_URL_IN_YOUR_ACCOUNT>
```
7. To see memory used, go to CloudWatch ->  All Metrics -> CWAgent -> host and select the `host` with the IP of your recently launched EC2 instance. From there you can track the memory usage over time
