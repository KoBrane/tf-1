resource "aws_ec2_transit_gateway" "example" {
  description = "tg-web-backend-database"
  tags = {
    Name = "Web-Backend-Database Transit Gateway"
  }
}