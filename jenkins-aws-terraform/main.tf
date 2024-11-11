provider aws {
    region = "ap-south-1"
}

variable vpc_name {}
variable vpc_cidr {}
variable avail_zone {}
variable project {}
variable env {}
variable public_key_location{}
variable instance_type {}
variable public_subnet_cidrs{}


module my_cicd_vpc {
    source = "terraform-aws-modules/vpc/aws"
    name = var.vpc_name
    cidr = var.vpc_cidr

    azs = [var.avail_zone]
    public_subnets = var.public_subnet_cidrs

    tags = {
        Name = "${var.project}-${var.env}-vpc"
    }
    public_subnet_tags = {
        Name = "${var.project}-${var.env}-subnet-1"
    }
}


resource "aws_key_pair" "ssh_key" {
    key_name = "my_cicd-ssh-key"
    public_key = file(var.public_key_location)
}

resource "aws_security_group" "my-cicd-sg" {
    name = "my-cicd-sg"
    vpc_id = module.my_cicd_vpc.vpc_id

    # SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Http
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

     tags = {
        Name = "${var.project}-${var.env}-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_instance" "jenkins-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = module.my_cicd_vpc.public_subnets[0]
    vpc_security_group_ids = [aws_security_group.my-cicd-sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh_key.key_name
    availability_zone = var.avail_zone
    user_data = file("install-jenkins.sh")

    tags = {
        Name = "${var.project}-${var.env}-jenkins-server"
    }

}

output "jenkins-server-ip" {
  value =  aws_instance.jenkins-server.public_ip
}
