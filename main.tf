data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "network" {
  source             = "./modules/network"
  name               = local.name
  vpc_cidr           = var.vpc_cidr
  azs                = local.azs
  single_nat_gateway = var.single_nat_gateway
}

module "security" {
  source = "./modules/security"
  name   = local.name
  vpc_id = module.network.vpc_id
}

module "alb" {
  source            = "./modules/alb"
  name              = local.name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  certificate_arn   = var.certificate_arn
}

module "compute" {
  source             = "./modules/compute"
  name               = local.name
  private_subnet_ids = module.network.private_subnet_ids
  app_sg_id          = module.security.app_sg_id
  target_group_arn   = module.alb.target_group_arn
  instance_type      = var.instance_type
  min_size           = var.asg_min
  desired_size       = var.asg_desired
  max_size           = var.asg_max
}

module "observability" {
  source                  = "./modules/observability"
  name                    = local.name
  alert_email             = var.alert_email
  asg_name                = module.compute.asg_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
}

module "budget" {
  source      = "./modules/budget"
  name        = local.name
  limit_usd   = var.monthly_budget_usd
  alert_email = var.alert_email
}
