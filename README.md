# 📚 UxiLibris - Gestor de Lecturas Personal

Una aplicación móvil moderna diseñada para amantes de la lectura que desean llevar un registro detallado de su colección, lecturas en curso y deseos futuros.

## 🚀 Características Actuales
- **Sistema de Autenticación Completo:** Registro e Inicio de Sesión seguro con validaciones de cliente y servidor.
- **Persistencia Real:** Migración completa de JSON local a **MySQL** mediante una API REST en **Java Spring Boot**.
- **Arquitectura MVC en Flutter:** Separación de responsabilidades mediante la implementación de una carpeta `controladores` para gestionar la lógica de negocio.
- **Seguridad y Validación:** Restricciones de registro (mayúsculas en contraseñas, formato de email y unicidad de usuario).
- **Arquitectura Robusta en Backend:** Implementación de capas (Controller, Service, Repository) y JPA para la gestión de datos.
- **UI/UX Avanzada:** Material 3, soporte de temas y validaciones de formularios con feedback visual (indicadores de carga y SnackBars).

## 🏗️ Tecnologías utilizadas
- **Frontend:** Flutter & Dart (Gestión de estado y arquitectura de Controladores).
- **Backend:** Java 17+, Spring Boot, Spring Data JPA.
- **Base de Datos:** MySQL.
- **Comunicación:** API REST (JSON) con soporte para CORS (recursos de origen cruzado).

## 🛠️ Estructura del Proyecto
```text
uxilbris_project/
├── frontend_flutter/       # Aplicación móvil (Flutter)
│   ├── lib/
│   │   ├── controladores/  # Lógica de Login y Registro (NUEVO)
│   │   ├── modelo/         # Lógica de libros y mapeo JSON
│   │   ├── servicio/       # ApiService (Comunicación HTTP/CORS)
│   │   ├── pantallas/      # Formularios dinámicos y listas
│   │   └── utilidades/     # Componentes compartidos
├── backend_spring/         # Servidor API (Java Spring Boot)
│   ├── src/main/java/...
│   │   ├── config/         # Configuración de CORS (NUEVO)
│   │   ├── controllers/    # Endpoints REST (Auth y Libros)
│   │   ├── services/       # Lógica de negocio y validaciones
│   │   └── entities/       # Mapeo de tablas (Usuario, Libro)
├── database/               # Esquemas y scripts SQL
└── documentación           # Memoria y diagramas
```

## 🎨 Capturas de Pantalla
*(Próximamente)*

## 📋 Próximas Mejoras (Roadmap)
1. **Escaner**: Sistema de escaneo de códigos de barras 
2. **Gestión de Perfil**: Edición de datos de usuario.
3. **Estadísticas**
4. **Lista de deseos**
5. **Vista de Sagas**

## :woman: Autor
**Uxía RD** - [GitHub](https://github.com/UxiaRD)