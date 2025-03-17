variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0e1bed4f06a3b463d" # Ubuntu image
}

# as requested, t3.medium
variable "instance_type" {
  default = "t3.medium"
}

# name of ssh key on my machine
variable "ssh_key_name" {
  default = "liad_ssh_key"
}

# path of the key in my machine
variable "ssh_key_path" {
  default = "~/.ssh/liad_ssh_key.pub"
}

# sg name
variable "security_group_name" {
  default = "liad_security_group_name"
}

variable "subnet_id" {
  description = "The ID of the existing public subnet"
  type        = string

  # i got this id from the aws cli
  default     = "subnet-0da18b5db37c9b627"
}