resource "aws_db_subnet_group" "this" {
  name       = "store-rds-subnet-v2"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}


resource "aws_security_group" "rds_sg" {
  name   = "store-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rails_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rails_sg.id
}


resource "aws_db_instance" "this" {
  identifier             = "store-postgres"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible    = false
  skip_final_snapshot    = true
}


