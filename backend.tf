terraform {
  backend "s3" {
    bucket = "techcorp-state"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}