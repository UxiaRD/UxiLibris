# UxiLibris — Gestor de Lecturas Personal

Una aplicación para amantes de la lectura que permite llevar un registro detallado de su colección, lecturas en curso, lista de deseos y hábitos de lectura con estadísticas visuales.

<p align="center">
<img src="frontend_flutter/assets/images/icono.png" alt="Icono UxiLibris" width="150">
</p>

## Índice

1. [Características](#características)
2. [Tecnologías utilizadas](#tecnologías-utilizadas)
3. [Estructura del proyecto](#estructura-del-proyecto)
4. [Instalación y ejecución](#instalación-y-ejecución)
   - [Opción A — Docker en el navegador (recomendado)](#opción-a--docker-en-el-navegador-recomendado)
   - [Opción B — App móvil Android (APK)](#opción-b--app-móvil-android-apk)
   - [Opción C — Entorno de desarrollo local](#opción-c--entorno-de-desarrollo-local)
5. [Limitaciones de la versión web](#limitaciones-de-la-versión-web)
6. [Autora](#autora)

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
| **Base de datos** | MySQL 8.0 |
| **Comunicación** | API REST (JSON), CORS global |
| **APIs externas** | Google Books API (ISBN y búsqueda por texto) |
| **Escaneo** | mobile_scanner (códigos de barras) |
| **Gráficas** | fl_chart |
| **Sesión segura** | flutter_secure_storage |
| **Estado** | provider |
| **Contenedores** | Docker, Docker Compose, nginx |

---

## Estructura del proyecto

```text
uxilibris_project/
├── docker-compose.yml              # Orquesta backend + BD + frontend web
├── nginx.conf                      # Configuración del servidor web (frontend)
├── Vagrantfile                     # Alternativa: VM Ubuntu con Docker preinstalado
│
├── frontend_flutter/               # App Flutter (móvil y web)
│   └── lib/
│       ├── controladores/          # Lógica de negocio desacoplada de la UI
│       ├── decoraciones/           # Temas, fondos y estilos globales
│       ├── modelo/                 # Entidades: Libro, Saga, Libreria…
│       ├── servicio/               # ApiService y SessionManager
│       ├── pantallas/              # Pantallas de la aplicación
│       │   ├── coleccionLibros/    # Grid principal con filtros y barra de letras
│       │   ├── coleccionSagas/     # Grid de sagas con buscador
│       │   ├── widgetsColeccionLibros/ # CardLibro y GridColeccion
│       │   ├── detalleSaga         # Volúmenes de una saga y slots vacíos
│       │   ├── estadisticas        # Gráficas y favoritos
│       │   ├── gestionLibro        # Añadir / editar libro
│       │   ├── gestionSaga         # Añadir / editar saga
│       │   ├── escanerISBN         # Escáner de código de barras
│       │   ├── busquedaLibros      # Búsqueda por texto en Google Books
│       │   ├── listaDeseos         # Libros marcados como deseo
│       │   ├── login / registro    # Autenticación
│       │   └── seleccionMetodoCarga # Selector de método de carga
│       └── utilidades/             # Componentes compartidos (drawer, diálogos…)
│
├── backend_spring/                 # API REST (Java Spring Boot)
│   └── uxilibris-backend/
│       ├── Dockerfile              # Imagen Docker del backend
│       └── src/main/java/.../
│           ├── config/             # CORS
│           ├── controller/         # Endpoints: libros, sagas, auth, ISBN
│           ├── service/            # Lógica de negocio
│           ├── repository/         # Acceso a datos (JPA)
│           ├── entity/             # Entidades JPA: Libro, Saga, Usuario…
│           └── dto/                # Objetos de transferencia de datos
│
├── casos de uso/                   # Diagramas de secuencia UC-01…UC-09
└── documentación/                  # Memoria, diagramas ER, clases y relacional
```

---

## Instalación y ejecución

Hay tres formas de ejecutar UxiLibris según el caso de uso. Escoge la que mejor se adapte:

| | Opción A — Docker | Opción B — APK | Opción C — Desarrollo |
|---|---|---|---|
| **Uso** | Demo / presentación en navegador | Demo en móvil Android | Desarrollo activo |
| **Instalar** | Docker Desktop | Android (sideload APK) | Flutter, Java 21, MySQL |
| **Tiempo de setup** | ~5 min | ~2 min | ~20 min |

---

### Opción A — Docker en el navegador (recomendado)

Levanta toda la infraestructura (base de datos, backend y frontend) con un solo comando. Solo necesitas **Docker Desktop** instalado en el ordenador.

#### Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows, Mac o Linux)
- Git
- Flutter SDK — **solo para compilar el frontend web**

#### Paso 1 — Clonar el repositorio

```bash
git clone https://github.com/UxiaRD/uxilibris_project.git
cd uxilibris_project
```

#### Paso 2 — Compilar el frontend web

> Este paso se hace **una sola vez** en cualquier ordenador que tenga Flutter instalado. El resultado (la carpeta `build/web/`) se lleva junto con el proyecto.

```bash
cd frontend_flutter
flutter pub get
flutter build web --release
cd ..
```

Los ficheros compilados quedan en `frontend_flutter/build/web/`. Docker los servirá automáticamente.

#### Paso 3 — Levantar todos los servicios

```bash
docker compose up --build
```

La primera vez tarda entre 5 y 10 minutos (descarga las imágenes de MySQL y Maven, compila el backend). Las siguientes arrancará en unos segundos porque las capas quedan en caché.

Verás los siguientes servicios activos:

| Servicio | URL |
|---|---|
| **App en el navegador** | http://localhost |
| **API Backend** | http://localhost:8080/api |
| **MySQL** | localhost:3306 |

#### Paso 4 — Primera vez: registrar un usuario

La base de datos arranca vacía. Abre http://localhost en el navegador, pulsa **Registrarse** y crea tu cuenta. A partir de ahí puedes añadir libros con normalidad.

#### Parar los servicios

```bash
# Parar (los datos de la BD se conservan)
docker compose down

# Parar y borrar también los datos de la BD
docker compose down -v
```

---

### Opción B — App móvil Android (APK)

Instala la app directamente en un dispositivo Android sin necesidad de compilar ni tener Flutter en el ordenador de destino.

#### Requisitos

- Un ordenador con Flutter SDK instalado (para compilar el APK una sola vez).
- Un dispositivo Android con **Instalar desde fuentes desconocidas** activado.
- El backend debe estar en ejecución (con Docker según la Opción A, o manualmente según la Opción C).

#### Paso 1 — Configurar la IP del backend

Abre `frontend_flutter/lib/servicio/ApiService.dart` y ajusta la IP en la línea 19:

```dart
static String get _host {
  if (kIsWeb) return 'localhost';
  return '192.168.X.X';   // ← IP local del ordenador donde corre el backend
  // return '10.0.2.2';   // ← usa esta línea si usas el emulador Android
}
```

Para conocer la IP local del ordenador con el backend:
- **Windows**: ejecuta `ipconfig` → busca "Dirección IPv4"
- **Mac/Linux**: ejecuta `ip addr` o `ifconfig`

El móvil y el ordenador deben estar en la **misma red Wi-Fi**.

#### Paso 2 — Compilar el APK

```bash
cd frontend_flutter
flutter pub get
flutter build apk --release
```

El APK queda en:
```
frontend_flutter/build/app/outputs/flutter-apk/app-release.apk
```

#### Paso 3 — Instalar en el móvil

Transfiere el fichero `app-release.apk` al dispositivo (por cable, correo, Google Drive, etc.) y ábrelo para instalarlo. Si el sistema pide confirmación para instalar desde fuentes desconocidas, acéptala.

---

### Opción C — Entorno de desarrollo local

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

Spring Boot creará las tablas automáticamente al arrancar gracias a `spring.jpa.hibernate.ddl-auto=update`.

#### Paso 2 — Backend

1. Abre `backend_spring/uxilibris-backend/src/main/resources/application.properties` y ajusta las credenciales si difieren de las predeterminadas:

   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/UxiLibrisDB?createDatabaseIfNotExists=true
   spring.datasource.username=root
   spring.datasource.password=abc123.
   ```

2. Lanza el servidor desde tu IDE o con Maven:

   ```bash
   cd backend_spring/uxilibris-backend
   ./mvnw spring-boot:run       # Mac / Linux
   mvnw.cmd spring-boot:run     # Windows
   ```

   El backend arranca en `http://localhost:8080`.

> **API de Google Books:** la clave incluida en `application.properties` es de uso personal. Para evitar agotar la cuota, obtén la tuya gratis en [Google Cloud Console](https://console.cloud.google.com) → APIs → Books API → Credenciales.

#### Paso 3 — Frontend Flutter

1. Configura la IP del backend en `frontend_flutter/lib/servicio/ApiService.dart` (ver [Paso 1 de la Opción B](#paso-1--configurar-la-ip-del-backend)).

2. Instala dependencias y lanza la app:

   ```bash
   cd frontend_flutter
   flutter pub get
   flutter run               # en dispositivo o emulador conectado
   flutter run -d chrome     # en el navegador
   ```

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