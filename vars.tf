variable access_key {}
variable secret_key {}
variable region {}
variable key_name {}
variable s3_bucket {}
variable iam_instance_profile {}


variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 80
}

variable "ssh_port" {
  default = 22
}

variable "instance_count" {
  description = "Number of EC2 instances"
# Insert desired number of instances
  default = 1
}

variable "my_ip" {
  description = "IP for locking down SSH Access"
# Insert your IP for SSH Access
  default = "82.38.111.189/32"
}


variable "db_name" {
  description = "The port the server will use for HTTP requests"
# Replace with desired DB Name
  default = "terraform-state-locks"
}

variable "s3_name" {
# Replace with desired S3 Name
  default = "terraform-state-storage-cotest"
}


