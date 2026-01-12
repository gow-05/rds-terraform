output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}
output "ec2_public_ip" {
  value = aws_instance.rails_ec2.public_ip
}
