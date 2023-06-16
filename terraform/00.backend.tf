terraform {

  backend "s3" {
    bucket  = "openmed-desa-iac-bucket"
    encrypt = true
    key     = "desa-iac.tfstate"
    region  = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
