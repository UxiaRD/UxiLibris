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
- Pull-to-refresh para actualizar la colección.
- **Portadas** desde URL (Google Books), imagen local (galería) o imagen por defecto.

### 📚 Gestión de Sagas
- Pantalla de colección de sagas con portadas apiladas de los volúmenes registrados.
  - Si la saga tiene total de libros definido, se muestran huecos para los volúmenes no registrados.
- Buscador por nombre de saga en tiempo real.
- Crear, editar y eliminar sagas.
- Pantalla de detalle por saga con la lista de libros ordenada por volumen.
- Asignar libros existentes a una saga desde el diálogo de la pantalla de detalle.
- Eliminar libros de una saga mediante pulsación larga.
- **Auto-creación de saga**: al guardar un libro con saga asignada, la saga se crea automáticamente si no existe.
- Drawer de navegación para volver a la colección de libros.

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
│       │   ├── coleccionLibros     # Colección principal con filtros
│       │   ├── coleccionSagas      # Colección de sagas con buscador
│       │   ├── detalleSaga         # Detalle y libros de una saga
│       │   ├── gestionLibro        # Añadir / editar libro
│       │   ├── gestionSaga         # Añadir / editar saga
│       │   ├── escanerISBN         # Escáner de código de barras
│       │   ├── login / registro    # Autenticación
│       │   └── menuPrincipal       # Navegación principal (tabs)
│       └── utilidades/             # Componentes compartidos (drawer, dialogs...)
├── backend_spring/                 # Servidor API (Java Spring Boot)
│   └── src/main/java/.../
│       ├── config/                 # CORS (todos los métodos HTTP)
│       ├── controller/             # Endpoints REST: libros, sagas, auth, ISBN
│       ├── service/                # Lógica de negocio y validaciones
│       ├── repository/             # Acceso a datos (JPA)
│       ├── entity/                 # Entidades JPA: Libro, Saga, Usuario...
│       └── dto/                    # IsbnResultDto (respuesta de Google Books)
├── database/                       # Esquemas y scripts SQL
└── documentación/                  # Memoria y diagramas
```

## 🎨 Capturas de Pantalla
*(Próximamente)*

## 📋 Próximas Mejoras (Roadmap)
1. **Gestión de Perfil**: Edición de datos de usuario.
2. **Estadísticas**: Gráficas de hábitos de lectura.
3. **Lista de Deseos**: Marcar libros para leer en el futuro.

## 👩‍💻 Autora
**Uxía RD** — [GitHub](https://github.com/UxiaRD)