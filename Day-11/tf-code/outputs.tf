output "instance_public_ip" {
description = "Public IP of the EC2 instance"
value       = aws_instance.demo_instance.public_ip
}

output "instance_id" {
description = "ID of the EC2 instance"
value       = aws_instance.demo_instance.id
}

output "s3_bucket_name" {
description = "Name of the S3 bucket"
value       = aws_s3_bucket.demo_bucket.bucket
}

output "application_url" {
description = "URL to access the application"
value       = "http://${aws_instance.demo_instance.public_ip}"
}

output "ssh_command" {
description = "SSH command to connect to instance"
value       = "ssh -i ${aws_key_pair.demo_key.key_name}.pem ec2-user@${aws_instance.demo_instance.public_ip}"
}