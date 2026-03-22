create database UxiLibrisDB;

-- 1. ENTIDADES CORE (Lo mínimo indispensable)
CREATE TABLE autores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    biografia TEXT
);

CREATE TABLE sagas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado ENUM('Finalizada', 'En proceso') DEFAULT 'En proceso'
);

CREATE TABLE libros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    autor_id INT,
    saga_id INT,
    num_libro_saga DECIMAL(4,1),
    puntuacion DECIMAL(3,1) default 0.0,
    estado_lectura ENUM('Leido', 'Pendiente', 'Leyendo'),
    fecha_inicio DATE,
    fecha_fin DATE,
    ruta_imagen VARCHAR(255),
    FOREIGN KEY (autor_id) REFERENCES autores(id),
    FOREIGN KEY (saga_id) REFERENCES sagas(id)
);

-- 2. SISTEMA DE PROPIEDADES DINÁMICAS (El "Almacén")
-- Aquí se define qué propiedades existen (Ej: 'ISBN', 'Editorial', 'Saga', 'Traductor')
CREATE TABLE definicion_propiedades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL, -- Nombre de la propiedad
    es_optativa BOOLEAN DEFAULT TRUE, -- Mapea a tu bool optativa
    tipo_dato ENUM('TEXTO', 'NUMERO', 'LISTA', 'FECHA') DEFAULT 'TEXTO'
);

-- Para propiedades tipo 'LISTA', aquí se guardan las opciones (Ej: Planeta, Minotauro)
CREATE TABLE opciones_propiedades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    propiedad_id INT,
    valor_opcion VARCHAR(100),
    FOREIGN KEY (propiedad_id) REFERENCES definicion_propiedades(id)
);

-- 3. VALORES REALES (Donde ocurre la magia)
-- Aquí se guarda el 'valor_unico' o los 'valores array' de cada libro
CREATE TABLE libro_propiedades_valores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    libro_id INT,
    propiedad_id INT,
    valor_texto TEXT, -- Aquí se guarda el valor (o un JSON si son varios)
    FOREIGN KEY (libro_id) REFERENCES libros(id),
    FOREIGN KEY (propiedad_id) REFERENCES definicion_propiedades(id)
);

-- 4. USUARIOS de app
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Almacenaremos el hash, no texto plano
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);