package com.uxia.uxilibris.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;

/**
 * Valor concreto de una propiedad dinámica para un libro específico.
 *
 * <p>Une {@link Libro} con {@link DefinicionPropiedad}: almacena el valor
 * que el usuario ha introducido para una propiedad concreta de un libro
 * concreto. Todos los tipos de dato ({@link com.uxia.uxilibris.model.TipoDato})
 * se serializan como cadena de texto en la columna {@code valor_texto}.</p>
 *
 * <p>Mapeada a la tabla {@code libro_propiedades_valores}.</p>
 */
@Entity
@Table(name = "libro_propiedades_valores")
@Data
public class PropiedadValor {

    /** Identificador único generado automáticamente por la base de datos. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /**
     * Valor de la propiedad almacenado como texto.
     *
     * <p>El cliente es responsable de interpretar el valor según el
     * {@link com.uxia.uxilibris.model.TipoDato} declarado en {@link #definicion}.</p>
     */
    @Column(name = "valor_texto")
    private String valor;

    /**
     * Libro al que pertenece este valor.
     *
     * <p>No se serializa en JSON ({@code @JsonIgnore}) para evitar la
     * referencia circular {@code Libro → PropiedadValor → Libro}.</p>
     */
    @ManyToOne
    @JoinColumn(name = "libro_id")
    @JsonIgnore
    private Libro libro;

    /**
     * Definición de propiedad que describe el significado y tipo de este valor
     * (p. ej. «ISBN», tipo {@code TEXTO}).
     */
    @ManyToOne
    @JoinColumn(name = "propiedad_id")
    private DefinicionPropiedad definicion;
}