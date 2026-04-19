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

@Service
public class LibroService {

    @Autowired
    private LibroRepository libroRepository;

    @Autowired
    private SagaRepository sagaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    // Si el libro tiene una saga asignada y no existe aún en la tabla sagas, la crea
    private void autoCrearSagaSiNecesario(String sagaNombre) {
        if (sagaNombre != null && !sagaNombre.isBlank()
                && !sagaRepository.existsByNombre(sagaNombre.trim())) {
            Saga nueva = new Saga();
            nueva.setNombre(sagaNombre.trim());
            sagaRepository.save(nueva);
        }
    }

    // Resuelve la entidad Saga a partir de un nombre; devuelve null si el nombre es vacío/nulo
    private Saga resolverSaga(String sagaNombre) {
        if (sagaNombre == null || sagaNombre.isBlank()) return null;
        return sagaRepository.findByNombre(sagaNombre.trim()).orElse(null);
    }

    // Resuelve la entidad Usuario desde el campo transiente usuarioId
    private Usuario resolverUsuario(Long usuarioId) {
        if (usuarioId == null) return null;
        return usuarioRepository.findById(usuarioId).orElse(null);
    }

    // Tras guardar, propaga las FK a los campos @Transient para que el JSON de respuesta los incluya
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

    public Double sugerirSiguienteVolumen(String nombreSaga) {
        List<Double> volumenes = libroRepository.findVolumesBySaga(nombreSaga);
        if (volumenes.isEmpty()) return 1.0;
        return volumenes.stream().mapToDouble(v -> v).max().orElse(0.0) + 1.0;
    }

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

    // Reemplaza la lista de lecturas de la entidad persistida con las que llegan del cliente.
    // Se nulifican los IDs entrantes para que JPA siempre inserte filas nuevas (orphanRemoval
    // eliminará las anteriores automáticamente al hacer save).
    private void sincronizarLecturas(Libro destino, java.util.List<LecturaLibro> entradasCliente) {
        // Copiamos antes de limpiar: cuando destino y entradasCliente comparten
        // la misma lista (libro nuevo), clear() vaciaría también entradasCliente.
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

    public List<Libro> listarTodosLosLibros(Long usuarioId) {
        return libroRepository.findByUsuarioId(usuarioId);
    }

    @Transactional
    public void eliminarLibro(Long id) {
        if (!libroRepository.existsById(id)) {
            throw new jakarta.persistence.EntityNotFoundException("Libro no encontrado con id: " + id);
        }
        libroRepository.deleteById(id);
    }

    @Transactional
    public Libro toggleFavorito(Long id, boolean favorito) {
        Libro libro = libroRepository.findById(id)
                .orElseThrow(() -> new jakarta.persistence.EntityNotFoundException("Libro no encontrado: " + id));
        libro.setFavorito(favorito);
        Libro saved = libroRepository.save(libro);
        propagarTransientes(saved);
        return saved;
    }

    public List<Double> obtenerVolumenesDeSaga(String nombreSaga) {
        return libroRepository.findVolumesBySaga(nombreSaga);
    }

    public List<String> listarSagasExistentes() {
        return libroRepository.findAllUniqueSagas();
    }

    public List<String> listarAutoresExistentes() {
        return libroRepository.findAllUniqueAutores();
    }
}