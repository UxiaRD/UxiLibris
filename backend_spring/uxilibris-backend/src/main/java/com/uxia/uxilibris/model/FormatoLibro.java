package com.uxia.uxilibris.model;

/**
 * Formato físico en el que el usuario posee un libro.
 *
 * <p>Se persiste como cadena de texto ({@code EnumType.STRING}).
 * El valor por defecto al crear un libro es {@link #FISICO}.</p>
 */
public enum FormatoLibro {

    /** Ejemplar en papel. Se muestra sin borde especial en la tarjeta. */
    FISICO,

    /** Ejemplar digital (ebook, audiolibro, etc.). Se muestra con borde morado en la tarjeta. */
    DIGITAL
}