package com.uxia.uxilibris.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "opciones_propiedades")
@Data
public class OpcionPropiedad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "valor_opcion")
    private String valor;

    // Relación: Muchas opciones pertenecen a una sola definición (Ej: 'Planeta' pertenece a 'Editorial')
    @ManyToOne
    @JoinColumn(name = "propiedad_id")
    private DefinicionPropiedad propiedad;
}
