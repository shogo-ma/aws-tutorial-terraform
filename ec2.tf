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
            "sudo yum install -y httpd php php-mysql php-mbstring",
            "sudo service httpd start",
            "sudo chkconfig httpd on",
            "wget http://ja.wordpress.org/latest-ja.tar.gz",
            "tar xvzf latest-ja.tar.gz",
            "cd wordpress",
            "sudo cp -r * /var/www/html/",
            "sudo chown apache:apache /var/www/html/ -R",
            "sudo service httpd restart"
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
