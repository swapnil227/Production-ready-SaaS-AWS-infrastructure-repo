#!/bin/bash
set -euxo pipefail
dnf install -y nginx amazon-cloudwatch-agent

# IMDSv2 token -> show which instance served the request (proves load balancing)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
IID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /usr/share/nginx/html/index.html <<HTML
<h1>SaaS sample app</h1><p>Served by <b>$IID</b> in <b>$AZ</b></p>
HTML

# Health endpoint used by ALB target group
cat > /etc/nginx/default.d/health.conf <<'NGX'
location = /health { access_log off; default_type text/plain; return 200 "ok"; }
NGX

systemctl enable --now nginx

# CloudWatch agent: nginx logs + memory/disk metrics
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CW'
{
  "agent": { "metrics_collection_interval": 60 },
  "metrics": {
    "append_dimensions": { "AutoScalingGroupName": "$${aws:AutoScalingGroupName}" },
    "metrics_collected": {
      "mem":  { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["used_percent"], "resources": ["/"] }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          { "file_path": "/var/log/nginx/access.log", "log_group_name": "${log_group}", "log_stream_name": "{instance_id}/access" },
          { "file_path": "/var/log/nginx/error.log",  "log_group_name": "${log_group}", "log_stream_name": "{instance_id}/error" }
        ]
      }
    }
  }
}
CW
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
