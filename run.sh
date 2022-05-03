#!/usr/bin/env bash
set -ex

SQS_QUEUE_URL=$1

echo "Installing amazon-cloudwatch-agent to capture memory metrics"
sudo yum install amazon-cloudwatch-agent -y
sudo amazon-linux-extras install collectd -y
sudo tee -a /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "root"
	},
	"metrics": {
		"aggregation_dimensions": [
			[
				"InstanceId"
			]
		],
		"metrics_collected": {
			"collectd": {
				"metrics_aggregation_interval": 60
			},
			"disk": {
				"measurement": [
					"used_percent"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			},
			"statsd": {
				"metrics_aggregation_interval": 60,
				"metrics_collection_interval": 10,
				"service_address": ":8125"
			}
		}
	}
}
EOF

sudo systemctl restart amazon-cloudwatch-agent

echo "Installing Java 17"
wget https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz
tar xvf openjdk-17_linux-x64_bin.tar.gz
rm -rf /opt/jdk-17
sudo mv jdk-17 /opt/
sudo tee /etc/profile.d/jdk.sh <<EOF
export JAVA_HOME=/opt/jdk-17
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile.d/jdk.sh

echo "Running program"

SQS_QUEUE_URL="$SQS_QUEUE_URL" java \
  -Dfile.encoding=UTF-8 \
  -Duser.country=US \
  -Duser.language=en \
  -Duser.variant \
  -Xms600m \
  -Xmx600m \
  -jar app/build/libs/app.jar
