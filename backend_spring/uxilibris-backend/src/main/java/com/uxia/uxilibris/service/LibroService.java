package com.uxia.uxilibris.service;

import com.uxia.uxilibris.entity.Libro;
import com.uxia.uxilibris.repository.LibroRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class LibroService {
    @Autowired
    private LibroRepository libroRepository;

    // Obtiene sugerencia de siguiente volumen
    public Double sugerirSiguienteVolumen(String nombreSaga) {
        List<Double> volumenes = libroRepository.findVolumesBySaga(nombreSaga);
        if (volumenes.isEmpty()) {
            return 1.0; // Si la saga es nueva, empieza por el 1
        }
        // Busca el máximo y suma 1
        return volumenes.stream().mapToDouble(v -> v).max().orElse(0.0) + 1.0;
    }

    // Método para guardar el libro con sus propiedades dinámicas
    @Transactional
    public Libro guardarLibro(Libro libro) {
        // Aquí podríamos añadir lógica de "Limpieza" de nombres (Trimming)
        if (libro.getAutorNombre() != null) {
            libro.setAutorNombre(libro.getAutorNombre().trim());
        }
        return libroRepository.save(libro);
    }

    public List<Libro> listarTodosLosLibros(){
        return libroRepository.findAll();
    }

    @Transactional
    public void eliminarLibro(Long id) {
        if (!libroRepository.existsById(id)) {
            throw new jakarta.persistence.EntityNotFoundException(
                    "Libro no encontrado con id: " + id
            );
        }
        libroRepository.deleteById(id);
    }

    public List<Double> obtenerVolumenesDeSaga(String nombreSaga) {
        return libroRepository.findVolumesBySaga(nombreSaga);
    }

    // Métodos para los buscadores de Flutter
    public List<String> listarSagasExistentes() {
        return libroRepository.findAllUniqueSagas();
    }

    public List<String> listarAutoresExistentes() {
        return libroRepository.findAllUniqueAutores();
    }
}
