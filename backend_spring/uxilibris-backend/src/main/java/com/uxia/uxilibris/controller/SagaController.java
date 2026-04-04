package com.uxia.uxilibris.controller;

import com.uxia.uxilibris.entity.Saga;
import com.uxia.uxilibris.service.SagaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sagas")
@CrossOrigin(origins = "*")
public class SagaController {

    @Autowired
    private SagaService sagaService;

    // GET /api/sagas
    @GetMapping
    public List<Saga> listarTodas() {
        return sagaService.listarTodas();
    }

    // POST /api/sagas → crea o actualiza (si incluye id, hace UPDATE)
    @PostMapping
    public ResponseEntity<Saga> guardar(@RequestBody Saga saga) {
        return ResponseEntity.ok(sagaService.guardar(saga));
    }

    // DELETE /api/sagas/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        sagaService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}