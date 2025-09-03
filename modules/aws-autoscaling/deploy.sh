#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum -y install nginx
sudo yum install java-17-amazon-corretto -y
cd /etc/nginx
# cd /usr/share/nginx/htmlcd 
# sudo wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
# sudo yum install unzip
# sudo unzip 2135_mini_finance.zip
# sudo rm -rf 2135_mini_finance.zip index.nginx-debian.html
# cd 2135_mini_finance/
# sudo mv * ../
# sudo rm -rf 2135_mini_finance/


echo ${web_dns}
echo "${web_dns}"
echo ${was_dns}


cd /etc/nginx/conf.d
suod vi default.conf
cat <<EOF | sudo tee /etc/nginx/conf.d/default.conf > /dev/null
server {
    listen 80;
    server_name ${web_dns};
    location / {
        proxy_pass http://${was_dns}:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
sudo sed -i '/http {/a \    server_names_hash_bucket_size 128;' /etc/nginx/nginx.conf


#cloud watch 작업 
sudo yum install -y amazon-cloudwatch-agent -y

# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

sudo yum install -y collectd

sudo cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json> /dev/null
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_class": "STANDARD",
                        "log_group_name": "nginx-access",
                        "log_stream_name": "{instance_id}",
                        "retention_in_days": 5
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_class": "STANDARD",
                        "log_group_name": "nginx-error",
                        "log_stream_name": "{instance_id}",
                        "retention_in_days": 5
                    }
                ]
            }
        }
    },
    "metrics": {
        "aggregation_dimensions": [
            [
                "InstanceId"
            ]
        ],
        "metrics_collected": {
            "collectd": {
                "metrics_aggregation_interval": 30
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
                "metrics_aggregation_interval": 30,
                "metrics_collection_interval": 60,
                "service_address": ":8125"
            }
        }
    }
}
EOF
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
-s


sudo systemctl enable nginx
sudo systemctl restart nginx
sudo yum install mysql-server -y
sudo yum info amazon-ssm-agent
sudo yum install -y stress