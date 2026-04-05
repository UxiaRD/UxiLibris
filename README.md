# 📚 UxiLibris - Gestor de Lecturas Personal

Una aplicación móvil moderna diseñada para amantes de la lectura que desean llevar un registro detallado de su colección, lecturas en curso y deseos futuros.

## 🚀 Características Actuales

### 🔐 Autenticación
- Registro e inicio de sesión seguros con validaciones de cliente y servidor.
- Restricciones de registro: mayúsculas en contraseña, formato de email y unicidad de usuario.

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

## 🏗️ Tecnologías Utilizadas

| Capa | Tecnología |
|---|---|
| **Frontend** | Flutter & Dart |
| **Backend** | Java 17, Spring Boot, Spring Data JPA |
| **Base de Datos** | MySQL |
| **Comunicación** | API REST (JSON), CORS |
| **APIs externas** | Google Books API (búsqueda por ISBN) |
| **Escaneo** | Mobile Scanner (códigos de barras) |

## 🛠️ Estructura del Proyecto

```text
uxilibris_project/
├── frontend_flutter/               # Aplicación móvil (Flutter)
│   └── lib/
│       ├── controladores/          # Lógica de negocio desacoplada de la UI
│       ├── decoraciones/           # Temas, fondos y estilos globales
│       ├── modelo/                 # Entidades: Libro, Saga, Libreria...
│       ├── servicio/               # ApiService (comunicación HTTP con backend)
│       ├── pantallas/              # Pantallas de la aplicación
│       │   ├── coleccionLibros     # Colección principal con filtros y barra de letras
│       │   ├── coleccionSagas      # Colección de sagas con buscador e indicador de letra
│       │   ├── cardSaga            # Tarjeta de saga (portadas apiladas + título)
│       │   ├── portadasApiladas    # Widget de portadas apiladas reutilizable
│       │   ├── detalleSaga         # Detalle, libros registrados y slots vacíos de una saga
│       │   ├── gestionLibro        # Añadir / editar libro
│       │   ├── gestionSaga         # Añadir / editar saga
│       │   ├── escanerISBN         # Escáner de código de barras
│       │   ├── login / registro    # Autenticación
│       │   └── menuPrincipal       # Navegación principal (tabs)
│       └── utilidades/             # Componentes compartidos
│           └── drawerPrincipal     # Drawer unificado con enum PantallaDrawer
├── backend_spring/                 # Servidor API (Java Spring Boot)
│   └── src/main/java/.../
│       ├── config/                 # CORS (todos los métodos HTTP)
│       ├── controller/             # Endpoints REST: libros, sagas, auth, ISBN
│       ├── service/                # Lógica de negocio y validaciones
│       ├── repository/             # Acceso a datos (JPA)
│       ├── entity/                 # Entidades JPA: Libro, Saga, Usuario...
│       └── dto/                    # IsbnResultDto, LoginResponse
├── database/                       # Esquemas y scripts SQL
├── casos de uso/                   # Diagramas de secuencia UC-01 a UC-09 (draw.io)
└── documentación/                  # Memoria, diagramas ER, de clases y relacional
```

## 🎨 Capturas de Pantalla
*(Próximamente)*

## 📋 Próximas Mejoras (Roadmap)
1. **Barra lateral de letras para Sagas**: misma navegación estática que en libros.
2. **Estadísticas**: Gráficas de hábitos de lectura.
3. **Lista de Deseos**: Marcar libros para leer en el futuro.
4. **Gestión de Perfil**: Edición de datos de usuario.

## 👩‍💻 Autora
**Uxía RD** — [GitHub](https://github.com/UxiaRD)