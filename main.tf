#----------------------------------------#
#          Checkout Demo                 #
#                                        #
# Deploys Two servers to AWs behind LB   #
#                                        #
#         Naming Convention              # 
#           co = Checkout                #
#----------------------------------------#

# Configure AWS connection - details in 
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

terraform {
  backend "s3" {
    # Replace this with your bucket name
    bucket         = "terraform-state-storage-cotest"
    key            = "terraform/terraform.tfstate"
    region         = "eu-west-2"
    # Replace this with your DynamoDB table name 
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-storage-cotest"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.db_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Get the availability zones for the region specified in region variable
data "aws_availability_zones" "all" {}

module "webinfra" {
  source  = "../modules/webinfra/"
  key_name = var.key_name
  iam_instance_profile = var.iam_instance_profile
  s3_bucket = var.s3_bucket

}





