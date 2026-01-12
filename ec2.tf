resource "aws_key_pair" "rails_key" {
  key_name   = "rails-key"
  public_key = trimspace(file("C:/Users/gowth/.ssh/id_rsa.pub"))
}

resource "aws_security_group" "rails_sg" {
  name   = "rails-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change later if needed
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "rails_ec2" {
  ami                         = "ami-0f5ee92e2d63afc18" # Ubuntu 22.04 ap-south-1
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true

  key_name               = aws_key_pair.rails_key.key_name
  vpc_security_group_ids = [aws_security_group.rails_sg.id]

  depends_on = [
    aws_db_instance.this
  ]

  user_data = <<-EOF
              #!/bin/bash
              set -eux

              apt-get update -y
              apt-get install -y \
                git curl build-essential libpq-dev nodejs

              # ---- Switch to ubuntu user ----
              su - ubuntu <<'USERDATA'
              set -eux

              # rbenv setup
              git clone https://github.com/rbenv/rbenv.git ~/.rbenv
              git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

              echo 'export RBENV_ROOT="$HOME/.rbenv"' >> ~/.bashrc
              echo 'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' >> ~/.bashrc
              echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc

              export RBENV_ROOT="$HOME/.rbenv"
              export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
              eval "$(rbenv init - bash)"

              rbenv install 3.2.4
              rbenv global 3.2.4

              gem install bundler

              cd ~
              git clone https://github.com/YOUR_GITHUB/store-main.git
              cd store-main

              export RAILS_ENV=production
              export DB_HOST=${aws_db_instance.this.address}
              export DB_NAME=store_production
              export DB_USERNAME=storeuser
              export DB_PASSWORD='${var.db_password}'
              export RAILS_MASTER_KEY='${var.rails_master_key}'


              bundle install
              bundle exec rails db:migrate

              bundle exec rails server -e production -b 0.0.0.0 -p 3000
              USERDATA
              EOF

  tags = {
    Name = "rails-prod"
  }
}
