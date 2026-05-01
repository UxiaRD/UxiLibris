package com.uxia.uxilibris.service;

import com.uxia.uxilibris.entity.Libro;
import com.uxia.uxilibris.entity.LecturaLibro;
import com.uxia.uxilibris.entity.Saga;
import com.uxia.uxilibris.entity.Usuario;
import com.uxia.uxilibris.repository.LibroRepository;
import com.uxia.uxilibris.repository.SagaRepository;
import com.uxia.uxilibris.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Servicio central de la aplicación que gestiona toda la lógica de negocio
 * relacionada con los libros.
 *
 * <h3>Responsabilidades principales</h3>
 * <ul>
 *   <li>Creación y actualización de libros, incluyendo la resolución de las
 *       relaciones con {@link Usuario} y {@link Saga} a partir de los campos
 *       transientes del DTO.</li>
 *   <li>Auto-creación de sagas cuando un libro se guarda con un nombre de
 *       saga que aún no existe.</li>
 *   <li>Sincronización del historial de lecturas mediante {@code orphanRemoval}.</li>
 *   <li>Propagación de campos transientes tras cada persistencia para que el
 *       JSON de respuesta incluya los datos de las FK.</li>
 * </ul>
 */
@Service
public class LibroService {

    @Autowired
    private LibroRepository libroRepository;

    @Autowired
    private SagaRepository sagaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    /**
     * Crea la saga indicada si no existe todavía en la base de datos.
     *
     * <p>Se invoca antes de resolver la saga para garantizar que {@link #resolverSaga}
     * siempre encuentre la entidad cuando el nombre es válido.</p>
     *
     * @param sagaNombre nombre de la saga; no hace nada si es {@code null} o vacío
     */
    private void autoCrearSagaSiNecesario(String sagaNombre) {
        if (sagaNombre != null && !sagaNombre.isBlank()
                && !sagaRepository.existsByNombre(sagaNombre.trim())) {
            Saga nueva = new Saga();
            nueva.setNombre(sagaNombre.trim());
            sagaRepository.save(nueva);
        }
    }

    /**
     * Resuelve la entidad {@link Saga} a partir de su nombre.
     *
     * @param sagaNombre nombre de la saga a resolver
     * @return la entidad {@link Saga} correspondiente, o {@code null} si el nombre
     *         es nulo, vacío o no existe en la base de datos
     */
    private Saga resolverSaga(String sagaNombre) {
        if (sagaNombre == null || sagaNombre.isBlank()) return null;
        return sagaRepository.findByNombre(sagaNombre.trim()).orElse(null);
    }

    /**
     * Resuelve la entidad {@link Usuario} a partir del {@code usuarioId} transiente.
     *
     * @param usuarioId identificador del usuario propietario del libro
     * @return la entidad {@link Usuario} correspondiente, o {@code null} si el id
     *         es {@code null} o no existe en la base de datos
     */
    private Usuario resolverUsuario(Long usuarioId) {
        if (usuarioId == null) return null;
        return usuarioRepository.findById(usuarioId).orElse(null);
    }

    /**
     * Propaga las claves foráneas de {@link Saga} y {@link Usuario} a los campos
     * {@code @Transient} del libro, de modo que el JSON de respuesta los incluya
     * sin serializar los objetos completos.
     *
     * <p>Se invoca después de cada operación de guardado, ya que {@code @PostLoad}
     * no se ejecuta al persistir (solo al cargar desde la base de datos).</p>
     *
     * @param libro entidad ya persistida cuyos campos transientes se van a rellenar
     */
    private void propagarTransientes(Libro libro) {
        libro.setUsuarioId(libro.getUsuario() != null ? libro.getUsuario().getId() : null);
        Saga saga = libro.getSaga();
        if (saga != null) {
            libro.setSagaNombre(saga.getNombre());
            libro.setSagaId(saga.getId());
        } else {
            libro.setSagaNombre(null);
            libro.setSagaId(null);
        }
    }

