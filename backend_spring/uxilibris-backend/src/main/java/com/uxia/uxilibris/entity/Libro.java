package com.uxia.uxilibris.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.uxia.uxilibris.model.EstadoLibro;
import com.uxia.uxilibris.model.FormatoLibro;
import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

/**
 * Entidad principal que representa un libro en la biblioteca de un usuario.
 *
 * <h3>Relaciones y campos transientes</h3>
 * <p>Las relaciones {@code @ManyToOne} con {@link Usuario} y {@link Saga} se marcan
 * con {@code @JsonIgnore} para evitar serializar el objeto completo (y ciclos
 * infinitos). En su lugar, los campos {@code @Transient} {@code usuarioId},
 * {@code sagaNombre} y {@code sagaId} viajan en el JSON y se propagan desde
 * las FK al cargar la entidad (véase {@link #cargarCamposTransientes()}).</p>
 *
 * <p>Mapeada a la tabla {@code libros}.</p>
 */
@Entity
@Table(name = "libros")
@Data
public class Libro {

    /** Identificador único generado automáticamente por la base de datos. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Título del libro. Campo obligatorio. */
    @Column(nullable = false)
    private String titulo;

    /** Nombre del autor principal. Se normaliza con {@code trim()} al guardar. */
    private String autorNombre;

    /**
     * Usuario propietario del libro.
     *
     * <p>No se serializa en JSON; el cliente recibe el id a través de {@link #usuarioId}.</p>
     */
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "usuario_id")
    @JsonIgnore
    private Usuario usuario;

    /**
     * Id del usuario propietario, propagado desde {@link #usuario} tras la carga.
     *
     * <p>No se persiste en base de datos ({@code @Transient}). El cliente
     * lo envía al crear o actualizar un libro.</p>
     */
    @Transient
    private Long usuarioId;

    /**
     * Saga a la que pertenece el libro.
     *
     * <p>No se serializa en JSON; el cliente recibe el nombre e id a través
     * de {@link #sagaNombre} y {@link #sagaId}.</p>
     */
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "saga_id")
    @JsonIgnore
    private Saga saga;

    /**
     * Nombre de la saga, propagado desde {@link #saga} tras la carga.
     *
     * <p>No se persiste ({@code @Transient}). El servicio lo usa para
     * resolver o crear la saga antes de guardar.</p>
     */
    @Transient
    private String sagaNombre;

    /**
     * Id de la saga, propagado desde {@link #saga} tras la carga.
     *
     * <p>No se persiste ({@code @Transient}).</p>
     */
    @Transient
    private Long sagaId;

    /** Número de volumen dentro de la saga (puede ser decimal, p. ej. 0.5 para una precuela). */
    private Double numLibroSaga;

    /** Puntuación del libro de 0 a 5 estrellas. {@code 0} indica sin puntuar. */
    private Double puntuacion;

    /**
     * Estado actual de lectura del libro.
     *
     * @see EstadoLibro
     */
    @Enumerated(EnumType.STRING)
    private EstadoLibro estado;

    /**
     * Formato físico del ejemplar (físico o digital).
     *
     * <p>El valor por defecto es {@link FormatoLibro#FISICO}.</p>
     */
    @Enumerated(EnumType.STRING)
    private FormatoLibro formato = FormatoLibro.FISICO;

    /** Ruta de la portada: URL de Google Books, ruta local del dispositivo o asset de la app. */
    private String rutaImagen;

    /** Ruta de la imagen de fondo de la pantalla de detalle. Nulo = usar la portada. */
    private String rutaFondo;

    /**
     * Indica si el usuario ha marcado el libro como favorito.
     *
     * <p>Se muestra con estrella amarilla en la tarjeta y aparece en la
     * sección «Mis favoritos» de estadísticas. Por defecto es {@code false}.</p>
     */
    private Boolean favorito = false;

    /**
     * Propiedades dinámicas asignadas al libro (p. ej. ISBN, editorial).
     *
     * <p>Relación {@code OneToMany} con eliminación en cascada: al borrar
     * el libro se eliminan automáticamente todos sus valores de propiedad.</p>
     */
    @OneToMany(mappedBy = "libro", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<PropiedadValor> propiedades = new java.util.ArrayList<>();

    /**
     * Historial de lecturas del libro (puede haber varias si el usuario lo releyó).
     *
     * <p>Relación {@code OneToMany} con eliminación en cascada. La sincronización
     * del historial se gestiona en
     * {@link com.uxia.uxilibris.service.LibroService#guardarLibro}.</p>
     */
    @OneToMany(mappedBy = "libro", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<LecturaLibro> lecturas = new java.util.ArrayList<>();

    /**
     * Propaga los datos de las claves foráneas a los campos {@code @Transient}
     * justo después de que JPA cargue la entidad desde la base de datos.
     *
     * <p>Esto permite que el JSON de respuesta incluya {@code usuarioId},
     * {@code sagaNombre} y {@code sagaId} sin serializar los objetos completos,
     * evitando así referencias circulares.</p>
     */
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