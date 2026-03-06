package com.uxia.uxilibris.entity;

import com.uxia.uxilibris.model.EstadoLibro;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "libros")
@Data // Lombok genera getters/setters automáticamente
public class Libro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    private String autorNombre;
    private String sagaNombre;

    private Double puntuacion;
    private Double numLibroSaga;

    @Enumerated(EnumType.STRING)
    private EstadoLibro estado;

    private LocalDate fechaInicio;
    private LocalDate fechaFin;

    private String rutaImagen;

    // Relación con el Almacén de Propiedades Dinámicas
    @OneToMany(mappedBy = "libro", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<PropiedadValor> propiedades;
}
