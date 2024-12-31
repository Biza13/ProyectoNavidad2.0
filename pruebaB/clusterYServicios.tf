#crear el cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_nombre
}

#--------------------SERVICIOS--------------------

#el servicio es donde debes asociar el Load Balancer con el servicio ECS para que las tareas puedan recibir tráfico a través de él.
#este sera el servicio para el contenedor de la pagina
resource "aws_ecs_service" "apache_service" {
  name            = "apache-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.apache_tarea.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.subred-privada.id] #ponemos el servicio de la pagina en la subred privada
    security_groups = [aws_security_group.security_ecs.id]  #ponemos el grupo de seguridad de las ecs que no permiten entrada desde internet
    assign_public_ip = false  #para que no asigne una ip publica
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.apache_target_group.arn
    container_name   = "apache-container"
    container_port   = 80
  }
}

#Este sera el servicio para el contenedor json server puerto usuarios.json
resource "aws_ecs_service" "json_server_service_3000" {
  name            = "json-server-service_3000"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.apache_tarea.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.subred-privada.id] #ponemos el servicio de los json en la subred privada
    security_groups  = [aws_security_group.security_ecs.id]  #ponemos el grupo de seguridad de las ecs que no permiten entrada desde internet
    assign_public_ip = false  #para que no asigne una ip publica
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.json_target_group_3000.arn
    container_name   = "json-api-container"
    container_port   = 3000
  }
}

#Este sera el servicio para el contenedor json server puerto ales.json
resource "aws_ecs_service" "json_server_service_3001" {
  name            = "json-server-service-3001"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.apache_tarea.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.subred-privada.id] #ponemos el servicio de los json en la subred privada
    security_groups  = [aws_security_group.security_ecs.id]  #ponemos el grupo de seguridad de las ecs que no permiten entrada desde internet
    assign_public_ip = false  #para que no asigne una ip publica
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.json_target_group_3001.arn
    container_name   = "json-api-container"
    container_port   = 3001
  }
}

#Este sera el servicio para el contenedor json server puerto stouts.json
resource "aws_ecs_service" "json_server_service_3002" {
  name            = "json-server-service-3002"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.apache_tarea.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.subred-privada.id] #ponemos el servicio de los json en la subred privada
    security_groups  = [aws_security_group.security_ecs.id]  #ponemos el grupo de seguridad de las ecs que no permiten entrada desde internet
    assign_public_ip = false  #para que no asigne una ip publica
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.json_target_group_3002.arn 
    container_name   = "json-api-container"
    container_port   = 3002
  }
}

#--------------------FIN SERVICIOS--------------------
