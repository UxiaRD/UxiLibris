package com.uxia.uxilibris.repository;

import com.uxia.uxilibris.entity.Saga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio JPA para la entidad {@link Saga}.
 *
 * <p>Además de las operaciones CRUD heredadas de {@link JpaRepository},
 * expone métodos derivados para buscar y verificar sagas por nombre,
 * necesarios para la lógica de auto-creación de sagas en
 * {@link com.uxia.uxilibris.service.LibroService}.</p>
 */
@Repository
public interface SagaRepository extends JpaRepository<Saga, Long> {

    /**
     * Comprueba si existe alguna saga con el nombre dado.
     *
     * <p>Usado para evitar duplicados al auto-crear una saga desde
     * el guardado de un libro.</p>
     *
     * @param nombre nombre de la saga a comprobar
     * @return {@code true} si ya existe una saga con ese nombre
     */
    boolean existsByNombre(String nombre);

    /**
     * Busca una saga por su nombre exacto.
     *
     * @param nombre nombre de la saga a buscar
     * @return {@code Optional} con la saga si existe, vacío en caso contrario
     */
    Optional<Saga> findByNombre(String nombre);
}