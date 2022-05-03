#!/usr/bin/env bash
set -ex

S3_BUCKET_NAME=$1

./gradlew build
zip -r sdk-leak-artifacts.zip .

aws s3 cp sdk-leak-artifacts.zip s3://"$S3_BUCKET_NAME"/sdk-leak-artifacts.zip
