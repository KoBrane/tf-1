# AMI id 
output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu_ami.id
}

jen