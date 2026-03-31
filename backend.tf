terraform {
  backend "s3" {
    bucket = "techcorp-state-bkt"
    key    = "terraform/backend/terraform.tfstate"
    region = "us-east-1"
  }
}

