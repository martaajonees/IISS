terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

// Instanciamos la imagen de mariadb
resource "docker_image" "mariadb" {
  name         = "mariadb:latest"
  keep_locally = false
}

// Instanciamos el contenedor de mariadb
resource "docker_container" "mariadb" {
  image = docker_image.mariadb.image_id
  name  = "mariadb"
  ports {
    internal = 3306
    external = 3306
  }
  env = [
    "MYSQL_ROOT_PASSWORD=admin",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=admin"
  ]
  networks_advanced {
    name = docker_network.miRed.name
  }
  volumes {
    volume_name    = docker_volume.miVolumen.name
    container_path = "/var/www/html"
  }
}

// Instanciamos la imagen de docker
resource "docker_image" "wordpress" {
  name         = "wordpress:latest"
  keep_locally = false
}

// Instanciamos el contenedor de wordpress
resource "docker_container" "wordpress" {
  image = docker_image.wordpress.image_id
  name  = "${var.container_name}"
  ports {
    internal = 80
    external = 8001
  }
  env = [
    "WORDPRESS_DB_HOST=mariadb:3306",
    "WORDPRESS_DB_USER=wordpress",
    "WORDPRESS_DB_PASSWORD=admin",
  ]
  depends_on = [docker_container.mariadb]
  networks_advanced {
    name = docker_network.miRed.name
  }
  volumes {
    volume_name    = docker_volume.miVolumen.name
    container_path = "/var/www/html"
  }
}

//Creamos una red Docker para que los contenedores se comuniquen
resource "docker_network" "miRed" {
  name = "mi-red-docker"
}

//Creamos un recurso para el volumen de datos
resource "docker_volume" "miVolumen" {
  name = "mi-volumen-docker"
}