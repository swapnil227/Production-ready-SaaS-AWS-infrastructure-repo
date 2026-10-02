variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "project" {
  type    = string
  default = "saas"
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "single_nat_gateway" {
  description = "true = 1 NAT (cheaper). false = 1 NAT per AZ (AZ-resilient egress)."
  type        = bool
  default     = true
}
variable "instance_type" {
  description = "Graviton (arm64) type. Must be an arm64 family (t4g/m7g/c7g...)."
  type        = string
  default     = "t4g.micro"
}
variable "asg_min" {
  type    = number
  default = 2
}
variable "asg_desired" {
  type    = number
  default = 2
}
variable "asg_max" {
  type    = number
  default = 6
}
variable "certificate_arn" {
  description = "Existing ACM cert ARN. Leave empty to generate a self-signed cert (demo only)."
  type        = string
  default     = ""
}
variable "alert_email" {
  description = "Email for CloudWatch alarms and budget alerts."
  type        = string
}
variable "monthly_budget_usd" {
  type    = number
  default = 100
}
