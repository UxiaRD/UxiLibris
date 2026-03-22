package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface LibroRepository extends JpaRepository<Libro, Long> {
    /// Busca los números de volumen ya ocupados para una saga específica.
    // Usado por sugerirSiguienteVolumen() y obtenerVolumenesDeSaga().
    // Añadido IS NOT NULL para evitar que devuelva nulls si el campo está vacío.
    @Query("SELECT l.numLibroSaga FROM Libro l WHERE l.sagaNombre = :saga AND l.numLibroSaga IS NOT NULL")
    List<Double> findVolumesBySaga(@Param("saga") String saga);

    // Obtiene la lista de nombres de sagas únicas para el Autocomplete de Flutter.
    // Añadido ORDER BY para que lleguen ordenadas alfabéticamente.
    @Query("SELECT DISTINCT l.sagaNombre FROM Libro l WHERE l.sagaNombre IS NOT NULL ORDER BY l.sagaNombre")
    List<String> findAllUniqueSagas();

    // Obtiene la lista de autores únicos para el Autocomplete de Flutter.
    // Añadido IS NOT NULL y ORDER BY.
    @Query("SELECT DISTINCT l.autorNombre FROM Libro l WHERE l.autorNombre IS NOT NULL ORDER BY l.autorNombre")
    List<String> findAllUniqueAutores();
}
