package com.uxia.uxilibris.service;

import com.uxia.uxilibris.entity.Libro;
import com.uxia.uxilibris.entity.Saga;
import com.uxia.uxilibris.repository.LibroRepository;
import com.uxia.uxilibris.repository.SagaRepository;
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

    // Tras guardar, propaga la relación saga a los campos @Transient para que el JSON de respuesta los incluya
    private void propagarTransientes(Libro libro) {
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

        if (libro.getId() != null) {
            return libroRepository.findById(libro.getId()).map(existente -> {
                existente.setTitulo(libro.getTitulo());
                existente.setAutorNombre(libro.getAutorNombre());
                existente.setSaga(saga);
                existente.setNumLibroSaga(libro.getNumLibroSaga());
                existente.setPuntuacion(libro.getPuntuacion());
                existente.setEstado(libro.getEstado());
                existente.setFechaInicio(libro.getFechaInicio());
                existente.setFechaFin(libro.getFechaFin());
                existente.setRutaImagen(libro.getRutaImagen());
                Libro saved = libroRepository.save(existente);
                propagarTransientes(saved);
                return saved;
            }).orElseGet(() -> {
                libro.setSaga(saga);
                if (libro.getPropiedades() == null) libro.setPropiedades(new java.util.ArrayList<>());
                Libro saved = libroRepository.save(libro);
                propagarTransientes(saved);
                return saved;
            });
        }

        libro.setSaga(saga);
        if (libro.getPropiedades() == null) libro.setPropiedades(new java.util.ArrayList<>());
        Libro saved = libroRepository.save(libro);
        propagarTransientes(saved);
        return saved;
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

    public List<Libro> listarTodosLosLibros() {
        return libroRepository.findAll();
    }

    @Transactional
    public void eliminarLibro(Long id) {
        if (!libroRepository.existsById(id)) {
            throw new jakarta.persistence.EntityNotFoundException("Libro no encontrado con id: " + id);
        }
        libroRepository.deleteById(id);
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