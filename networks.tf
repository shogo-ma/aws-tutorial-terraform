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

resource "aws_route_table" "prt" {
    vpc_id = "${aws_vpc.vpc_region.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat_gateway.id}"
    }
}

resource "aws_route_table_association" "public_r" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_eip" "eip" {
    vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = "${aws_eip.eip.id}"
    subnet_id = "${aws_subnet.public_subnet.id}"
}
