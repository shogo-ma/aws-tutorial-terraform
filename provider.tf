variable "aws_access_key" {}
variable "aws_secret_access_key" {}
variable "ssh_key_file" {}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_access_key}"
    region = "ap-northeast-1"
}
