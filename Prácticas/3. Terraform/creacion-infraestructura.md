## Creación de infraestructura Docker con Terraform
#### Paso 1. Terraform configuration
Una vez instalamos Terraform, se necesita hacer una configuración previa. Se debe añadir a nuestro directorio 
terraform un archivo de configuración `.tf` con la plataforma que queramos, en nuestro caso Docker.

Se añadirá de la siguiente forma:
<div align="center">
  <img src="https://github.com/martaajonees/IISS/assets/100365874/86a66e8e-e309-4630-92e2-86cd357e8aff" alt="Texto alternativo" />
  <p>Figura 1. Creación de archivo de configuración </p>
</div>



Ahora añadimos el siguiente contenido a dicho archivo:
```terraform
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
    volume_name     = docker_volume.miVolumen.name
    container_path  = "/var/www/html"
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
  name  = "wordpress"
  ports {
    internal = 80
    external = 8001
  }
  env = [
    "WORDPRESS_DB_HOST=mariadb:3306",
    "WORDPRESS_DB_USER=wordpress",
    "WORDPRESS_DB_PASSWORD=admin"
  ]
  depends_on   = [docker_container.mariadb]
  networks_advanced {
    name = docker_network.miRed.name
  }
  volumes {
    volume_name     = docker_volume.miVolumen.name
    container_path  = "/var/www/html"
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
```
#### Paso 2. Iniciamos terraform
Una vez creado el archivo de configuración, iniciamos terraform con el comando `terraform init`. 
<div align="center">
  <img src="https://github.com/martaajonees/IISS/assets/100365874/1f27d006-480f-4eac-b534-0c3ed3227a72" alt="Texto alternativo" />
  <p> Figura 2. Iniciamos terraform </p>
</div>

#### Paso 3. Validamos y formateamos la configuración
Validamos la configuración anterios con los siguientes comandos antes de crear la infraestructura.
<div align="center">
  <img src="https://github.com/martaajonees/IISS/assets/100365874/c95a8bd4-1c08-4945-8a34-afc301b97b0e" alt="Texto alternativo" />
  <p> Figura 3. Vemos que nuestra configuración está bien</p>
</div>

#### Paso 4. Creamos la infraestructura
Para ello usamos el comando `terraform apply`, nos aparecerá el plan de los archivos que van a crearse y pedirá confirmación. 
Tras realizar todo esto nos debe aparecer el siguiente mensaje :
<div align="center">
  <img src="https://github.com/martaajonees/IISS/assets/100365874/59488ba2-8915-4fce-8fa0-73301c643982" alt="Texto alternativo" />
  <p> Figura 4. Creamos nuestra infraestructura</p>
</div>

#### Paso 5. Verificamos
Ahora podemos conprobar que en la dirección [http:](http://localhost:8001/)http://localhost:8001/ se encuentra la pantalla de 
configuración de WordPress.
<div align="center">
  <img src="https://github.com/martaajonees/IISS/assets/100365874/b9972e77-156d-4e05-9c60-90f38733c562" alt="Texto alternativo" style="width: 75%;" />
  <p> Figura 5. La infraestructura funciona de manera correcta</p>
</div>

#### Variables de entorno
Podemos definirle variables de entorno creando un nuevo archivo de configuración llamado `variables.tf` cuyo contenido será el siguiente:
<div align="center">
  <img src="https://github.com/martaajonees/IISS/assets/100365874/0283e4bf-7898-4346-a6cb-4db046e16628" alt="Texto alternativo"/>
  <p> Figura 6. Archivo de variables de entorno</p>
</div>

Por último modificamos el archivo de configuración principal `wordpress.tf` como se muestra abajo y aplicamos pasos 4 y 5 de este documento. EL archivo sigue funcionando de igual forma.
```terraform
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
```








