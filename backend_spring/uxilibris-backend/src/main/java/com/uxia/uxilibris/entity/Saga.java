package com.uxia.uxilibris.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * Entidad que representa una saga o serie literaria.
 *
 * <p>Los libros se asocian a una saga mediante la relación {@code ManyToOne}
 * en {@link Libro}. Una saga puede crearse de forma explícita desde el formulario
 * o de forma automática al guardar un libro con saga asignada
 * (véase {@link com.uxia.uxilibris.service.LibroService#guardarLibro}).</p>
 *
 * <p>Mapeada a la tabla {@code sagas}.</p>
 */
@Entity
@Table(name = "sagas")
@Data
public class Saga {

    /** Identificador único generado automáticamente por la base de datos. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Nombre de la saga, único en el sistema.
     *
     * <p>Se normaliza con {@code trim()} antes de persistirse para evitar
     * duplicados por espacios accidentales.</p>
     */
    @Column(nullable = false, unique = true)
    private String nombre;

    /**
     * Número total de libros que componen la saga según el autor.
     *
     * <p>Si es {@code null} o {@code 0}, la pantalla de detalle de la saga
     * no muestra huecos para volúmenes pendientes.</p>
     */
    private Integer totalLibros;

    /**
     * Indica si el usuario ha abandonado esta saga.
     *
     * <p>Las sagas abandonadas se muestran con fondo rojo claro en la lista
     * y sus libros pendientes aparecen tachados en la pantalla de detalle.</p>
     */
    @Column(nullable = false, columnDefinition = "boolean DEFAULT false")
    private boolean abandonada = false;
}