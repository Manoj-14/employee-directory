terraform {

  backend "s3" {
    key          = "terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = "true"
    encrypt      = true
  }
}