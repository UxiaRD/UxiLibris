package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LibroRepository extends JpaRepository<Libro, Long> {

    // Volúmenes ya ocupados para una saga (por la relación, no por nombre plano)
    @Query("SELECT l.numLibroSaga FROM Libro l WHERE l.saga.nombre = :saga AND l.numLibroSaga IS NOT NULL")
    List<Double> findVolumesBySaga(@Param("saga") String saga);

    // Nombres de saga únicos para el Autocomplete de Flutter
    @Query("SELECT DISTINCT l.saga.nombre FROM Libro l WHERE l.saga IS NOT NULL ORDER BY l.saga.nombre")
    List<String> findAllUniqueSagas();

    // Autores únicos para el Autocomplete de Flutter
    @Query("SELECT DISTINCT l.autorNombre FROM Libro l WHERE l.autorNombre IS NOT NULL ORDER BY l.autorNombre")
    List<String> findAllUniqueAutores();

    // Desasocia todos los libros de una saga antes de eliminarla
    @Modifying
    @Query("UPDATE Libro l SET l.saga = null WHERE l.saga.id = :sagaId")
    void clearSagaById(@Param("sagaId") Long sagaId);

    // Libros de un usuario concreto
    @Query("SELECT l FROM Libro l WHERE l.usuario.id = :usuarioId")
    List<Libro> findByUsuarioId(@Param("usuarioId") Long usuarioId);
}