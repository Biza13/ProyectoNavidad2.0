# Referencia al rol IAM existente en mi cuenta de aws que es (LabRole) usando su ARN
data "aws_iam_role" "labrole" {
  name = "LabRole" 
}

#definición de la tarea de ecs
resource "aws_ecs_task_definition" "apache_tarea" {

  #familia a la que pertenece la tarea
  family = "apache-tarea"

  execution_role_arn = data.aws_iam_role.labrole.arn
  task_role_arn      = data.aws_iam_role.labrole.arn

  # Modo de red para Fargate
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # Especificar recursos a nivel de la tarea
  cpu    = "512"
  memory = "1024"

  container_definitions = <<TASK_DEFINITION
  [
    {
      "cpu": 256,
      "entryPoint": [
        "bash",
        "-c",
        "apt-get update && apt-get install -y apache2 && service apache2 start && tail -f /dev/null && apt install -y nodejs && apt install -y npm && apt install nano -y && apt clean"
      ],
      "environment": [
        {"name": "VARNAME", "value": "VARVAL"}
      ],
      "essential": true,
      "image": "${aws_ecr_repository.repositorio_ecr.repository_url}:img-apachenodenpm",
      "memory": 512,
      "name": "apache-container",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ]
    },

    {
      "cpu": 256,
      "entryPoint": [
        "bash",
        "-c",
        "apt-get update && apt install -y nodejs && apt install -y npm && apt install nano -y && npm install -g json-server tail -f /dev/null && apt clean"
      ],
      "environment": [
        {"name": "VARNAME", "value": "VARVAL"}
      ],
      "essential": true,
      "image": "${aws_ecr_repository.repositorio_ecr.repository_url}:img-jsonserver",
      "memory": 512,
      "name": "json-api-container",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        },
        {
          "containerPort": 3001,
          "protocol": "tcp"
        },
        {
          "containerPort": 3002,
          "protocol": "tcp"
        }
      ]
    }
  ]
TASK_DEFINITION

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
