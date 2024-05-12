resource "tls_private_key" "finance-me-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "app-key" {
  key_name   = "finance-me-key"
  public_key = tls_private_key.finance-me-key.public_key_openssh
}

resource "local_file" "finance-me-key" {
  content  = tls_private_key.finance-me-key.private_key_pem
  filename = "finance-me-key.pem"

  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }

}
resource "aws_instance" "deploy-server" {
  ami = "ami-04b70fa74e45c3917" 
  instance_type = "t2.micro" 
  key_name = "finance-me-key"
  vpc_security_group_ids= ["sg-090308876f85665e4"]
  tags = {
    Name = "Deploy-server"
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = tls_private_key.finance-me-key.private_key_pem
    host     = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [ "echo 'wait to start instance' "]
  }
  provisioner "local-exec" {
        command = " echo ${aws_instance.test-server.public_ip} > inventory "
  }
   provisioner "local-exec" {
   command = "ansible-playbook /var/lib/jenkins/workspace/Banking/scripts/finance-me-playbook.yaml"
  } 
}
