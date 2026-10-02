variable "name" { type = string }
variable "alert_email" { type = string }
variable "asg_name" { type = string }
variable "alb_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }
variable "cpu_threshold" {
  type    = number
  default = 80
}