    /**
     * Sugiere el siguiente número de volumen disponible para una saga.
     *
     * <p>Calcula el máximo volumen registrado y suma 1. Si la saga no tiene
     * libros, devuelve {@code 1.0}.</p>
     *
     * @param nombreSaga nombre de la saga para la que se quiere la sugerencia
     * @return número de volumen sugerido
     */
    public Double sugerirSiguienteVolumen(String nombreSaga) {
        List<Double> volumenes = libroRepository.findVolumesBySaga(nombreSaga);
        if (volumenes.isEmpty()) return 1.0;
        return volumenes.stream().mapToDouble(v -> v).max().orElse(0.0) + 1.0;
    }

    /**
     * Crea o actualiza un libro, resolviendo sus relaciones y sincronizando lecturas.
     *
     * <p>Si el libro incluye un {@code id} y existe en la base de datos, se actualiza
     * el registro existente campo a campo. Si el {@code id} no existe o es nulo,
     * se crea un nuevo libro. En ambos casos:</p>
     * <ol>
     *   <li>Se auto-crea la saga si es necesario.</li>
     *   <li>Se resuelven las entidades {@link Saga} y {@link Usuario}.</li>
     *   <li>Se sincroniza el historial de lecturas.</li>
     *   <li>Se propagan los campos transientes en la respuesta.</li>
     * </ol>
     *
     * @param libro datos del libro recibidos del cliente (puede tener {@code id} o no)
     * @return el libro guardado con todos los campos, incluidos los transientes, rellenos
     */
    @Transactional
    public Libro guardarLibro(Libro libro) {
        if (libro.getAutorNombre() != null) {
            libro.setAutorNombre(libro.getAutorNombre().trim());
        }

        String sagaNombre = libro.getSagaNombre();
        autoCrearSagaSiNecesario(sagaNombre);
        Saga saga = resolverSaga(sagaNombre);
        Usuario usuario = resolverUsuario(libro.getUsuarioId());

        if (libro.getId() != null) {
            return libroRepository.findById(libro.getId()).map(existente -> {
                existente.setTitulo(libro.getTitulo());
                existente.setAutorNombre(libro.getAutorNombre());
                existente.setSaga(saga);
                existente.setUsuario(usuario);
                existente.setNumLibroSaga(libro.getNumLibroSaga());
                existente.setPuntuacion(libro.getPuntuacion());
                existente.setEstado(libro.getEstado());
                existente.setRutaImagen(libro.getRutaImagen());
                if (libro.getFavorito() != null) existente.setFavorito(libro.getFavorito());
                if (libro.getFormato() != null) existente.setFormato(libro.getFormato());
                sincronizarLecturas(existente, libro.getLecturas());
                Libro saved = libroRepository.save(existente);
                propagarTransientes(saved);
                return saved;
            }).orElseGet(() -> {
                libro.setSaga(saga);
                libro.setUsuario(usuario);
                if (libro.getPropiedades() == null) libro.setPropiedades(new java.util.ArrayList<>());
                sincronizarLecturas(libro, libro.getLecturas());
                Libro saved = libroRepository.save(libro);
                propagarTransientes(saved);
                return saved;
            });
        }

        libro.setSaga(saga);
        libro.setUsuario(usuario);
        if (libro.getPropiedades() == null) libro.setPropiedades(new java.util.ArrayList<>());
        sincronizarLecturas(libro, libro.getLecturas());
        Libro saved = libroRepository.save(libro);
        propagarTransientes(saved);
        return saved;
    }

    /**
     * Reemplaza el historial de lecturas del libro con las entradas recibidas del cliente.
     *
     * <p>Se nulifican los IDs de las lecturas entrantes para que JPA siempre inserte
     * filas nuevas; el mecanismo {@code orphanRemoval = true} elimina automáticamente
     * las lecturas anteriores al hacer {@code save}.</p>
     *
     * <p><strong>Nota de implementación:</strong> cuando {@code destino} y
     * {@code entradasCliente} comparten la misma instancia de lista (libro nuevo),
     * el {@code clear()} vaciaría también la fuente. Por eso se hace una copia
     * defensiva antes de limpiar.</p>
     *
     * @param destino        entidad cuya lista de lecturas se va a reemplazar
     * @param entradasCliente lecturas recibidas del cliente; puede ser {@code null}
     */
    private void sincronizarLecturas(Libro destino, java.util.List<LecturaLibro> entradasCliente) {
        java.util.List<LecturaLibro> copia = entradasCliente != null
                ? new java.util.ArrayList<>(entradasCliente)
                : new java.util.ArrayList<>();
        destino.getLecturas().clear();
        for (LecturaLibro lec : copia) {
            LecturaLibro nueva = new LecturaLibro();
            nueva.setLibro(destino);
            nueva.setFechaInicio(lec.getFechaInicio());
            nueva.setFechaFin(lec.getFechaFin());
            destino.getLecturas().add(nueva);
        }
    }

