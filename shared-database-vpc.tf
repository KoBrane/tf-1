
resource "aws_vpc" "SHARED_DATABASE_VPC" {
  cidr_block       = "12.0.0.0/16"
  

  tags = {
    Name = "SHARED_DATABASE_VPC"
  }
}

resource "aws_subnet" "SHARED_DATABASE_SUBNET" {
  vpc_id     = aws_vpc.SHARED_DATABASE_VPC.id
  cidr_block = "12.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "SHARED_DAYABASE_SUBNET"
  }
}

resource "aws_internet_gateway" "SHARED_DATABASE_IGW" {
  vpc_id     = aws_vpc.SHARED_DATABASE_VPC.id

  tags = {
    Name = "SHARED_DATABASE_IGW"
  }
}
# Create a default route table for shared database VPC
resource "aws_default_route_table" "SHARED_DATABASE_ROUTE" {
  default_route_table_id = aws_vpc.SHARED_DATABASE_VPC.default_route_table_id

  tags = {
    Name = "SHARED_DATABASE_ROUTE"
  }
}

# Create a default route for shared database VPC
resource "aws_route" "shared_database_route" {
  route_table_id         = aws_default_route_table.SHARED_DATABASE_ROUTE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.SHARED_DATABASE_IGW.id # Replace with actual internet gateway ID

  depends_on = [aws_vpc.SHARED_DATABASE_VPC]  # Ensure VPC is created before route
}

# Route to backend services VPC via Transit Gateway Attachment
resource "aws_route" "shared_database_to_backend_services" {
  route_table_id         = aws_default_route_table.SHARED_DATABASE_ROUTE.id
  destination_cidr_block = "11.0.0.0/16"  # Replace with actual BACKEND_SERVICES VPC CIDR block
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.shared_database_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.shared_database_attachment]
}

resource "aws_route" "shared_database_to_webapp" {
  route_table_id         = aws_default_route_table.SHARED_DATABASE_ROUTE.id
  destination_cidr_block = "10.0.0.0/16"  # Replace with actual web_app VPC CIDR block
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.shared_database_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.shared_database_attachment]
}