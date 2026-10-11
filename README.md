# Control de facturación

**Gestión de vendedores, productos, clientes y facturas con IVA del 13%, comisiones, PDF y alertas de acceso.**

![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.4-4479A1?logo=mysql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Proyecto académico](https://img.shields.io/badge/Proyecto-Acad%C3%A9mico-2563EB)

Aplicación para la asignatura de Desarrollo de Aplicaciones Web. La interfaz (HTML, CSS y JavaScript) consulta una API PHP; los datos viven en MySQL y los comprobantes se generan como PDF de texto sin dependencias externas. El envío de correos (facturas y alertas de acceso) usa PHPMailer contra Gmail con contraseña de aplicación.

## Componentes

| Parte | Tecnología |
| --- | --- |
| Interfaz | HTML, CSS y JavaScript con `fetch()` a la API en ruta relativa |
| API y PDF | PHP 8 (PDO, sesiones, CSRF) y PHPMailer vendorizado |
| Base de datos | MySQL 8; `database/schema.sql` crea estructura, migración vigente y datos de ejemplo |
| Despliegue | Docker Compose (Apache + MySQL), con perfil productivo tras proxy nginx TLS |

## Requisitos (sin Docker)

- PHP 8.3 con `pdo_mysql` y un servidor Apache o PHP integrado.
- MySQL 8. El usuario debe ejecutar `database/schema.sql` (instalación nueva; **es destructivo**, reinicia las tablas) o `database/actualizacion.sql` sobre una base existente.

## Ejecutar con Docker

1. Preparar el entorno (PowerShell: `Copy-Item .env.example .env`) y definir `MYSQL_ROOT_PASSWORD` y `FACTURACION_DB_PASS`. Las credenciales de Gmail son opcionales: sin ellas los correos quedan en cola como pendientes.

   ```bash
   docker compose up --build
   ```

   En el primer arranque MySQL aplica `database/schema.sql` automáticamente. Abrir **[http://localhost:8080/](http://localhost:8080/)**.

2. Crear el administrador (sólo desde consola; la contraseña se imprime una vez):

   ```bash
   docker compose exec app php database/crear-admin.php
   ```

3. Perfil productivo con proxy TLS (puerto `HTTPS_PORT`, por defecto 8444):

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
   ```

   `tls-certs-init` genera un certificado autofirmado la primera vez (con `TLS_CN` como nombre DNS o IP). Los datos persisten en los volúmenes `mysql-data` y `tls-certs`; `docker compose down -v` los elimina.

## Acceso y horarios

Todos los usuarios, incluido el administrador supremo, sólo pueden iniciar sesión en sus días y horario autorizados (los datos de ejemplo usan lunes a sábado,08:00 a18:00). Las restricciones se revisan en cada solicitud. Fuera del horario el sistema responde «Hora fuera del horario autorizado» y registra la alerta.

## Correo

La configuración de transporte (`config/correo.php`) lee `FACTURACION_SMTP_USUARIO` y `FACTURACION_SMTP_CLAVE`: una dirección Gmail y su contraseña de aplicación de exactamente 16 caracteres. El destinatario de alertas es `FACTURACION_CORREO_JEFE` y puede configurarse después desde el panel supremo. Los correos se encolan en la base; un fallo de envío no elimina la factura ni la alerta, y el panel permite reintentar y enviar una prueba.

## Notas de seguridad

- El panel supremo crea y administra usuarios, horarios y períodos; la autorización vive siempre en PHP.
- Los usuarios de ejemplo (`vendedor`, `juan`, `cumple`) nacen con la contraseña `password`; cámbialos o desactívalos en el panel antes de un uso real.
- `database/crear-admin.php` se niega a ejecutarse por HTTP; el administrador inicial sólo puede crearse desde la consola del contenedor.

## Estructura

```text
bvm-facturacion/
├── api/                    API PHP: login, catálogos, facturas, PDF, panel
├── assets/                 Interfaz: CSS y JavaScript
├── config/                 Conexión a MySQL y transporte de correo
├── database/               schema.sql, actualizacion.sql y crear-admin.php
├── deploy/
│   ├── apache/produccion.conf  Ajuste HTTPS tras el proxy
│   └── docker/nginx.conf       Proxy TLS del perfil productivo
├── vendor/PHPMailer/       PHPMailer vendorizado (sin Composer)
├── .env.example            Plantilla de configuración
├── Dockerfile              Imagen Apache + PHP 8.3
├── docker-compose.yml      Pila dev: app + MySQL 8
├── docker-compose.prod.yml Combinación productiva con proxy TLS
└── index.html              Entrada de la interfaz
```
