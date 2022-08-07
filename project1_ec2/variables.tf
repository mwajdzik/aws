variable "aws_az" {
  type        = string
  description = "AWS AZ"
  default     = "us-west-2a"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.1.64.0/18"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.1.64.0/24"
}

variable "linux_instance_type" {
  type        = string
  description = "EC2 instance type for Linux Server"
  default     = "t2.micro"
}

variable "linux_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}

variable "linux_root_volume_size" {
  type        = number
  description = "Volume size of root volume of Linux Server"
  default     = 10
}

variable "linux_data_volume_size" {
  type        = number
  description = "Volume size of data volume of Linux Server"
  default     = 10
}

variable "linux_root_volume_type" {
  type        = string
  description = "Volume type of root volume of Linux Server."
  default     = "gp2"
}

variable "linux_data_volume_type" {
  type        = string
  description = "Volume type of data volume of Linux Server"
  default     = "gp2"
}
