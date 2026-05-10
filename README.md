# UxiLibris — Gestor de Lecturas Personal

Una aplicación para amantes de la lectura que permite llevar un registro detallado de su colección, lecturas en curso, lista de deseos y hábitos de lectura con estadísticas visuales.

[![CI](https://github.com/UxiaRD/uxilibris_project/actions/workflows/ci.yml/badge.svg)](https://github.com/UxiaRD/uxilibris_project/actions/workflows/ci.yml)

<p align="center">
<img src="frontend_flutter/assets/images/icono.png" alt="Icono UxiLibris" width="150">
</p>

## Índice

1. [Características](#características)
2. [Tecnologías utilizadas](#tecnologías-utilizadas)
3. [Estructura del proyecto](#estructura-del-proyecto)
4. [Instalación y ejecución](#instalación-y-ejecución)
   - [Comparativa de opciones](#comparativa-de-opciones)
   - [Opción A — Despliegue en la nube (Render + Neon)](#opción-a--despliegue-en-la-nube-render--neon)
   - [Opción B — Docker en el navegador](#opción-b--docker-en-el-navegador)
   - [Opción C — APK móvil con backend local](#opción-c--apk-móvil-con-backend-local)
   - [Opción D — Entorno de desarrollo local](#opción-d--entorno-de-desarrollo-local)
5. [Tests](#tests)
6. [Limitaciones de la versión web](#limitaciones-de-la-versión-web)
7. [Autora](#autora)

---

## Características

### 🔐 Autenticación
- Registro e inicio de sesión seguros con validaciones en cliente y servidor.
- Restricciones de contraseña: mínimo una mayúscula y un número.
- **Sesión persistente**: las credenciales se almacenan cifradas en el dispositivo (keychain/keystore) y no es necesario volver a introducirlas al abrir la app.

### 📖 Colección de libros
- Añadir libros **manualmente**, mediante **escáner de código de barras ISBN** o mediante **búsqueda por título/autor en Google Books**.
  - El escáner y la búsqueda consultan la **API de Google Books** y rellenan automáticamente título, autor, portada y datos de saga.
  - Detección de duplicados: aviso si el ISBN ya está registrado.
- Editar y eliminar libros de la biblioteca.
- Filtrado por estado de lectura: *Todos*, *Leyendo*, *Pendientes*, *Leídos*.
- Barra de búsqueda por título, autor o saga.
- **Ordenación alfabética** automática con **barra de letras lateral**: al pulsar una letra el grid salta directamente a esa sección.
- Pull-to-refresh para sincronizar con el servidor.
- **Portadas** desde URL (Google Books), imagen local (galería del dispositivo) o imagen por defecto.
- **Formato del libro**: distingue entre ejemplar físico (borde por defecto) y digital (borde morado).
- **Favoritos**: marca un libro como favorito con la estrella de la portada; se refleja en estadísticas.

### 💜 Lista de Deseos
- Pantalla dedicada con los libros marcados como *deseo*.
- Los libros deseados se muestran con borde y corazón rosas para distinguirlos visualmente.
- Añadir deseos directamente desde el menú de carga con el estado preseleccionado.

### 📚 Gestión de sagas
- Colección de sagas con portadas apiladas de los volúmenes registrados.
- Las sagas **completadas** (todos los libros en estado *leído*) se muestran con fondo morado claro.
- Indicador de letra flotante al hacer scroll.
- Buscador por nombre de saga en tiempo real.
- Crear, editar y eliminar sagas.
- Pantalla de detalle con libros ordenados por volumen.
  - Si la saga tiene el total de libros definido, aparecen **tarjetas grises** para los volúmenes pendientes: al pulsar una se abre el formulario con saga y volumen prerellenados.
- Asignar libros existentes a una saga desde el diálogo de detalle.
- **Auto-creación de saga**: al guardar un libro con saga asignada, la saga se crea automáticamente si no existe.

### 📊 Estadísticas
- Tarjetas de resumen: libros leídos este año, total histórico, nota media y autor favorito.
- Gráfica de barras de libros leídos por mes con selector de año.
- Gráfica de líneas comparativa entre años (cuando hay datos de más de un año).
- Ranking de los 5 autores más leídos con barra de progreso relativa.
- Ranking de los 5 libros mejor puntuados.
- Sección **Mis favoritos**: todos los libros marcados como favorito, ordenados por puntuación.

### ⚙️ Ajustes
- Cambio de nombre de usuario, correo y contraseña (con verificación de la contraseña actual).
- Alternancia entre **tema claro y oscuro**.
- Recarga manual de la biblioteca desde el servidor.
- Cierre de sesión con confirmación.

### 🧭 Navegación
- **Drawer principal unificado** compartido por todas las pantallas: Libros, Sagas, Estadísticas y Lista de Deseos.
- La pantalla activa se resalta; las demás navegan directamente a su destino.

---

## Tecnologías utilizadas

| Capa | Tecnología |
|---|---|
| **Frontend** | Flutter 3 & Dart |
| **Backend** | Java 21, Spring Boot 3.2, Spring Data JPA |
| **Base de datos (local)** | MySQL 8.0 |
| **Base de datos (nube)** | PostgreSQL vía Neon |
| **Comunicación** | API REST (JSON), CORS global |
| **APIs externas** | Google Books API (ISBN y búsqueda por texto) |
| **Escaneo** | mobile_scanner (códigos de barras) |
| **Gráficas** | fl_chart |
| **Sesión segura** | flutter_secure_storage |
| **Estado** | provider |
| **Contenedores** | Docker, Docker Compose, nginx |
| **Despliegue backend** | Render |
| **Despliegue base de datos** | Neon (PostgreSQL gratuito y permanente) |
| **CI** | GitHub Actions |

---

## Estructura del proyecto

```text
uxilibris_project/
├── .github/workflows/ci.yml           # Pipeline CI (tests backend + frontend)
├── docker-compose.yml                 # Orquesta backend + BD + frontend web
├── nginx.conf                         # Configuración del servidor web (frontend)
├── Vagrantfile                        # Alternativa: VM Ubuntu con Docker preinstalado
│
├── scripts/
│   ├── modoA_compilar_apk_nube.bat    # Compila APK apuntando a Render
│   └── modoA_actualizar_apk_nube.bat  # Compila y actualiza APK vía ADB (sin desinstalar)
│
├── frontend_flutter/                  # App Flutter (móvil y web)
│   ├── test/
│   │   └── modelo/                   # Tests unitarios de modelos Dart
│   └── lib/
│       ├── controladores/            # Lógica de negocio desacoplada de la UI
│       ├── decoraciones/             # Temas, fondos y estilos globales
│       ├── modelo/                   # Entidades: Libro, Saga, Libreria…
│       ├── servicio/                 # ApiService y SessionManager
│       ├── pantallas/                # Pantallas de la aplicación
│       └── utilidades/               # Componentes compartidos (drawer, diálogos…)
│
├── backend_spring/                   # API REST (Java Spring Boot)
│   └── uxilibris-backend/
│       ├── Dockerfile                # Imagen Docker del backend
│       └── src/
│           ├── main/java/.../
│           │   ├── config/           # CORS
│           │   ├── controller/       # Endpoints: libros, sagas, auth, ISBN
│           │   ├── service/          # Lógica de negocio
│           │   ├── repository/       # Acceso a datos (JPA)
│           │   ├── entity/           # Entidades JPA: Libro, Saga, Usuario…
│           │   └── dto/              # Objetos de transferencia de datos
│           └── test/                 # Tests unitarios e integración
│
└── documentación/                    # Memoria, diagramas ER, clases y relacional
```

---

## Instalación y ejecución

### Comparativa de opciones

| | Opción A — Nube | Opción B — Docker | Opción C — APK local | Opción D — Desarrollo |
|---|---|---|---|---|
| **Uso** | App permanente desde móvil | Demo / presentación en navegador | Demo en móvil con backend local | Desarrollo activo |
| **Backend** | Render (cloud, gratuito) | Docker local | Docker o local | Local |
| **Base de datos** | Neon (cloud, gratuito y permanente) | MySQL (Docker) | MySQL (Docker/local) | MySQL local |
| **Qué instalar** | Cuenta Render + Neon | Docker Desktop | Docker Desktop + Flutter | Flutter, Java 21, MySQL |
| **Tiempo de setup** | ~15 min | ~5 min | ~10 min | ~20 min |
| **Datos persistentes** | Siempre (Neon) | Solo mientras Docker corre | Solo mientras el backend corre | Solo mientras MySQL corre |

---

### Opción A — Despliegue en la nube (Render + Neon)

El backend se despliega en **Render** y la base de datos en **Neon**. Una vez configurado, la app móvil (APK) funciona desde cualquier dispositivo y en cualquier momento sin necesidad de tener el ordenador encendido.

> **Aviso:** Render free tier duerme el backend tras 15 minutos de inactividad. La primera petición después de un periodo de inactividad puede tardar **hasta 2 minutos** en despertar. La app reintenta automáticamente durante ese tiempo y muestra un mensaje informativo; no es necesaria ninguna acción por parte del usuario.

#### Paso 1 — Crear la base de datos en Neon

1. Crea una cuenta gratuita en [neon.tech](https://neon.tech).
2. Crea un nuevo proyecto → Neon genera automáticamente una base de datos PostgreSQL.
3. En el panel de Neon, ve a **Connection Details** y anota:
   - **Host** (formato `ep-xxxx.region.aws.neon.tech`)
   - **Database** (por defecto `neondb`)
   - **Username**
   - **Password**

#### Paso 2 — Desplegar el backend en Render

1. Crea una cuenta gratuita en [render.com](https://render.com).
2. **New → Web Service** → conecta tu repositorio de GitHub.
3. Configura el servicio:
   - **Environment:** Docker
   - **Root Directory:** `backend_spring/uxilibris-backend`
   - **Plan:** Free
4. En la sección **Environment Variables**, añade las siguientes variables:

| Variable | Valor |
|---|---|
| `SPRING_DATASOURCE_URL` | `jdbc:postgresql://ep-xxxx.region.aws.neon.tech/neondb?sslmode=require` |
| `SPRING_DATASOURCE_USERNAME` | (usuario de Neon) |
| `SPRING_DATASOURCE_PASSWORD` | (contraseña de Neon) |
| `SPRING_JPA_HIBERNATE_DDL_AUTO` | `update` |
| `SPRING_JACKSON_SERIALIZATION_WRITE_DATES_AS_TIMESTAMPS` | `false` |
| `SPRING_JPA_OPEN_IN_VIEW` | `false` |
| `GOOGLE_BOOKS_API_KEY` | (tu clave de Google Books API, opcional) |

5. Pulsa **Deploy**. La primera compilación tarda ~5 minutos.
6. Una vez desplegado, copia la URL del servicio (formato `https://tu-servicio.onrender.com`).

> **URL de Neon sin pooler:** en `SPRING_DATASOURCE_URL` asegúrate de que el host **no contiene `-pooler`** (por ejemplo `ep-billowing-flower-a12345.eu-west-2.aws.neon.tech`, no `ep-billowing-flower-a12345-pooler.eu-west-2.aws.neon.tech`). El pooler impide que Hibernate cree las tablas.

#### Paso 3 — Compilar e instalar el APK

Con el backend en la nube, compila el APK apuntando a la URL de Render:

```bash
cd frontend_flutter
flutter pub get
flutter build apk --dart-define=BACKEND_URL=https://tu-servicio.onrender.com
```

El APK queda en:
```
frontend_flutter/build/app/outputs/flutter-apk/app-release.apk
```

Instálalo en el móvil transfiriendo el fichero (cable, Google Drive, etc.) y abriéndolo. Si el sistema pide confirmación para instalar desde fuentes desconocidas, acéptala.

También puedes instalar directamente con el móvil conectado por USB:

```bash
flutter install
```

#### Scripts de compilación rápida

Si tienes Flutter y ADB disponibles en el PATH, los scripts de la carpeta `scripts/` automatizan el proceso:

| Script | Qué hace |
|---|---|
| `modoA_compilar_apk_nube.bat` | Compila el APK apuntando a `uxilibris-backend.onrender.com` y muestra la ruta del fichero resultante |
| `modoA_actualizar_apk_nube.bat` | Compila el APK y lo instala/actualiza directamente en el dispositivo conectado por USB vía ADB (`adb install -r`), conservando los datos de la app |

#### Primera vez: registrar un usuario

Abre la app, pulsa **Registrarse** y crea tu cuenta. Las tablas se habrán creado automáticamente al arrancar el backend por primera vez.

---

### Opción B — Docker en el navegador

Levanta toda la infraestructura (base de datos, backend y frontend) con un solo comando en local. Solo necesitas **Docker Desktop** instalado.

#### Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows, Mac o Linux)
- Git
- Flutter SDK — **solo para compilar el frontend web** (una vez)

#### Paso 1 — Clonar el repositorio

```bash
git clone https://github.com/UxiaRD/uxilibris_project.git
cd uxilibris_project
```

#### Paso 2 — Compilar el frontend web

> Este paso se hace **una sola vez** en cualquier ordenador que tenga Flutter instalado.

```bash
cd frontend_flutter
flutter pub get
flutter build web --release
cd ..
```

Los ficheros compilados quedan en `frontend_flutter/build/web/`. Docker los servirá automáticamente.

#### Paso 3 — Crear el fichero de contraseñas

Copia el fichero de ejemplo y establece una contraseña para la base de datos:

```bash
cp .env.example .env
```

Edita `.env` y cambia el valor de `MYSQL_ROOT_PASSWORD`.

#### Paso 4 — Levantar todos los servicios

```bash
docker compose up --build
```

La primera vez tarda entre 5 y 10 minutos (descarga imágenes y compila el backend). Las siguientes arrancará en segundos gracias a la caché.

| Servicio | URL |
|---|---|
| **App en el navegador** | http://localhost |
| **API Backend** | http://localhost:8080/api |
| **MySQL** | localhost:3306 |

#### Parar los servicios

```bash
# Parar (los datos de la BD se conservan)
docker compose down

# Parar y borrar también los datos de la BD
docker compose down -v
```

---

### Opción C — APK móvil con backend local

Instala la app en un dispositivo Android que se conecta al backend corriendo en tu ordenador. Útil para demos en móvil sin necesidad de despliegue en la nube.

#### Requisitos

- Un ordenador con Flutter SDK y Docker Desktop instalados.
- El backend corriendo localmente (con Docker según la Opción B, o manualmente según la Opción D).
- El móvil y el ordenador en la **misma red Wi-Fi**.
- Android con **Instalar desde fuentes desconocidas** activado.

#### Paso 1 — Obtener la IP local del ordenador

- **Windows:** ejecuta `ipconfig` → busca "Dirección IPv4"
- **Mac/Linux:** ejecuta `ip addr` o `ifconfig`

#### Paso 2 — Compilar el APK apuntando al backend local

```bash
cd frontend_flutter
flutter pub get
flutter build apk --dart-define=BACKEND_URL=http://192.168.X.X:8080
```

Sustituye `192.168.X.X` por la IP local de tu ordenador.

El APK queda en:
```
frontend_flutter/build/app/outputs/flutter-apk/app-release.apk
```

#### Paso 3 — Instalar en el móvil

Transfiere el fichero al dispositivo y ábrelo para instalarlo, o con el móvil conectado por USB:

```bash
flutter install
```

---

### Opción D — Entorno de desarrollo local

Para desarrollo activo con recarga en caliente (`hot reload`).

#### Requisitos

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.x |
| Java JDK | 21 |
| MySQL Server | 8.0 |
| Android Studio o VS Code | Cualquiera reciente |

#### Paso 1 — Base de datos

Inicia MySQL y crea la base de datos:

```sql
CREATE DATABASE UxiLibrisDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Spring Boot creará las tablas automáticamente al arrancar.

#### Paso 2 — Backend

1. Copia el fichero de configuración de ejemplo:

   ```bash
   cp backend_spring/uxilibris-backend/src/main/resources/application.properties.example \
      backend_spring/uxilibris-backend/src/main/resources/application.properties
   ```

2. Edita `application.properties` y ajusta las credenciales de MySQL si difieren:

   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/UxiLibrisDB?createDatabaseIfNotExists=true
   spring.datasource.username=root
   spring.datasource.password=tu_contraseña
   ```

3. Lanza el servidor:

   ```bash
   cd backend_spring/uxilibris-backend
   ./mvnw spring-boot:run       # Mac / Linux
   mvnw.cmd spring-boot:run     # Windows
   ```

   El backend arranca en `http://localhost:8080`.

> **API de Google Books:** obtén una clave gratuita en [Google Cloud Console](https://console.cloud.google.com) → APIs → Books API → Credenciales y añádela a `application.properties`. Sin clave, la cuota anónima se agota fácilmente.

#### Paso 3 — Frontend Flutter

```bash
cd frontend_flutter
flutter pub get
flutter run               # en dispositivo o emulador conectado
flutter run -d chrome     # en el navegador
```

Para conectar la app móvil al backend local, pasa la IP de tu ordenador:

```bash
flutter run --dart-define=BACKEND_URL=http://192.168.X.X:8080
```

---

## Tests

El proyecto incluye tests unitarios para el frontend (Dart) y el backend (Java), integrados en un pipeline de **GitHub Actions** que se ejecuta automáticamente en cada push.

### Frontend — Tests unitarios de modelos (Dart)

Ubicados en `frontend_flutter/test/modelo/`. No requieren dispositivo ni emulador; prueban la lógica pura de los modelos.

| Fichero | Qué prueba |
|---|---|
| `lectura_test.dart` | `Lectura.fromJson` (formatos string ISO y array), `toJson`, `estaActiva`/`estaCompletada`, `withFechaInicio`/`withFechaFin` (inmutabilidad) |
| `libro_test.dart` | `Libro.fromJson` (campos completos, valores por defecto, estado desconocido, estado en mayúsculas, lecturas anidadas), `toJson` (round-trip), `withEstado` (inmutabilidad y preservación de campos) |
| `libreria_test.dart` | `filtrarPorEstado` (excluye deseos en "todos", estado concreto, vacío), `filtrarPorBusqueda` (case-insensitive, por título/autor/saga, sin duplicados) |

```bash
cd frontend_flutter
flutter test
```

### Backend — Tests unitarios e integración (Java)

Ubicados en `backend_spring/uxilibris-backend/src/test/java/`.

| Fichero | Tipo | Qué prueba |
|---|---|---|
| `service/UsuarioServiceTest.java` | Unitario (Mockito) | `guardar` (nuevo usuario, email duplicado, username duplicado) y `verificar` (credenciales correctas, contraseña incorrecta, usuario inexistente) |
| `repository/UsuarioRepositoryTest.java` | Integración (`@DataJpaTest` + H2) | `findByUsername`, `findByEmail` (existente y no existente), `save` asigna ID |

Los tests de backend usan H2 en memoria (perfil `test`). La configuración está en `src/test/resources/application-test.properties`.

```bash
cd backend_spring/uxilibris-backend
./mvnw test -Dspring.profiles.active=test       # Mac / Linux
mvnw.cmd test -Dspring.profiles.active=test     # Windows
```

### CI — GitHub Actions

El workflow `.github/workflows/ci.yml` se lanza en cualquier push o pull request. Ejecuta en paralelo:

- **Job `backend`**: compila y lanza los tests de Maven con el perfil `test`.
- **Job `flutter`**: instala dependencias, analiza el código con `flutter analyze` y ejecuta `flutter test`.

El estado del pipeline se muestra en el badge al inicio de este README.

---

## Limitaciones de la versión web

Algunas funciones nativas del móvil no están disponibles cuando la app se ejecuta en el navegador:

| Función | Móvil | Web |
|---|---|---|
| Escáner de código de barras ISBN | ✅ | ❌ `mobile_scanner` no soporta web |
| Selección de imagen de galería | ✅ | ⚠️ Selector de ficheros del sistema operativo |
| Almacenamiento seguro de sesión | ✅ Keychain/Keystore | ⚠️ `localStorage` (sin cifrado) |
| Resto de la aplicación | ✅ | ✅ |

---

## Autora

**Uxía RD** — [GitHub](https://github.com/UxiaRD)