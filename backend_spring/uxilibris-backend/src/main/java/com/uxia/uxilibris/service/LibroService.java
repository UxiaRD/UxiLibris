package com.uxia.uxilibris.service;

import com.uxia.uxilibris.entity.Libro;
import com.uxia.uxilibris.repository.LibroRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public class LibroService {
    @Autowired
    private LibroRepository libroRepository;

    // Obtiene sugerencia de siguiente volumen
    public Double sugerirSiguienteVolumen(String nombreSaga) {
        List<Double> volumenes = libroRepository.findVolumesBySaga(nombreSaga);
        if (volumenes.isEmpty()) {
            return 1.0; // Si la saga es nueva, empezamos por el 1
        }
        // Buscamos el máximo y sumamos 1
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

    // Métodos para los buscadores de Flutter
    public List<String> listarSagasExistentes() {
        return libroRepository.findAllUniqueSagas();
    }

    public List<String> listarAutoresExistentes() {
        return libroRepository.findAllUniqueAutores();
    }
}
