bakcend-services-vpc.tf
resource "aws_vpc" "BACKEND_SERVICES_VPC" {
  cidr_block       = "11.0.0.0/16"
  

  tags = {
    Name = "BACKEND_SERVICES_VPC"
  }
}

resource "aws_subnet" "BACKEND_SERVICES_SUBNET" {
  vpc_id     = aws_vpc.BACKEND_SERVICES_VPC.id
  cidr_block = "11.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "BACKEND_SERVICES_SUBNET"
  }
}

resource "aws_internet_gateway" "BACKEND_SERVICES_IGW" {
  vpc_id     = aws_vpc.BACKEND_SERVICES_VPC.id

  tags = {
    Name = "BACKEND_SERVICES_IGW"
  }
}

# Create a default route table for backend services VPC
resource "aws_default_route_table" "BACKEND_SERVICES_ROUTE" {
  default_route_table_id = aws_vpc.BACKEND_SERVICES_VPC.default_route_table_id

  tags = {
    Name = "BACKEND_SERVICES_ROUTE"
  }
}

# Create a default route for backend services VPC
resource "aws_route" "backend_services_route" {
  route_table_id         = aws_default_route_table.BACKEND_SERVICES_ROUTE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.BACKEND_SERVICES_IGW.id # Replace with actual internet gateway ID

  depends_on = [aws_vpc.BACKEND_SERVICES_VPC]  # Ensure VPC is created before route
}

resource "aws_route" "backend_services_to_web_app" {
  route_table_id         = aws_default_route_table.BACKEND_SERVICES_ROUTE.id
  destination_cidr_block = "10.0.0.0/16"  # Replace with actual WEB_APP VPC CIDR block
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.backend_services_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.backend_services_attachment]
}

resource "aws_route" "backend_services_to_shared_database" {
  route_table_id         = aws_default_route_table.BACKEND_SERVICES_ROUTE.id
  destination_cidr_block = "12.0.0.0/16"  # Replace with actual SHARED_DATABASE VPC CIDR block
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.backend_services_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.backend_services_attachment]
}