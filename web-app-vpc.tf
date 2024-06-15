
web-app-vpc.tf
resource "aws_vpc" "WEB_APP_VPC" {
  cidr_block       = "10.0.0.0/16"
  

  tags = {
    Name = "WEB_APP_VPC"
  }
}

resource "aws_subnet" "WEB_APP_SUBNET" {
  vpc_id     = aws_vpc.WEB_APP_VPC.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "WEB_APP_SUBNET"
  }
}

resource "aws_internet_gateway" "WEB_APP_IGW" {
  vpc_id     = aws_vpc.WEB_APP_VPC.id

  tags = {
    Name = "WEB_APP_IGW"
  }
}

resource "aws_default_route_table" "WEB_APP_ROUTE" {
  default_route_table_id = aws_vpc.WEB_APP_VPC.default_route_table_id

  tags = {
    Name = "WEB_APP_ROUTE"
  }
}

resource "aws_route" "web_app_route" {
  route_table_id         = aws_default_route_table.WEB_APP_ROUTE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.WEB_APP_IGW.id

  depends_on = [aws_vpc.WEB_APP_VPC]  # Ensure VPC is created before route
}

# Route to BACKEND_SERVICES_VPC via Transit Gateway Attachment
resource "aws_route" "web_app_to_backend_services" {
  route_table_id         = aws_default_route_table.WEB_APP_ROUTE.id
  destination_cidr_block = "11.0.0.0/16"  # Replace with actual VPC 2 CIDR block
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.web_app_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.web_app_attachment]
}

# Route to SHARED_DATABASE_VPC via Transit Gateway Attachment
resource "aws_route" "web_app_to_shared_database" {
  route_table_id         = aws_default_route_table.WEB_APP_ROUTE.id
  destination_cidr_block = "12.0.0.0/16"  # Replace with actual VPC 3 CIDR block
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.web_app_attachment.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.web_app_attachment]
}