package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio JPA para la entidad {@link Libro}.
 *
 * <p>Extiende {@link JpaRepository} con consultas JPQL personalizadas para
 * los casos de uso específicos de la aplicación: sugerencia de volúmenes,
 * autocompletado de sagas y autores, desasociación previa al borrado de
 * sagas y filtrado por usuario.</p>
 */
@Repository
public interface LibroRepository extends JpaRepository<Libro, Long> {

    /**
     * Devuelve los números de volumen ya registrados para una saga concreta.
     *
     * <p>Utilizado por {@link com.uxia.uxilibris.service.LibroService#sugerirSiguienteVolumen}
     * para calcular el siguiente volumen disponible y por el controlador
     * para informar al cliente de los huecos ya ocupados.</p>
     *
     * @param saga nombre de la saga
     * @return lista de números de volumen no nulos registrados en esa saga
     */
    @Query("SELECT l.numLibroSaga FROM Libro l WHERE l.saga.nombre = :saga AND l.numLibroSaga IS NOT NULL")
    List<Double> findVolumesBySaga(@Param("saga") String saga);

    /**
     * Devuelve los nombres de saga únicos y ordenados alfabéticamente.
     *
     * <p>Utilizado para rellenar el campo de autocompletado de sagas
     * en el formulario de alta y edición de libros.</p>
     *
     * @return lista de nombres de saga sin duplicados
     */
    @Query("SELECT DISTINCT l.saga.nombre FROM Libro l WHERE l.saga IS NOT NULL ORDER BY l.saga.nombre")
    List<String> findAllUniqueSagas();

    /**
     * Devuelve los nombres de autor únicos y ordenados alfabéticamente.
     *
     * <p>Utilizado para rellenar el campo de autocompletado de autores
     * en el formulario de alta y edición de libros.</p>
     *
     * @return lista de nombres de autor sin duplicados ni valores nulos
     */
    @Query("SELECT DISTINCT l.autorNombre FROM Libro l WHERE l.autorNombre IS NOT NULL ORDER BY l.autorNombre")
    List<String> findAllUniqueAutores();

    /**
     * Establece a {@code null} la referencia de saga en todos los libros
     * que pertenecen a la saga indicada.
     *
     * <p>Debe ejecutarse antes de eliminar la saga para no violar la
     * restricción de clave foránea {@code saga_id → sagas.id}.</p>
     *
     * @param sagaId identificador de la saga que se va a eliminar
     */
    @Modifying
    @Query("UPDATE Libro l SET l.saga = null WHERE l.saga.id = :sagaId")
    void clearSagaById(@Param("sagaId") Long sagaId);

    /**
     * Devuelve todos los libros pertenecientes a un usuario concreto.
     *
     * <p>Es la consulta principal de carga de la biblioteca del usuario
     * ({@code GET /api/libros?usuarioId=X}).</p>
     *
     * @param usuarioId identificador del usuario propietario
     * @return lista de libros del usuario, sin un orden garantizado
     */
    @Query("SELECT l FROM Libro l WHERE l.usuario.id = :usuarioId")
    List<Libro> findByUsuarioId(@Param("usuarioId") Long usuarioId);
}