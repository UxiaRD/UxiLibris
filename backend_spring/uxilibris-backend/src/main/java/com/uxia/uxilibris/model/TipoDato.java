package com.uxia.uxilibris.model;

/**
 * Tipo de dato que puede almacenar una propiedad dinámica de un libro.
 *
 * <p>Cada {@link com.uxia.uxilibris.entity.DefinicionPropiedad} declara su tipo
 * para que el cliente pueda renderizar el campo adecuado (texto libre, número,
 * selector de fecha o interruptor booleano).</p>
 */
public enum TipoDato {

    /** Cadena de texto libre (p. ej. ISBN, editorial, notas). */
    TEXTO,

    /** Valor numérico entero o decimal (p. ej. número de páginas). */
    NUMERICO,

    /** Fecha en formato ISO-8601 (p. ej. fecha de publicación). */
    FECHA,

    /** Valor verdadero/falso (p. ej. «¿Tiene dedicatoria?»). */
    BOOLEANO
}