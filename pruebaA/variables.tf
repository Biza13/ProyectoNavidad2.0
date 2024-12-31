variable "vpc" {
    description = "rango de vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "cidrSubredPublica"{
    description = "Rango de ips de la subred pública"
    type = string
    default = "10.0.101.0/24"
}

variable "cidrSubredPublicaAz"{
    description = "Rango de ips de la subred pública dos"
    type = string
    default = "10.0.102.0/24"
}

variable "cidrSubredPrivada"{
    description = "Rango de ips de la subred privada"
    type = string
    default = "10.0.103.0/24"
}

variable "s3"{
  description = "Nombre del bucket s3"
  type = string
  default = "cubo-s3-begona"
}

variable "ecr"{
    description = "nombre del repositorio ecr"
    type = string
    default = "repositorio-apache"
}