provider "aws" {
  region     = "us-west-1"
  access_key = "your access key"
  secret_key = "your access secret "
  version = "2.13"
  skip_requesting_account_id = true
  skip_credentials_validation = true
}
