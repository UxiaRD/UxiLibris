# 📚 UxiLibris - Gestor de Lecturas Personal

Una aplicación móvil moderna diseñada para amantes de la lectura que desean llevar un registro detallado de su colección, lecturas en curso y deseos futuros.

## 🚀 Características Actuales
- **Persistencia Real:** Migración completa de JSON local a **MySQL** mediante una API REST en **Java Spring Boot**.
- **Arquitectura Robusta:** Implementación de capas (Controller, Service, Repository) y JPA para la gestión de datos.
- **Personalización Extrema:** Sistema de "Almacén de Propiedades" que permite añadir campos dinámicos a cada libro desde el frontend.
- **Validación Inteligente:** Sugerencia automática de volúmenes de sagas y normalización de autores mediante consultas al backend.
- **UI/UX Avanzada:** Material 3, soporte de temas (claro/oscuro) y validaciones de formularios en tiempo real.

## 🏗️ Tecnologías utilizadas
- **Frontend:** Flutter & Dart (Gestión de estado con Provider).
- **Backend:** Java 17+, Spring Boot, Spring Data JPA.
- **Base de Datos:** MySQL.
- **Comunicación:** API REST (JSON) con soporte para CORS (recursos de origen cruzado).

## 🛠️ Estructura del Proyecto
```text
uxilbris_project/
├── frontend_flutter/       # Aplicación móvil (Flutter)
│   ├── lib/
│   │   ├── modelo/         # Lógica de libros y sagas con mapeo JSON
│   │   ├── servicio/       # ApiService para la comunicación HTTP
│   │   ├── pantallas/      # Fomularios dinámicos y listas
│   │   └── utilidades/     # Componentes compartidos
├── backend_spring/         # Servidor API (Java Spring Boot)
│   ├── src/main/java/...
│   │   ├── controllers/    # Endpoints REST
│   │   ├── services/       # Lógica de negocio y validaciones
│   │   └── entities/       # Mapeo de tablas MySQL (Libro, Propiedad)
├── database/               # Esquemas y scripts SQL
└── documentación           # Memoria y diagramas
```

## 🎨 Capturas de Pantalla
*(Próximamente)*

## 📋 Próximas Mejoras (Roadmap)
1. **Escaner**: Sistema de escaneo de códigos de barras 
2. **Autenticación:** Sistema de registro e inicio de sesión conectado al backend.

## :woman: Autor
**Uxía RD** - [GitHub](https://github.com/UxiaRD)