resource "aws_vpc" "vpc_region" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "VPC領域"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = "${aws_vpc.vpc_region.id}"
    cidr_block = "10.0.1.0/24"

    tags {
        Name = "パブリックサブネット"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = "${aws_vpc.vpc_region.id}"
    cidr_block = "10.0.2.0/24"

    tags {
        Name = "プライベートサブネット"
    }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.vpc_region.id}"
}

resource "aws_route_table" "rt" {
    vpc_id = "${aws_vpc.vpc_region.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gateway.id}"
    }

    tags {
        Name = "パブリックルートテーブル"
    }
}

resource "aws_route_table_association" "public_r" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_instance" "web_server" {
    ami = "ami-ceafcba8"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public_subnet.id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.web_server_sg.id}"]
    private_ip = "10.0.1.10"
    key_name = "my-key"
   
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = "ec2-user"
            private_key = "${file(var.ssh_key_file)}"
        }
        inline = [
            "sudo yum install -y httpd",
            "sudo service httpd start",
            "sudo chkconfig httpd on"
        ]
    }

    tags {
        Name = "Webサーバー"
    }
}

resource "aws_instance" "mysql_server" {
    ami = "ami-ceafcba8"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private_subnet.id}"
    associate_public_ip_address = false
    security_groups = ["${aws_security_group.mysql_server_sg.id}"]
    private_ip = "10.0.2.10"
    key_name = "my-key"

    tags {
        Name = "DBサーバー"
    }
}

resource "aws_security_group" "web_server_sg" {
    vpc_id = "${aws_vpc.vpc_region.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "WEB-SG"
    }
}

resource "aws_security_group" "mysql_server_sg" {
    vpc_id = "${aws_vpc.vpc_region.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "DB-SG"
    }
}
