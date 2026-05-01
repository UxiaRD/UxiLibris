package com.uxia.uxilibris.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

/**
 * Entidad que registra una sesión de lectura de un libro.
 *
 * <p>Un libro puede tener múltiples lecturas si el usuario lo relee.
 * Una lectura con {@link #fechaFin} no nula se considera <em>completada</em>
 * y es la que se tiene en cuenta para las estadísticas.</p>
 *
 * <p>Mapeada a la tabla {@code lecturas}.</p>
 */
@Entity
@Table(name = "lecturas")
@Data
public class LecturaLibro {

    /** Identificador único generado automáticamente por la base de datos. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Libro al que pertenece esta lectura.
     *
     * <p>No se serializa en JSON ({@code @JsonIgnore}) para evitar la
     * referencia circular {@code Libro → LecturaLibro → Libro}.</p>
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "libro_id", nullable = false)
    @JsonIgnore
    private Libro libro;

    /** Fecha en la que el usuario comenzó esta lectura. Puede ser {@code null} si no se registró. */
    private LocalDate fechaInicio;

    /**
     * Fecha en la que el usuario terminó esta lectura.
     *
     * <p>Si es {@code null}, la lectura está en curso. Las estadísticas
     * solo contabilizan lecturas con {@code fechaFin} definida.</p>
     */
    private LocalDate fechaFin;
}