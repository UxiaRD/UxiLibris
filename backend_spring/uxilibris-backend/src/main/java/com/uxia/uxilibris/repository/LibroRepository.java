package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface LibroRepository extends JpaRepository<Libro, Long> {
    // Busca los números de volumen ya ocupados para una saga específica
    @Query("SELECT l.numLibroSaga FROM Libro l WHERE l.sagaNombre = :saga")
    List<Double> findVolumesBySaga(@Param("saga") String saga);

    // Obtiene la lista de nombres de sagas únicas para el Autocomplete de Flutter
    @Query("SELECT DISTINCT l.sagaNombre FROM Libro l WHERE l.sagaNombre IS NOT NULL")
    List<String> findAllUniqueSagas();

    // Obtiene la lista de autores únicos para el Autocomplete de Flutter
    @Query("SELECT DISTINCT l.autorNombre FROM Libro l")
    List<String> findAllUniqueAutores();
}
