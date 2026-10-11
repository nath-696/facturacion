# syntax=docker/dockerfile:1

# ── Imagen de la aplicación PHP ────────────────────────────────────────────────
# Apache sirve la interfaz (index.html, assets/) y la API (api/*.php) en un
# mismo origen; no hace falta proxy inverso ni configuración CORS en despliegue.
FROM php:8.3-apache

# Única extensión necesaria fuera del conjunto por defecto: PDO sobre MySQL.
# iconv, openssl, sesión y mbstring ya vienen incluidas en la imagen base.
RUN docker-php-ext-install pdo_mysql

# El contenido del repositorio se copia en el docroot por defecto de Apache.
# No se incrusta ningún .env: la configuración llega por variables de entorno.
COPY . /var/www/html/

EXPOSE 80
