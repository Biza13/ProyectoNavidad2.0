terraform {
  backend "s3" {
    bucket         = "cubo-s3-begona"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
  }
}