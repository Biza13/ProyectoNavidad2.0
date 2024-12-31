# Referencia al rol IAM existente en mi cuenta de aws que es (LabRole) usando su ARN
data "aws_iam_role" "labrole" {
  name = "LabRole" 
}

#definición de la tarea de ecs
resource "aws_ecs_task_definition" "apache_tarea" {

  #familia a la que pertenece la tarea
  family                = "apache-tarea"

  execution_role_arn    = data.aws_iam_role.labrole.arn
  task_role_arn         = data.aws_iam_role.labrole.arn 

  # Modo de red para Fargate
  network_mode          = "awsvpc"  
  requires_compatibilities = ["FARGATE"]

  # Especificar recursos a nivel de la tarea
  cpu                      = "512"
  memory                   = "1024"
  
  container_definitions = jsonencode([
    { # Primer contenedor (Apache, para la página web)
      name      = "apache-container"
      image     = ""
      essential = true
      memory = 512
      cpu = 256

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    },

    { # Segundo contenedor (API JSON)
      name      = "json-api-container"
      image     = ""
      essential = true 
      memory = 512
      cpu = 256

      portMappings = [
        {
          containerPort = 3000  # Puerto donde se expone el primer archivo JSON (usuarios.json)
          hostPort      = 3000
          protocol      = "tcp"
        },
        {
          containerPort = 3001  # Puerto donde se expone el segundo archivo JSON (ales.json)
          hostPort      = 3001
          protocol      = "tcp"
        },
        {
          containerPort = 3002  # Puerto donde se expone el tercer archivo JSON (stouts.json)
          hostPort      = 3002
          protocol      = "tcp"
        }
      ]
    }

  ])
}

#--------------------GRUPOS Y REGLAS PARA GRUPOS DE PUERTOS--------------------

#El target group es donde el ALB dirigirá el tráfico, en este caso a las tareas de las ecs que estan ejecutando mis contenedores
#este es el targer group para la web
resource "aws_lb_target_group" "apache_target_group" {
  name     = "apache-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Desarrollo-web-VPC.id
  target_type = "ip"  #hay que poner esto porque no estamos usando ec2 sino fargate serverless

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#regla para el contenedor de apache con la web
resource "aws_lb_listener_rule" "apache_rule" {
  listener_arn = aws_lb_listener.http.arn

  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apache_target_group.arn 
  }

  condition {
    path_pattern {
      values = ["/"]  #ruta
    }
  }
}



# Target Group para el puerto 3000 (usuarios.json)
resource "aws_lb_target_group" "json_target_group_3000" {
  name     = "json-target-group-3000"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.Desarrollo-web-VPC.id
  target_type = "ip"  #hay que poner esto porque no estamos usando ec2 sino fargate serverless

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Regla para enrutar tráfico al puerto 3000 (usuarios.json)
resource "aws_lb_listener_rule" "json_usuarios_rule" {
  listener_arn = aws_lb_listener.http.arn

  priority     = 101 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.json_target_group_3000.arn
  }

  condition {
    path_pattern {
      values = ["/usuarios.json"] #ruta
    }
  }
}




# Target Group para el puerto 3001 (ales.json)
resource "aws_lb_target_group" "json_target_group_3001" {
  name     = "json-target-group-3001"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = aws_vpc.Desarrollo-web-VPC.id
  target_type = "ip"  #hay que poner esto porque no estamos usando ec2 sino fargate serverless

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Regla para enrutar tráfico al puerto 3001 (ales.json)
resource "aws_lb_listener_rule" "json_ales_rule" {
  listener_arn = aws_lb_listener.http.arn

  priority     = 102

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.json_target_group_3001.arn
  }

  condition {
    path_pattern {
      values = ["/ales.json"] #ruta
    }
  }
}



# Target Group para el puerto 3002 (stouts.json)
resource "aws_lb_target_group" "json_target_group_3002" {
  name     = "json-target-group-3002"
  port     = 3002
  protocol = "HTTP"
  vpc_id   = aws_vpc.Desarrollo-web-VPC.id
  target_type = "ip"  #hay que poner esto porque no estamos usando ec2 sino fargate serverless

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#Regla para enrutar tráfico al puerto 3002 (stouts.json)
resource "aws_lb_listener_rule" "json_stouts_rule" {
  listener_arn = aws_lb_listener.http.arn 

  priority     = 103 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.json_target_group_3002.arn 
  }

  condition {
    path_pattern {
      values = ["/stouts.json"]   #ruta
    }
  }
}

#--------------------FIN GRUPOS Y REGLAS PARA GRUPOS DE PUERTOS--------------------