# Entorno Docker para Symfony v7

## Red Docker
Si no existe, crear la red symfony_net:
```
docker network create --driver=bridge --subnet=172.18.0.0/16 symfony_net
```

## Clona este repositorio

    https://github.com/augc/docker-symfony.git <nombre>

## Accede a la carpeta

    cd <nombre>

## Levanta contenedores

Para que tus proyectos symfony puedan ser accesibles, este entorno configura dos contenedores distintos:

- Un contenedor ngnix para acceder a las distintas aplicaciones symfony que puedas tener, que utiliza los archivos de configuraciónde ngnix en la carpeta build/ para que puedas disponer de ello asignando nombres de dominio o puertos que creas convenientes
- Un contenedor con las versiones de php, symfony y composer necesarias

    docker compose build

Si todo ha ido bien, lanzamos los contenedores con la orden

    docker compose up -d

A partir de ahora podemos acceder al contenedor desde docker mediante

    docker exec -it symfony7_php bash

Pero siempre es mejor hacerlos desde un entorno de desarollo. Por ejemplo VS Code puede acceder al contenedor en funcionamiento y directamente crear y probar el código en él, con su propio servidor, sin utilizar el contenedor ngnix

## Symfony

    Crear un usuario y una base de datos específica para la app
    Crear un archivo .env.local con la configuración necesaria
