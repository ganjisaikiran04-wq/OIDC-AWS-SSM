terraform {
  backend "s3" {
    bucket         = "bucketforpractice4477"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
  }
}
