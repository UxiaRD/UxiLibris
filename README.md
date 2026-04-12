# 📚 UxiLibris - Gestor de Lecturas Personal

Una aplicación móvil moderna diseñada para amantes de la lectura que desean llevar un registro detallado de su colección, lecturas en curso y deseos futuros.

## 🚀 Características Actuales

### 🔐 Autenticación
- Registro e inicio de sesión seguros con validaciones de cliente y servidor.
- Restricciones de registro: mayúsculas en contraseña, formato de email y unicidad de usuario.
- **Sesión persistente**: las credenciales se almacenan de forma segura en el dispositivo (keychain/keystore) y no es necesario volver a introducirlas al abrir la app.

### 📖 Colección de Libros
- Añadir libros **manualmente** o mediante **escáner de código de barras ISBN**.
  - El escáner consulta la **API de Google Books** y rellena automáticamente título, autor, portada y datos de saga.
  - Detección de duplicados: aviso si el libro ya está registrado al escanear el mismo ISBN.
- Editar y eliminar libros de la biblioteca.
- Filtrado por estado de lectura: *Todos*, *Leyendo*, *Pendientes*, *Leídos*.
- Barra de búsqueda por título, autor o saga.
- **Ordenación alfabética** automática por título en todas las vistas.
- **Barra lateral de letras** estática: siempre visible a la derecha, muestra las iniciales presentes en la lista actual. Al pulsar una letra, el grid salta directamente a esa sección; la letra activa se resalta mientras se hace scroll.
- Pull-to-refresh para actualizar la colección.
- **Portadas** desde URL (Google Books), imagen local (galería) o imagen por defecto.

### 📚 Gestión de Sagas
- Pantalla de colección de sagas con portadas apiladas de los volúmenes registrados.
- Las sagas **completadas** (todos los libros en estado *leído*) se muestran con fondo en morado claro.
- **Indicador de letra flotante** al hacer scroll: aparece centrado en pantalla con la inicial de la saga visible y desaparece tras 1,2 segundos de inactividad.
- Buscador por nombre de saga en tiempo real.
- Crear, editar y eliminar sagas.
- Pantalla de detalle por saga con la lista de libros ordenada por volumen.
  - Si la saga tiene el total de libros definido, se muestran **tarjetas en gris** para los volúmenes aún no registrados. Al pulsar una, se abre el formulario de añadir libro con la saga y el volumen prerellenados.
- Asignar libros existentes a una saga desde el diálogo de la pantalla de detalle.
- Eliminar libros de una saga mediante pulsación larga.
- **Auto-creación de saga**: al guardar un libro con saga asignada, la saga se crea automáticamente si no existe.

### 📊 Estadísticas
- Tarjetas de resumen: libros leídos este año, total leídos, nota media y autor favorito.
- Gráfica de barras de libros leídos por mes con selector de año.
- Gráfica de líneas comparativa entre años (visible cuando hay datos de más de un año).
- Ranking de los 5 autores más leídos con barra de progreso relativa.
- Ranking de los 5 libros mejor puntuados con visualización de estrellas.

### ⚙️ Ajustes
- **Edición de datos de cuenta**: cambio de nombre de usuario, correo y contraseña con verificación de la contraseña actual.
- Cambio entre **tema claro y oscuro**.
- Recarga manual de la biblioteca desde el servidor.
- Cierre de sesión con confirmación.

### 🧭 Navegación
- **Drawer principal unificado** (`DrawerPrincipal`) compartido por todas las pantallas.
  - Muestra siempre las cuatro opciones de navegación: Libros, Sagas, Estadísticas y Lista de Deseos.
  - La pantalla activa se resalta con `selected: true`; las demás navegan directamente a su destino.
  - Controlado por el enum `PantallaDrawer` para facilitar la incorporación de nuevas pantallas.

### 🎨 UI/UX
- Material 3 con soporte de tema claro/oscuro.
- Fondos personalizados con filtro adaptativo según el tema.
- AppBar transparente con extensión detrás del contenido.
- Feedback visual mediante indicadores de carga y SnackBars.
- Campos personalizados dinámicos por libro.
- Formulario de libro con autocompletado de autores y sagas existentes.
- Sugerencia automática del siguiente volumen de saga al añadir un libro.

## 📋 Próximas Mejoras (Roadmap)

- **Lista de Deseos**: marcar libros que se quieren leer en el futuro antes de registrarlos en la colección principal.
- **Búsqueda por título o autor en Google Books**: complementar el escáner ISBN con una búsqueda manual de texto libre contra la API de Google Books para facilitar el registro de libros sin código de barras.
- **Formato del libro (físico / digital)**: añadir un campo al formulario para distinguir si el ejemplar es físico, ebook o audiolibro.

