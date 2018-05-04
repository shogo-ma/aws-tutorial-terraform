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
