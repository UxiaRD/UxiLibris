package com.uxia.uxilibris.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * Opción predefinida para una propiedad dinámica de tipo selección.
 *
 * <p>Permite restringir los valores válidos de una {@link DefinicionPropiedad}
 * a un conjunto cerrado (p. ej. lista de editoriales conocidas).</p>
 *
 * <p>Mapeada a la tabla {@code opciones_propiedades}.</p>
 */
@Entity
@Table(name = "opciones_propiedades")
@Data
public class OpcionPropiedad {

    /** Identificador único generado automáticamente por la base de datos. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /** Valor de la opción que se muestra al usuario (p. ej. {@code "Planeta"}). */
    @Column(name = "valor_opcion")
    private String valor;

    /**
     * Definición de propiedad a la que pertenece esta opción.
     *
     * <p>Muchas opciones pueden pertenecer a una misma definición
     * (p. ej. varias editoriales para la propiedad «Editorial»).</p>
     */
    @ManyToOne
    @JoinColumn(name = "propiedad_id")
    private DefinicionPropiedad propiedad;
}