## 🏗️ Tecnologías Utilizadas

| Capa | Tecnología |
|---|---|
| **Frontend** | Flutter & Dart |
| **Backend** | Java 17, Spring Boot, Spring Data JPA |
| **Base de Datos** | MySQL |
| **Comunicación** | API REST (JSON), CORS |
| **APIs externas** | Google Books API (búsqueda por ISBN) |
| **Escaneo** | mobile_scanner (códigos de barras) |
| **Gráficas** | fl_chart |
| **Sesión segura** | flutter_secure_storage |
| **Estado del tema** | provider |

## 🛠️ Estructura del Proyecto

```text
uxilibris_project/
├── frontend_flutter/               # Aplicación móvil (Flutter)
│   └── lib/
│       ├── controladores/          # Lógica de negocio desacoplada de la UI
│       ├── decoraciones/           # Temas, fondos y estilos globales
│       ├── modelo/                 # Entidades: Libro, Saga, Libreria...
│       ├── servicio/               # ApiService y SessionManager
│       ├── pantallas/              # Pantallas de la aplicación
│       │   ├── coleccionLibros     # Colección principal con filtros y barra de letras
│       │   ├── coleccionSagas      # Colección de sagas con buscador e indicador de letra
│       │   ├── cardSaga            # Tarjeta de saga (portadas apiladas + título)
│       │   ├── portadasApiladas    # Widget de portadas apiladas reutilizable
│       │   ├── detalleSaga         # Detalle, libros registrados y slots vacíos de una saga
│       │   ├── estadisticas        # Gráficas y resumen de hábitos de lectura
│       │   ├── gestionLibro        # Añadir / editar libro
│       │   ├── gestionSaga         # Añadir / editar saga
│       │   ├── escanerISBN         # Escáner de código de barras
│       │   ├── login / registro    # Autenticación
│       │   └── menuPrincipal       # Navegación principal (tabs)
│       └── utilidades/             # Componentes compartidos
│           ├── ajustes             # Pantalla de ajustes
│           ├── dialogoEditarCuenta # Diálogo de edición de datos de usuario
│           └── drawerPrincipal     # Drawer unificado con enum PantallaDrawer
├── backend_spring/                 # Servidor API (Java Spring Boot)
│   └── src/main/java/.../
│       ├── config/                 # CORS (todos los métodos HTTP)
│       ├── controller/             # Endpoints REST: libros, sagas, auth, ISBN
│       ├── service/                # Lógica de negocio y validaciones
│       ├── repository/             # Acceso a datos (JPA)
│       ├── entity/                 # Entidades JPA: Libro, Saga, Usuario...
│       └── dto/                    # IsbnResultDto, LoginResponse, ActualizarUsuarioRequest
├── casos de uso/                   # Diagramas de secuencia UC-01 a UC-09 (draw.io)
└── documentación/                  # Memoria, diagramas ER, de clases y relacional
```

## ⚙️ Preparación del entorno

### Requisitos previos

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.x |
| Java JDK | 17 |
| MySQL Server | 8.0 |
| Android Studio / VS Code | Cualquiera reciente |

### 1. Base de datos

1. Inicia MySQL y crea la base de datos:
   ```sql
   CREATE DATABASE uxilibris;
   ```
2. Spring Boot creará las tablas automáticamente al arrancar gracias a `spring.jpa.hibernate.ddl-auto`.

### 2. Backend (Spring Boot)

1. Abre `backend_spring/src/main/resources/application.properties` y configura:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/uxilibris
   spring.datasource.username=TU_USUARIO
   spring.datasource.password=TU_CONTRASEÑA
   google.books.api.key=TU_API_KEY   # opcional, aumenta la cuota diaria
   ```
2. Lanza el servidor desde IntelliJ IDEA o con:
   ```bash
   ./mvnw spring-boot:run
   ```
   El servidor arranca en `http://localhost:8080`.

> **Nota:** Sin `google.books.api.key` la búsqueda por ISBN sigue funcionando pero está limitada a 1 000 peticiones diarias por IP.

### 3. Frontend (Flutter)

1. Instala las dependencias:
   ```bash
   cd frontend_flutter
   flutter pub get
   ```
2. Asegúrate de que el dispositivo o emulador esté conectado y lanza la app:
   ```bash
   flutter run
   ```

> **Nota:** La URL del backend está definida en `frontend_flutter/lib/servicio/ApiService.dart`. Si el backend no corre en `localhost:8080` (por ejemplo, en un dispositivo físico), actualiza `baseUrl` con la IP de tu máquina en la red local.

## 🎨 Capturas de Pantalla
*(Próximamente)*

## 👩‍💻 Autora
**Uxía RD** — [GitHub](https://github.com/UxiaRD)