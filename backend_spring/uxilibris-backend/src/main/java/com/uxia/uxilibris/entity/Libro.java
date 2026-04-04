package com.uxia.uxilibris.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.uxia.uxilibris.model.EstadoLibro;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "libros")
@Data
public class Libro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    private String autorNombre;

    // Relación con Saga (FK saga_id en la tabla libros)
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "saga_id")
    @JsonIgnore // Evita serializar el objeto Saga completo; se usan los @Transient de abajo
    private Saga saga;

    // Campos transientes: no se persisten en DB, solo viajan en JSON
    @Transient
    private String sagaNombre;

    @Transient
    private Long sagaId;

    private Double numLibroSaga;

    private Double puntuacion;

    @Enumerated(EnumType.STRING)
    private EstadoLibro estado;

    private LocalDate fechaInicio;
    private LocalDate fechaFin;

    private String rutaImagen;

    // Relación con el Almacén de Propiedades Dinámicas
    @OneToMany(mappedBy = "libro", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<PropiedadValor> propiedades;

    // Tras cargar desde DB, propaga los datos de la FK a los campos transientes
    @PostLoad
    private void cargarCamposTransientes() {
        if (saga != null) {
            sagaNombre = saga.getNombre();
            sagaId = saga.getId();
        } else {
            sagaNombre = null;
            sagaId = null;
        }
    }
}