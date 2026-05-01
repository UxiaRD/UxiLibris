package com.uxia.uxilibris.model;

/**
 * Estado de lectura de un libro en la biblioteca del usuario.
 *
 * <p>Se persiste como cadena de texto ({@code EnumType.STRING}) en la columna
 * {@code estado} de la tabla {@code libros}, lo que permite añadir nuevos
 * valores sin alterar el esquema numérico de la base de datos.</p>
 */
public enum EstadoLibro {

    /** El libro está en la cola de lectura pero aún no se ha empezado. */
    PENDIENTE,

    /** El usuario está leyendo el libro en este momento. */
    LEYENDO,

    /** El libro ha sido leído completamente al menos una vez. */
    LEIDO,

    /** El usuario desea leer el libro en el futuro; aparece en la Lista de Deseos. */
    DESEO
}