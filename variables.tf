data "aws_ami" "ami" {
  owners = ["amazon"]
  most_recent = true

#  filter {
#   name = "name"
#  }
}

variable "lifecycles" {
  default = "t2.micro"
}