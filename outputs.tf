# # Display ELB IP address

output "co-elb" {
  value = module.webinfra.co-elb
}

output "asg_name" {
  value = module.webinfra.co_asg
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
