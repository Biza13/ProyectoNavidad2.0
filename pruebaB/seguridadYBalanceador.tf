#--------------------GRUPO SEGURIDAD--------------------
#crear un grupo de seguridad para ssh y http/https
resource "aws_security_group" "security_ecs" {
  name = "seguridad"
  description = "Security group para las ecs contenedores" #que al estar en una subred privada no recibiran trafico desde internet
  vpc_id      = aws_vpc.Desarrollo-web-VPC.id 

  # ingres reglas de entrada
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups  = [aws_security_group.lb_security.id]  # Permitir tráfico de entrada solo desde el ALB
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups  = [aws_security_group.lb_security.id]  # Permitir tráfico de entrada solo desde el ALB
  }
  
  #egress reglas de salida
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"] #permitir que los contenedores salgan a Internet a través de la NAT Gateway
  }
}

# Crear un grupo de seguridad para ALB
resource "aws_security_group" "lb_security" {
  name        = "alb-security"
  description = "Security group para ALB"
  vpc_id      = aws_vpc.Desarrollo-web-VPC.id

  # Permitir tráfico HTTP/HTTPS desde cualquier IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico HTTP desde cualquier IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico HTTPS desde cualquier IP
  }

  # Regla de salida (permitir todo el tráfico)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------FIN GRUPO SEGURIDAD--------------------

#--------------------BALANCEADOR Y LISTENER--------------------
#balanceador de carga para que siempre tengan la misma ip publica
resource "aws_lb" "balanceador" {
  name               = "balanceador-de-carga"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.lb_security.id]
  subnets            = [aws_subnet.subred-publica.id, aws_subnet.subred-publica-az2.id]
  enable_deletion_protection = false

  tags = {
    Name = "balanceador-de-carga"
  }
}

#listener para que el balanceador pueda escuchar las solicitudes 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.balanceador.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
    }
  }
}

#--------------------FIN BALANCEADOR Y LISTENER--------------------