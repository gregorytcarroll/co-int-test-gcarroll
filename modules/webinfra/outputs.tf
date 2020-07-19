 # Display ELB IP address

 output "co-elb" {
   value = "${aws_elb.co_elb.dns_name}"
 }

 output "co_asg" {
  value = "${aws_autoscaling_group.co_asg.name}"
}