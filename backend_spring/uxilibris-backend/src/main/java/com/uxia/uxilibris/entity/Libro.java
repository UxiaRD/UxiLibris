package com.uxia.uxilibris.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.uxia.uxilibris.model.EstadoLibro;
import com.uxia.uxilibris.model.FormatoLibro;
import jakarta.persistence.*;
import lombok.Data;
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

    // Relación con Usuario (FK usuario_id en la tabla libros)
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "usuario_id")
    @JsonIgnore
    private Usuario usuario;

    @Transient
    private Long usuarioId;

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

    @Enumerated(EnumType.STRING)
    private FormatoLibro formato = FormatoLibro.FISICO;

    private String rutaImagen;

    private Boolean favorito = false;

    // Relación con el Almacén de Propiedades Dinámicas
    @OneToMany(mappedBy = "libro", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<PropiedadValor> propiedades;

    // Historial de lecturas del libro
    @OneToMany(mappedBy = "libro", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<LecturaLibro> lecturas = new java.util.ArrayList<>();

    // Tras cargar desde DB, propaga los datos de las FK a los campos transientes
    @PostLoad
    private void cargarCamposTransientes() {
        usuarioId = (usuario != null) ? usuario.getId() : null;
        if (saga != null) {
            sagaNombre = saga.getNombre();
            sagaId = saga.getId();
        } else {
            sagaNombre = null;
            sagaId = null;
        }
    }
}