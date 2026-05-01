package com.uxia.uxilibris.entity;

import com.uxia.uxilibris.model.TipoDato;
import jakarta.persistence.*;
import lombok.Data;

import java.util.List;

/**
 * Definición de una propiedad dinámica que puede asignarse a los libros.
 *
 * <p>El sistema de propiedades dinámicas permite al usuario añadir campos
 * personalizados a sus libros (p. ej. ISBN, editorial, número de páginas)
 * sin modificar el esquema fijo de la entidad {@link Libro}.</p>
 *
 * <p>Cada definición declara un {@link TipoDato} para que el cliente pueda
 * renderizar el control de entrada adecuado. Si el tipo es una lista de
 * opciones predefinidas, estas se almacenan en {@link OpcionPropiedad}.</p>
 *
 * <p>Mapeada a la tabla {@code definicion_propiedades}.</p>
 */
@Entity
@Table(name = "definicion_propiedades")
@Data
public class DefinicionPropiedad {

    /** Identificador único generado automáticamente por la base de datos. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /** Nombre descriptivo de la propiedad (p. ej. {@code "ISBN"}, {@code "Editorial"}). */
    private String nombre;

    /**
     * Tipo de dato que almacena esta propiedad.
     *
     * @see TipoDato
     */
    @Enumerated(EnumType.STRING)
    private TipoDato tipoDato;

    /**
     * Opciones predefinidas disponibles para esta propiedad.
     *
     * <p>Solo relevante cuando la propiedad es de tipo selección. Si la lista
     * está vacía, el usuario introduce el valor libremente.</p>
     */
    @OneToMany(mappedBy = "propiedad", cascade = CascadeType.ALL)
    private List<OpcionPropiedad> opciones;
}