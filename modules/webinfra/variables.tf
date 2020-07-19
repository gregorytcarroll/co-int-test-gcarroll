variable iam_instance_profile {}
variable key_name {}
variable s3_bucket {}


variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 80
}

variable "ssh_port" {
  default = 22
}

variable "my_ip" {
  description = "IP for locking down SSH Access"
  default = "82.38.111.189/32"
}




