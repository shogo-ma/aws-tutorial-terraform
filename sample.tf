resource "aws_vpc" "vpc_region" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

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

    tags {
        Name = "Webサーバー"
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

    tags {
        Name = "WEB-SG"
    }
}
