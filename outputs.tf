# Display ELB IP address

output "elb_dns_name" {
  value = "${aws_elb.co-elb.dns_name}"
}
