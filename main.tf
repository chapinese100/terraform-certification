resource "aws_instance" "ec2-prod" {
    ami                    = data.aws_ami.ami.id
    instance_type          = "t2.micro"
    availability_zone      = "us-east-1a"
    key_name               = aws_key_pair.ssh.key_name
    vpc_security_group_ids = [aws_security_group.prov_fw.id]
}

resource "aws_key_pair" "ssh" {
    key_name   = "provkey"
    public_key = file("C:/Users/Compufire/Documents/terraform_course/mykeypair.pub")
}

resource "aws_security_group" "prov_fw" {
    name   = "prov_fw"

  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "prov_null" {
    triggers = {
        public_ip = aws_instance.ec2-prod.public_ip
    }

    connection {
        type = "ssh"
        host = aws_instance.ec2-prod.public_ip
        private_key = file("C:/Users/Compufire/Documents/terraform_course/mykeypair.pem")
        user = "ubuntu"
        timeout = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get -y update",
            "sudo apt-get install -y apache2",
            "sudo service apache2 start",
            "echo '<!doctype html><html><body><h1>CONGRATS!!..You have configured successfully your remote exec provisioner!</h1></body></html>' | sudo tee /var/www/html/index.html"
            ]
    }
}
