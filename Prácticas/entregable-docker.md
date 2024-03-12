# Entregable de Docker
## Parte 1
1. Crear un fichero docker-compose.yml con dos servicios: drupal + mysql.
2. Hacer que el servicio drupal utilice el puerto 81.
3. Hacer que ambos contenedores usen volúmenes para persistir información.
4. Comprobar que puede acceder a localhost:81 y puede visualizar la página de
configuración de drupal

```
version: '3.8'

services:
  mysql:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_DATABASE: drupal
      MYSQL_USER: drupal
      MYSQL_PASSWORD: drupalpass
      MYSQL_ROOT_PASSWORD: rootpass
    volumes:
      - mysql_data:/var/lib/mysql

  drupal:
    image: drupal:latest
    restart: always
    ports:
      - "81:81"
    volumes:
      - drupal_data:/var/www/html

volumes:
  mysql_data:
  drupal_data:

```
**Explicación** `mysql`
- `image: mysql:5.7` Se usa la versión 5.7 de mysql
- `restart: always` En caso de fallo, el contenedor se reiniciará automáticamente
- `environment` Aquí se especifican las variables del entorno para instanciar la base de datos de la imagen
- `volumes - mysql_data:/var/lib/mysql` Se usa un volumen para almacenar datos de mysql. Este volumen se guardará en el directorio /var/lib/mysql de nuestro contenedor

**Explicación** `drupal` 
- `image: drupal:latest` Se usa la imagen de drupal más recientemente guardada en docker.
-  `restart: always` En caso de fallo, el contenedor se reiniciará automáticamente.
-  `ports  - "81:81"` Se usa el puerto 81, permitiendo el acceso a la interfaz web de Drupal desde el host en el puerto 81.
-  `volumes: - drupal_data:/var/www/html` Se define el volumen drupal_data para almacenar datos de drupal. Se almacenará en el directorio /var/www/html de nuestro contenedor
<img width="957" alt="Captura de pantalla 2024-03-12 a las 9 40 24" src="https://github.com/martaajonees/IISS/assets/100365874/a17a32e4-5474-4933-93b1-b0d1d930a6b8">

## Parte 2
1. Crear un fichero docker-compose.yml con dos servicios: wordpress + mariadb.
2. Hacer que el servicio wordpress utilice el puerto 82.
3. Hacer que ambos contenedores usen la red redDocker .
4. Comprobar que puede acceder a localhost:82 y puede visualizar la página de
configuración de wordpress

```
services:
    mariadb:
        image: mariadb:10
        volumes:
            - data:/var/lib/mysql
        environment:
            - MYSQL_ROOT_PASSWORD=secret
            - MYSQL_DATABASE=wordpress
            - MYSQL_USER=manager
            - MYSQL_PASSWORD=secret
        networks:
            - redDocker
    web:
        image: wordpress:6
        depends_on:
            - mariadb
        volumes:
            - ./target:/var/www/html
        environment:
            - WORDPRESS_DB_USER=manager
            - WORDPRESS_DB_PASSWORD=secret
            - WORDPRESS_DB_HOST=db
            - WORDPRESS_DB_NAME=wordpress
        ports:
            - 82:80
        networks:
            - redDocker
networks:
  redDocker:

volumes:
    data:
```

**Explicación** `mariadb`
- `image: mariadb:10` Se usa la versión 10 de mariadb
- `environment` Aquí se especifican las variables del entorno para instanciar la base de datos de la imagen
- `volumes - data:/var/lib/mysql` Se usa un volumen para almacenar datos de mariadb. Este volumen se guardará en el directorio /var/lib/mysql de nuestro contenedor

**Explicación** `web` 
- `image: wordpress:6` Se usa la version 6 de wordpress.
- ` depends_on: - mariadb` Se especifica que esta imagen depende de mariadb por lo que se iniciará antes mariadb que wordpress
- `volumes: - ./target:/var/www/html` Se define un volumen que vincula el directorio ./target del host con el directorio/var/www/html.
- `environment: `Se especifican variables de entorno para el programa
-  `ports  - 82:80` Se usa el puerto 82, permitiendo el acceso a la interfaz web de wordpress e este puerto.
-  `networks: - redDocker` Se usa la red docker que hemos creado con anterioridad.
<img width="913" alt="Captura de pantalla 2024-03-12 a las 10 00 44" src="https://github.com/martaajonees/IISS/assets/100365874/bb628bfe-7857-45d9-b187-d534bda8ad37">
