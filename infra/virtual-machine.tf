resource "aws_instance" "mongo_server" {
  ami                    = "ami-0080836bbeccd860a"
  instance_type          = "t2.large"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  subnet_id              = aws_subnet.public_subnets.id
  iam_instance_profile   = aws_iam_instance_profile.vm-profile.name

  root_block_device {
    volume_size           = 50
    delete_on_termination = true
  }

  tags = {
    Name = "mongo server"
  }

}

resource "aws_key_pair" "ssh_key" {
  key_name   = "mongo-vm key"
  public_key = file("~/.ssh/wiz-key.pub")
}

