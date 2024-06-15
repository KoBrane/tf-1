
# Create a security group named 'customer-securitygrp' with ingress rules
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.WEB_APP_VPC.id
  tags = {
    Name = "Webapp-sg"
  }
 

  # Allow SSH access from your specific IP or CIDR block (replace with yours)
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access from anywhere for testing (consider restricting later)
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Remove unnecessary ICMP rule for web applications (optional)
  # ingress {
  #   from_port = -1
  #   to_port   = -1
  #   protocol  = "icmp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # Allow all outbound traffic for simplicity (consider restricting later)
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# Launch the EC2 instance
resource "aws_instance" "webapp_linux" {
  # Use data source to retrieve the latest Ubuntu AMI
  ami = data.aws_ami.latest_ubuntu_ami.id

  instance_type = "t2.micro"  # Adjust instance type as needed

  # Ensure you have a key pair created and named "customer-keypair" in AWS
  key_name = "webapp_keypair"

  # Securely encode the user data script with base64encode
  user_data = base64encode(<<EOF
#!/bin/bash

# Update package list for Ubuntu
sudo apt update -y

# Install Nginx web server
sudo apt install nginx -y

# Start the Nginx service
sudo systemctl start nginx

# Enable Nginx to start automatically on boot
sudo systemctl enable nginx

# Create and populate the index.html file with hostname and IP address
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to My Web App!</title>
<style>
body {
  font-family: Arial, sans-serif;
  background-color: #f0f0f0;
}
.container {
  max-width: 800px;
  margin: 50px auto;
  padding: 20px;
  background-color: #fff;
  border-radius: 5px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
}
</style>
</head>
<body>
<div class="container">
  <h1>Welcome to My Web App!</h1>
  <p><strong>Hostname:</strong> $(hostname)</p>
  <p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>
</div>
</body>
</html>
EOF


  )

  # Tag the instance for easy identification
  tags = {
    Name = "Webapp-Linux-Instance"
  }

  # Associate the instance with a security group
  vpc_security_group_ids = [aws_default_security_group.default.id]

  # Associate the instance with a subnet
  subnet_id = aws_subnet.WEB_APP_SUBNET.id

  # Enable auto-assign public IP (optional)
  associate_public_ip_address = true
}

# Output the public IP address of the instance (optional)
output "webapp_public_ip" {
  value = aws_instance.webapp_linux.public_ip
}