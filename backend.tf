# Partial S3 backend: bucket/key/region are injected with -backend-config (see README + CI).
terraform {
  backend "s3" {
    encrypt = true
  }
}
