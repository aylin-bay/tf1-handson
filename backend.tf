terraform {
  backend "s3" {
    bucket = "aylinsbucket"
    key    = "dev-env-state"
    region = "us-east-1"

  }
}