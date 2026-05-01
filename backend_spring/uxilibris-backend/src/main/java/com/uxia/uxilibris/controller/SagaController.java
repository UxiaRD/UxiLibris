package com.uxia.uxilibris.controller;

import com.uxia.uxilibris.entity.Saga;
import com.uxia.uxilibris.service.SagaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST que gestiona las operaciones CRUD sobre las sagas literarias.
 *
 * <p>Base URL: {@code /api/sagas}</p>
 */
@RestController
@RequestMapping("/api/sagas")
@CrossOrigin(origins = "*")
public class SagaController {

    @Autowired
    private SagaService sagaService;

    /**
     * Devuelve todas las sagas almacenadas en el sistema.
     *
     * <p>{@code GET /api/sagas}</p>
     *
     * @return lista completa de sagas
     */
    @GetMapping
    public List<Saga> listarTodas() {
        return sagaService.listarTodas();
    }

    /**
     * Crea una nueva saga o actualiza una existente.
     *
     * <p>{@code POST /api/sagas}</p>
     *
     * <p>Si el cuerpo de la petición incluye un {@code id}, JPA realiza un UPDATE;
     * si no, un INSERT. El nombre se normaliza con {@code trim()} antes de guardarse.</p>
     *
     * @param saga entidad con los datos de la saga
     * @return {@code 200 OK} con la saga guardada
     */
    @PostMapping
    public ResponseEntity<Saga> guardar(@RequestBody Saga saga) {
        return ResponseEntity.ok(sagaService.guardar(saga));
    }

    /**
     * Elimina la saga indicada y desasocia todos sus libros.
     *
     * <p>{@code DELETE /api/sagas/{id}}</p>
     *
     * <p>Antes de borrar la saga, se actualiza a {@code null} el campo {@code saga_id}
     * de todos los libros que la referencian para evitar violaciones de integridad referencial.</p>
     *
     * @param id identificador de la saga a eliminar
     * @return {@code 204 No Content}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        sagaService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}