package com.uxia.uxilibris.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "libro_propiedades_valores")
@Data
public class PropiedadValor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "valor_texto") // Mapea con la columna TEXT del SQL
    private String valor;

    // Relación con el Libro (Muchos valores pertenecen a un Libro)
    @ManyToOne
    @JoinColumn(name = "libro_id")
    private Libro libro;

    // Relación con la Definición (Saber si este valor es del ISBN, Editorial, etc.)
    @ManyToOne
    @JoinColumn(name = "propiedad_id")
    private DefinicionPropiedad definicion;
}
