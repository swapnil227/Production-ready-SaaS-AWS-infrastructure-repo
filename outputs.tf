output "alb_dns_name" {
  description = "Open https://<this> (self-signed cert warning expected unless you supply certificate_arn)."
  value       = module.alb.alb_dns_name
}
output "vpc_id" { value = module.network.vpc_id }
output "asg_name" { value = module.compute.asg_name }
output "alarm_topic_arn" { value = module.observability.sns_topic_arn }
