package com.uxia.uxilibris.controller;

import com.uxia.uxilibris.dto.IsbnResultDto;
import com.uxia.uxilibris.entity.Libro;
import com.uxia.uxilibris.service.GoogleBooksService;
import com.uxia.uxilibris.service.LibroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/libros")
@CrossOrigin(origins = "*") // Para permitir peticiones desde el emulador de Flutter
public class LibroController {
    @Autowired
    private LibroService libroService;

    @Autowired
    private GoogleBooksService googleBooksService;

    // GET /api/libros?usuarioId=1 → devuelve los libros del usuario indicado
    @GetMapping
    public List<Libro> listarTodos(@RequestParam Long usuarioId) {
        return libroService.listarTodosLosLibros(usuarioId);
    }
    // POST /api/libros → guarda o actualiza un libro
    // Si el JSON incluye 'id', Spring hace UPDATE. Si no, hace INSERT.
    @PostMapping
    public ResponseEntity<Libro> guardar(@RequestBody Libro libro) {
        return ResponseEntity.ok(libroService.guardarLibro(libro));
    }

    // PUT /api/libros/{id} → actualiza un libro existente
    @PutMapping("/{id}")
    public ResponseEntity<Libro> actualizar(@PathVariable Long id, @RequestBody Libro libro) {
        libro.setId(id);
        return ResponseEntity.ok(libroService.guardarLibro(libro));
    }

    // DELETE /api/libros/{id} → elimina un libro por su id
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        libroService.eliminarLibro(id);
        return ResponseEntity.noContent().build(); // devuelve 204
    }

    // GET /api/libros/volumenes?saga=NombreSaga
    @GetMapping("/volumenes")
    public ResponseEntity<List<Double>> getVolumenesPorSaga(
            @RequestParam String saga) {
        List<Double> volumenes = libroService.obtenerVolumenesDeSaga(saga);
        return ResponseEntity.ok(volumenes);
    }

    // GET /api/libros/sagas
    @GetMapping("/sagas")
    public List<String> getSagas() {
        return libroService.listarSagasExistentes();
    }

    // GET /api/libros/autores
    @GetMapping("/autores")
    public List<String> getAutores() {
        return libroService.listarAutoresExistentes();
    }

    // GET /api/libros/sugerir-volumen?saga=NombreSaga
    @GetMapping("/sugerir-volumen")
    public Double getSugerencia(@RequestParam String saga) {
        return libroService.sugerirSiguienteVolumen(saga);
    }

    // PATCH /api/libros/{id}/saga → asigna saga y volumen sin tocar el resto
    @PatchMapping("/{id}/saga")
    public ResponseEntity<Libro> asignarSaga(
            @PathVariable Long id,
            @RequestParam String saga,
            @RequestParam(required = false) Double numLibroSaga) {
        return ResponseEntity.ok(libroService.asignarSaga(id, saga, numLibroSaga));
    }

    // PATCH /api/libros/{id}/favorito?valor=true|false → marca/desmarca como favorito
    @PatchMapping("/{id}/favorito")
    public ResponseEntity<Libro> toggleFavorito(
            @PathVariable Long id,
            @RequestParam boolean valor) {
        return ResponseEntity.ok(libroService.toggleFavorito(id, valor));
    }

    // GET /api/libros/isbn/{isbn}
    @GetMapping("/isbn/{isbn}")
    public ResponseEntity<IsbnResultDto> buscarPorISBN(@PathVariable String isbn) {
        return googleBooksService.buscarPorISBN(isbn)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
