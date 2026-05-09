package com.uxia.uxilibris.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;

/**
 * Propiedad dinámica con su valor para un libro específico.
 *
 * <p>Estructura plana que almacena en una sola fila el nombre, tipo y valor
 * de una propiedad personalizada. Corresponde 1:1 con el modelo {@code Propiedad}
 * del cliente Flutter.</p>
 *
 * <p>Mapeada a la tabla {@code libro_propiedades_valores}.</p>
 */
@Entity
@Table(name = "libro_propiedades_valores")
@Data
public class PropiedadValor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    /** Nombre descriptivo de la propiedad (p. ej. "ISBN", "Editorial"). */
    private String nombre;

    /** Tipo de dato tal como lo envía el cliente (p. ej. "texto", "numero"). */
    private String tipo;

    /** Indica si la propiedad es optativa. Por defecto {@code true}. */
    private Boolean esOptativa = true;

    /** Valor almacenado como cadena de texto. */
    @Column(name = "valor_texto")
    private String valor;

    @ManyToOne
    @JoinColumn(name = "libro_id")
    @JsonIgnore
    private Libro libro;
}