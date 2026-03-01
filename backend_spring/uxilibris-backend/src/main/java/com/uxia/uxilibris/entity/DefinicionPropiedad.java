package com.uxia.uxilibris.entity;

import com.uxia.uxilibris.model.TipoDato;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "definicion_propiedades")
@Data
public class DefinicionPropiedad {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String nombre; // Ej: "ISBN"

    @Enumerated(EnumType.STRING)
    private TipoDato tipoDato; // TEXTO, NUMERO, etc.

    @OneToMany(mappedBy = "propiedad", cascade = CascadeType.ALL)
    private List<OpcionPropiedad> opciones;
}
