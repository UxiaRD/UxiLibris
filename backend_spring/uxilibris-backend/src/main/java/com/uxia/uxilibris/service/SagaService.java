package com.uxia.uxilibris.service;

import com.uxia.uxilibris.entity.Saga;
import com.uxia.uxilibris.repository.LibroRepository;
import com.uxia.uxilibris.repository.SagaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Servicio que gestiona las operaciones CRUD sobre las sagas literarias.
 *
 * <p>La eliminación de una saga requiere un paso previo de desasociación
 * de todos sus libros para respetar la integridad referencial de la
 * clave foránea {@code saga_id} en la tabla {@code libros}.</p>
 */
@Service
public class SagaService {

    @Autowired
    private SagaRepository sagaRepository;

    @Autowired
    private LibroRepository libroRepository;

    /**
     * Devuelve todas las sagas almacenadas en el sistema.
     *
     * @return lista completa de sagas, sin filtrado ni ordenación garantizada
     */
    public List<Saga> listarTodas() {
        return sagaRepository.findAll();
    }

    /**
     * Crea o actualiza una saga.
     *
     * <p>Si el objeto {@link Saga} incluye un {@code id}, JPA realiza un UPDATE;
     * si no, un INSERT. El nombre se normaliza con {@code trim()} para evitar
     * duplicados por espacios accidentales.</p>
     *
     * @param saga entidad con los datos de la saga a persistir
     * @return la saga guardada con su {@code id} generado o actualizado
     */
    @Transactional
    public Saga guardar(Saga saga) {
        if (saga.getNombre() != null) {
            saga.setNombre(saga.getNombre().trim());
        }
        return sagaRepository.save(saga);
    }

    /**
     * Marca o desmarca una saga como abandonada.
     *
     * @param id    identificador de la saga
     * @param valor {@code true} para abandonar, {@code false} para retomar
     * @return la saga actualizada, o {@code null} si no existe
     */
    @Transactional
    public Saga toggleAbandonada(Long id, boolean valor) {
        return sagaRepository.findById(id).map(saga -> {
            saga.setAbandonada(valor);
            return sagaRepository.save(saga);
        }).orElse(null);
    }

    /**
     * Elimina una saga y desasocia todos los libros que la referenciaban.
     *
     * <p>Primero se ejecuta un UPDATE masivo que pone a {@code null} el campo
     * {@code saga_id} de todos los libros de esa saga, evitando así la violación
     * de la restricción de clave foránea al borrar la saga.</p>
     *
     * @param id identificador de la saga a eliminar
     */
    @Transactional
    public void eliminar(Long id) {
        libroRepository.clearSagaById(id);
        sagaRepository.deleteById(id);
    }
}