    /**
     * Asigna o reasigna una saga a un libro existente sin modificar el resto de sus datos.
     *
     * <p>Si la saga indicada no existe, se crea automáticamente antes de asignarla.</p>
     *
     * @param id              identificador del libro a modificar
     * @param sagaNombreNuevo nombre de la saga a asignar; puede ser {@code null} para desasociar
     * @param numLibroSaga    número de volumen dentro de la saga; puede ser {@code null}
     * @return el libro actualizado con los campos transientes propagados
     * @throws jakarta.persistence.EntityNotFoundException si no existe un libro con ese {@code id}
     */
    @Transactional
    public Libro asignarSaga(Long id, String sagaNombreNuevo, Double numLibroSaga) {
        Libro libro = libroRepository.findById(id)
                .orElseThrow(() -> new jakarta.persistence.EntityNotFoundException("Libro no encontrado: " + id));

        autoCrearSagaSiNecesario(sagaNombreNuevo);
        libro.setSaga(resolverSaga(sagaNombreNuevo));
        libro.setNumLibroSaga(numLibroSaga);

        Libro saved = libroRepository.save(libro);
        propagarTransientes(saved);
        return saved;
    }

    /**
     * Devuelve todos los libros de un usuario concreto.
     *
     * @param usuarioId identificador del usuario propietario
     * @return lista de libros del usuario
     */
    public List<Libro> listarTodosLosLibros(Long usuarioId) {
        return libroRepository.findByUsuarioId(usuarioId);
    }

    /**
     * Elimina un libro por su identificador.
     *
     * @param id identificador del libro a eliminar
     * @throws jakarta.persistence.EntityNotFoundException si no existe un libro con ese {@code id}
     */
    @Transactional
    public void eliminarLibro(Long id) {
        if (!libroRepository.existsById(id)) {
            throw new jakarta.persistence.EntityNotFoundException("Libro no encontrado con id: " + id);
        }
        libroRepository.deleteById(id);
    }

    /**
     * Marca o desmarca un libro como favorito.
     *
     * @param id       identificador del libro
     * @param favorito {@code true} para marcar como favorito; {@code false} para desmarcarlo
     * @return el libro actualizado con los campos transientes propagados
     * @throws jakarta.persistence.EntityNotFoundException si no existe un libro con ese {@code id}
     */
    @Transactional
    public Libro toggleFavorito(Long id, boolean favorito) {
        Libro libro = libroRepository.findById(id)
                .orElseThrow(() -> new jakarta.persistence.EntityNotFoundException("Libro no encontrado: " + id));
        libro.setFavorito(favorito);
        Libro saved = libroRepository.save(libro);
        propagarTransientes(saved);
        return saved;
    }

    /**
     * Devuelve los números de volumen registrados para una saga.
     *
     * @param nombreSaga nombre de la saga
     * @return lista de números de volumen no nulos
     */
    public List<Double> obtenerVolumenesDeSaga(String nombreSaga) {
        return libroRepository.findVolumesBySaga(nombreSaga);
    }

    /**
     * Devuelve los nombres de saga únicos para el autocompletado del formulario.
     *
     * @return lista de nombres de saga sin duplicados, ordenada alfabéticamente
     */
    public List<String> listarSagasExistentes() {
        return libroRepository.findAllUniqueSagas();
    }

    /**
     * Devuelve los nombres de autor únicos para el autocompletado del formulario.
     *
     * @return lista de nombres de autor sin duplicados, ordenada alfabéticamente
     */
    public List<String> listarAutoresExistentes() {
        return libroRepository.findAllUniqueAutores();
    }
}