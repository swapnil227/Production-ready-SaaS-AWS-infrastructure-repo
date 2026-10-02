variable "name" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "app_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "instance_type" { type = string }
variable "min_size" { type = number }
variable "desired_size" { type = number }
variable "max_size" { type = number }
variable "log_retention_days" {
  type    = number
  default = 30
}
